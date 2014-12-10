<cfcomponent>
<!--- configure this Application.cfc options --->
<cfscript>
THIS.name = "cfSpeakerList_v1";
THIS.clientmanagement="True";
THIS.loginstorage="session";
THIS.sessionmanagement="True";
THIS.sessiontimeout="#createtimespan(0,15,0,0)#";
THIS.applicationtimeout="#createtimespan(0,0,0,0)#";
THIS.scriptprotect="all";
THIS.mappings["/core"]=ExpandPath('core');
</cfscript>
<!---                    --->
<!--- onApplicationStart --->
<!---                    --->
<cffunction name="onApplicationStart">
	<!--- set application variables --->
	<!--- NOTE: You must set up the datasource and three encryption keys  --->
	<!--- (create keys: http://www.dvdmenubacks.com/key.cfm), algorithms  --->
	<!--- (e.g. AES/CBC/PKCS5Padding) and encodings (e.g. BASE64, HEX)    --->
	<!--- before you run this application.                                --->
	<!---                                                                 --->
	<!--- NOTE: This application uses mappings to ensure access to core   --->
	<!--- components. You will need to check the Enable Per App Settings  --->
	<!--- option on the Settings page of the ColdFusion Administrator for --->
	<!--- this to work properly. Some (shared) hosting providers do not   --->
	<!--- allow per-application settings. In this case, you will need to  --->
	<!--- run this application in a root domain or sub-domain for access  --->
	<!--- to the private area to work.                                    --->
	<cfscript>
        APPLICATION.ds = "<datasource>";
		APPLICATION.dbkey1 = '<key>';
		APPLICATION.dbalg1 = '<algorithm>';
		APPLICATION.dbenc1 = '<encoding>';
		APPLICATION.dbkey2 = '<key>';
		APPLICATION.dbalg2 = '<algorithm>';
		APPLICATION.dbenc2 = '<encoding>';
		APPLICATION.dbkey3 = '<key>';
		APPLICATION.dbalg3 = '<algorithm>';
		APPLICATION.dbenc3 = '<encoding>';
		APPLICATION.siteName = 'cfSpeakerList';
		APPLICATION.siteLongName = 'cfSpeakerList';
		APPLICATION.debugOn = true;
		APPLICATION.iusTable = 'speakers';
		APPLICATION.iusColumn = 'speakerKey';
		APPLICATION.fromEmail = 'noreply@domain.tld';
		APPLICATION.bccEmail = '';
		APPLICATION.abuseEmail = 'abuse@domain.tld';
		APPLICATION.verificationTimeout = 12;
		APPLICATION.cookieName = 'cfslid';
		APPLICATION.sessionTimeout = 30;
		APPLICATION.sendSpeakerFeedbackRequests = true;
		APPLICATION.sendEventFeedbackRequests = true;
		APPLICATION.daysToFeedbackRequest = 2;
		APPLICATION.showRequestStats = true;
		APPLICATION.utils = CreateObject('component','core.utils.utils');	
		APPLICATION.urlZero = APPLICATION.utils.dataEnc(value = 0, mode = 'url');
		APPLICATION.formZero = APPLICATION.utils.dataEnc(value = 0, mode = 'form');
		APPLICATION.cookieZero = APPLICATION.utils.dataEnc(value = 0, mode = 'cookie');	
    </cfscript>
	
	<!--- INITIALIZE OBJECTS --->
  	<cfset datasourceObject = createObject('component','core.beans.Datasource').init(DSN = APPLICATION.ds) />
	<cfset APPLICATION.eventFeedbackDAO = createObject('component','core.dao.EventFeedbackDAO').init(datasource = datasourceObject) /> 
	<cfset APPLICATION.speakerDAO = createObject('component','core.dao.SpeakerDAO').init(datasource = datasourceObject) />
	<cfset APPLICATION.speakerFeedbackDAO = createObject('component','core.dao.SpeakerFeedbackDAO').init(datasource = datasourceObject) />
	<cfset APPLICATION.speakerRequestDAO = createObject('component','core.dao.SpeakerRequestDAO').init(datasource = datasourceObject) /> 
	<cfset APPLICATION.userDAO = createObject('component','core.dao.UserDAO').init(datasource = datasourceObject) />
	<cfset APPLICATION.eventFeedbackGateway = createObject('component','core.gateways.EventFeedbackGateway').init(datasource = datasourceObject) /> 
	<cfset APPLICATION.speakerGateway = createObject('component','core.gateways.SpeakerGateway').init(datasource = datasourceObject) />
	<cfset APPLICATION.speakerFeedbackGateway = createObject('component','core.gateways.SpeakerFeedbackGateway').init(datasource = datasourceObject) /> 
	<cfset APPLICATION.speakerRequestGateway = createObject('component','core.gateways.SpeakerRequestGateway').init(datasource = datasourceObject) /> 
	<cfset APPLICATION.userGateway = createObject('component','core.gateways.UserGateway').init(datasource = datasourceObject) /> 
	<cfset APPLICATION.iusUtil = createObject('component','core.utils.IrreversibleURLShortener').init(datasource = datasourceObject) />
	<cfset APPLICATION.countryGateway = createObject('component','core.gateways.CountryGateway').init(datasource = datasourceObject) /> 
	<cfset APPLICATION.stateGateway = createObject('component','core.gateways.StateGateway').init(datasource = datasourceObject) />
	
	<!--- try to use ESAPI --->
	<cftry>
		
		<!--- create the ESAPI object --->
		<cfset APPLICATION.esapiEncoder = CreateObject("java", "org.owasp.esapi.ESAPI").encoder() />
		<!--- set flag to use the ESAPI (available) --->
		<cfset APPLICATION.useESAPI = true />
	
		<!--- catch any errors instantiating the ESAPI object --->	
		<cfcatch type="any">
		
			<!--- ESAPI not available, set the flag to not use ESAPI --->
			<cfset APPLICATION.useESAPI = false />
			
		</cfcatch>
	</cftry>
	
	<!--- log the application start --->
	<cflog text="#THIS.name# Application Started" type="Information" file="#THIS.name#" thread="yes" date="yes" time="yes" application="yes">
	<cfreturn True>
</cffunction>
<!---                 --->
<!--- onSessiontStart --->
<!---                 --->
<cffunction name="onSessionStart">
</cffunction>
<!---                --->
<!--- onRequestStart --->
<!---                --->
<cffunction name="onRequestStart">
	<!--- set up a tick counter --->
	<cfset tickBegin = GetTickCount()>
	
	<!--- check if the user is in the private area of the site --->
	<cfif FindNoCase('cfslpriv',CGI.SCRIPT_NAME)>
	
		<!--- expire old sessions --->
		<cfset APPLICATION.userDAO.expireOldSessions(APPLICATION.sessionTimeout) />
	
		<!--- user is in the private area, check for the existence of a session cookie --->
		<cfif NOT IsDefined('COOKIE.#APPLICATION.cookieName#') OR NOT Len(COOKIE[APPLICATION.cookieName])>
			<!--- no cookie present, include the login form --->
			<cfinclude template="login.cfm" />
			<cfabort>
		<!--- otherwise --->
		<cfelse>
			<!--- cookie present, verify session hasn't expired --->
			<cfif NOT APPLICATION.userDAO.isValidSession(COOKIE[APPLICATION.cookieName])>
				<!--- no valid session, set an error message to display --->
				<cfset errorMsg = '<p>We&apos;re sorry but your session has expired. Please login again to continue working.</p>' />
				<!--- and include the login form --->
				<cfinclude template="login.cfm" />
				<cfabort>
			<!--- otherwise --->
			<cfelse>
				
				<!--- get the user object for this user --->
				<cfset userObj = APPLICATION.userDAO.getUserById(APPLICATION.userDAO.getUserIdFromSession(COOKIE[APPLICATION.cookieName])) />
				<!--- do session rotation, expire the existing session --->
				<cfset APPLICATION.userDAO.expireSession(COOKIE[APPLICATION.cookieName]) />
				<!--- expire the cookie --->
				<cfcookie name="#APPLICATION.cookieName#" value="" expires="now" />
				
				<!--- generate a session id --->
				<cfset sid = APPLICATION.utils.generateSessionId() />
				<!--- generate an encrypted version of the session id to store in the cookie --->
				<cfset cSid = APPLICATION.utils.dataEnc(sid, 'cookie') />
				<!--- send the new session cookie --->
				<cfcookie name="#APPLICATION.cookieName#" value="#cSid#" expires="never" />
				<!--- add the new session to the database --->
				<cfset APPLICATION.userDAO.addSession(sessionId = sid, user = userObj) />
			
			<!--- end verifying session hasn't expired --->
			</cfif>

		<!--- end checking for the existence of a session cookie --->
		</cfif>				
	
	<!--- end checking if the user is in the private area of the site --->
	</cfif>
	
</cffunction>
<cffunction name="onRequestEnd">
	<!--- check if debug is on --->
	<cfif APPLICATION.debugOn>
		<!--- it is, set up another tick counter --->
		<cfset tickEnd = GetTickCount()>
		<!--- calculate ticks it took to process this page --->
		<cfset totalTicks = tickEnd - tickBegin>			
		<!--- log the page execution time --->
		<cflog text="#CGI.SCRIPT_NAME# took #totalTicks/1000# ms to execute." type="Information" file="#THIS.name#" thread="yes" date="yes" time="yes" application="yes">
	<!--- end checking if debug is on --->
	</cfif>
</cffunction>
<!---              --->
<!--- onSessionEnd --->
<!---              --->
<cffunction name="onSessionEnd" returnType="void">
	<cfargument name="SessionScope" required=True/>
	<cfargument name="ApplicationScope" required=False/>
</cffunction>
<!---                  --->
<!--- onApplicationEnd --->
<!---                  --->
<cffunction name="onApplicationEnd">
	<cfargument name="ApplicationScope" required=true/>
	<cflog file="#This.Name#" type="Information" 
        text="Application #ApplicationScope.applicationname# Ended">
</cffunction>
</cfcomponent>