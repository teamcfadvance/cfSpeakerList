<cfcomponent>
<!--- configure this Application.cfm options --->
<cfscript>
THIS.name = "UGSLIST_v1";
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
		APPLICATION.debugOn = true;
		APPLICATION.iusTable = 'speakers';
		APPLICATION.iusColumn = 'speakerKey';
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