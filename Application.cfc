<cfcomponent>
<!--- configure this Application.cfm options --->
<cfscript>
THIS.name = "cfSpeakerList_v1";
THIS.clientmanagement="True";
THIS.loginstorage="session";
THIS.sessionmanagement="True";
THIS.sessiontimeout="#createtimespan(0,15,0,0)#";
THIS.applicationtimeout="#createtimespan(0,0,0,0)#";
THIS.scriptprotect="all";
</cfscript>
<!---                    --->
<!--- onApplicationStart --->
<!---                    --->
<cffunction name="onApplicationStart">
	<!--- set application variables --->
	<!--- NOTE: You must set up the datasource and three encryption keys --->
	<!--- (create keys: http://www.dvdmenubacks.com/key.cfm), algorithms --->
	<!--- (e.g. AES/CBC/PKCS5Padding) and encodings (e.g. BASE64, HEX)   --->
	<!--- before you run this application.                               --->
	<cfscript>
        APPLICATION.ds = "<datasource>";
		APPLICATION.dbkey1 = '<key1>';
		APPLICATION.dbalg1 = '<alg1>';
		APPLICATION.dbenc1 = '<enc1>';
		APPLICATION.dbkey2 = '<key2>';
		APPLICATION.dbalg2 = '<alg2>';
		APPLICATION.dbenc2 = '<enc2>';
		APPLICATION.dbkey3 = '<key3>';
		APPLICATION.dbalg3 = '<alg3>';
		APPLICATION.dbenc3 = '<enc3>';
		APPLICATION.siteName = 'UGS List';
		APPLICATION.debugOn = true;
		APPLICATION.iusTable = 'speakers';
		APPLICATION.iusColumn = 'speakerKey';
		APPLICATION.fromEmail = 'nospam@ugslist.tld';
		APPLICATION.bccEmail = '';
		APPLICATION.verificationTimeout = 12;
		APPLICATION.cookieName = 'cfslid';
		APPLICATION.sessionTimeout = 30;
		APPLICATION.utils = CreateObject('component','core.utils.utils');	
		APPLICATION.urlZero = APPLICATION.utils.dataEnc(value = 0, mode = 'url');
		APPLICATION.formZero = APPLICATION.utils.dataEnc(value = 0, mode = 'form');
		APPLICATION.cookieZero = APPLICATION.utils.dataEnc(value = 0, mode = 'cookie');	
    </cfscript>
	
	<!--- INITIALIZE OBJECTS --->
  	<cfset datasourceObject = createObject('component','core.beans.Datasource').init(DSN = APPLICATION.ds) />
	<cfset APPLICATION.speakerDAO = createObject('component','core.dao.SpeakerDAO').init(datasource = datasourceObject) />
	<cfset APPLICATION.userDAO = createObject('component','core.dao.UserDAO').init(datasource = datasourceObject) />
	<cfset APPLICATION.speakerGateway = createObject('component','core.gateways.SpeakerGateway').init(datasource = datasourceObject) />
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
		<cfset APPLICTION.userDAO.expireOldSessions() />
	
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
				<cfset userObj = APPLICATION.userDAO.getUserById(APPLICATION.userDAO.getSession(COOKIE[APPLICATION.cookieName])) />
				<!--- do session rotation, decrypt the old cookie --->
				<cfset dSid = APPLICATION.utils.dataDec(COOKIE[APPLICATION.cookieName], 'cookie') />
				<!--- expire the cookie --->
				<cfcookie name="#APPLICATION.cookieName#" value="" expires="now" />
				<!--- expire the session --->
				<cfset APPLICATION.userDAO.expireSession(dSid) />
				
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
	<!--- set up another tick counter --->
	<cfset tickEnd = GetTickCount()>
	<!--- calculate ticks it took to process this page --->
	<cfset totalTicks = tickEnd - tickBegin>
</cffunction>
<!---              --->
<!--- onSessionEnd --->
<!---              --->
<cffunction name="onSessionEnd" returnType="void">
	<cfargument name="SessionScope" required=True/>
	<cfargument name="ApplicationScope" required=False/>
	<cflock scope="Application" timeout="5" type="Exclusive">
		<cfset APPLICATION.Sessions = APPLICATION.Sessions - 1>
	</cflock>
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