<!--- COMPONENT --->
<cfcomponent displayname="SpeakerGateway" output="false" hint="I am the SpeakerGateway class.">

<!--- Pseudo-constructor --->
<cfset variables.instance = {
	datasource = ''
} />
<cffunction name="init" access="public" output="false" returntype="any" hint="I am the constructor method of the SpeakerGateway class.">
  <cfargument name="datasource" type="any" required="true" hint="I am the Datasource bean." />
  <!--- Set the initial values of the Bean --->
  <cfscript>
	variables.instance.datasource = arguments.datasource;
  </cfscript>
  <cfreturn this>
</cffunction>
<!--- PUBLIC METHODS --->
<!--- NO FILTER - GET ALL RECORDS --->
<cffunction name="getAllSpeakers" access="public" output="false" returntype="query" hint="I return a query of all records in the speakers table in the database.">
    <cfset var thisFilter = {
		bogus = 'bogus'
    } />

  <cfreturn filterAllSpeakers(thisFilter) />
</cffunction>
<!--- FILTER --->
<cffunction name="filter" access="public" output="false" returntype="any" hint="I run a query of all records within the database table.">
  <cfargument name="userId" type="any" required="false" default="" hint="I am the userId numeric to return records for." />
  <cfargument name="firstName" type="any" required="false" default="" hint="I am the firstName string to return records for." />
  <cfargument name="lastName" type="any" required="false" default="" hint="I am the lastName string to return records for." />
  <cfargument name="email" type="any" required="false" default="" hint="I am the email string to return records for." />
  <cfargument name="phone" type="any" required="false" default="" hint="I am the phone string to return records for." />
  <cfargument name="twitter" type="any" required="false" default="" hint="I am the twitter string to return records for." />
  <cfargument name="specialties" type="any" required="false" default="" hint="I am the specialties string to return records for." />
  <cfargument name="locations" type="any" required="false" default="" hint="I am the locations string to return records for." />
  <cfargument name="majorCity" type="any" required="false" default="" hint="I am the major city string to return records for." />
  <cfargument name="isOnline" type="any" required="false" default="" hint="I am the isOnline boolean to return records for." />
  <cfargument name="isACP" type="any" required="false" default="" hint="I am the isACP boolean to return records for." />
  <cfargument name="isAEL" type="any" required="false" default="" hint="I am the isAEL boolean to return records for." />
  <cfargument name="isUGM" type="any" required="false" default="" hint="I am the isUGM boolean to return records for." />
  <cfargument name="isOther" type="any" required="false" default="" hint="I am the isOther boolean to return records for." />
  <cfargument name="orderBy" type="any" required="false" default="" hint="I am the column(s) (and optional ordinal ASC or DESC) that records should be ordered by." />
  <cfargument name="cache" type="any" required="false" default="false" hint="I am a flag to determine if this query should be cached." />
  <cfargument name="cacheTime" type="any" required="false" default="#CreateTimeSpan(0,1,0,0)#" hint="I am the timespan to cache this query (Use CreateTimeSpan() or use the default cache time of one hour by not passing this variable." />
	<cfargument name="showActive" type="boolean" required="false" default="true" hint="I am a flag to determine if active or inactive users should be returned." />
    <cfset var thisFilter = StructNew() />
    <cfif IsDefined('ARGUMENTS.userId') AND ARGUMENTS.userId NEQ "">
		<cfset thisFilter.userId = ARGUMENTS.userId />
    </cfif>
    <cfif IsDefined('ARGUMENTS.firstName') AND ARGUMENTS.firstName NEQ "">
		<cfset thisFilter.firstName = ARGUMENTS.firstName />
    </cfif>
    <cfif IsDefined('ARGUMENTS.lastName') AND ARGUMENTS.lastName NEQ "">
		<cfset thisFilter.lastName = ARGUMENTS.lastName />
    </cfif>
    <cfif IsDefined('ARGUMENTS.email') AND ARGUMENTS.email NEQ "">
		<cfset thisFilter.email = ARGUMENTS.email />
    </cfif>
    <cfif IsDefined('ARGUMENTS.phone') AND ARGUMENTS.phone NEQ "">
		<cfset thisFilter.phone = ARGUMENTS.phone />
    </cfif>
    <cfif IsDefined('ARGUMENTS.twitter') AND ARGUMENTS.twitter NEQ "">
		<cfset thisFilter.twitter = ARGUMENTS.twitter />
    </cfif>
    <cfif IsDefined('ARGUMENTS.specialties') AND ARGUMENTS.specialties NEQ "">
		<cfset thisFilter.specialties = ARGUMENTS.specialties />
    </cfif>
    <cfif IsDefined('ARGUMENTS.locations') AND ARGUMENTS.locations NEQ "">
		<cfset thisFilter.locations = ARGUMENTS.locations />
    </cfif>
    <cfif IsDefined('ARGUMENTS.majorCity') AND ARGUMENTS.majorCity NEQ "">
		<cfset thisFilter.majorCity = ARGUMENTS.majorCity />
    </cfif>
    <cfif IsDefined('ARGUMENTS.isOnline') AND ARGUMENTS.isOnline NEQ "">
		<cfset thisFilter.isOnline = ARGUMENTS.isOnline />
    </cfif>
    <cfif IsDefined('ARGUMENTS.isACP') AND ARGUMENTS.isACP NEQ "">
		<cfset thisFilter.isACP = ARGUMENTS.isACP />
    </cfif>
    <cfif IsDefined('ARGUMENTS.isAEL') AND ARGUMENTS.isAEL NEQ "">
		<cfset thisFilter.isAEL = ARGUMENTS.isAEL />
    </cfif>
    <cfif IsDefined('ARGUMENTS.isUGM') AND ARGUMENTS.isUGM NEQ "">
		<cfset thisFilter.isUGM = ARGUMENTS.isUGM />
    </cfif>
    <cfif IsDefined('ARGUMENTS.isOther') AND ARGUMENTS.isOther NEQ "">
		<cfset thisFilter.isOther = ARGUMENTS.isOther />
    </cfif>
    <cfif IsDefined('ARGUMENTS.orderBy') AND ARGUMENTS.orderBy NEQ "">
		<cfset thisFilter.order_by = ARGUMENTS.orderBy />
    </cfif>
    <cfif IsDefined('ARGUMENTS.cache') AND ARGUMENTS.cache NEQ "">
		<cfset thisFilter.cache = ARGUMENTS.cache />
    </cfif>
    <cfif IsDefined('ARGUMENTS.cacheTime') AND ARGUMENTS.cacheTime NEQ "">
		<cfset thisFilter.cacheTime = ARGUMENTS.cacheTime />
    </cfif>
  <cfif NOT structIsEmpty(thisFilter) AND structKeyExists(thisFilter, 'cache') AND thisFilter.cache>
    <cfreturn cacheAllSpeakers(thisFilter, ARGUMENTS.showActive) />
  <cfelse>
    <cfreturn filterAllSpeakers(thisFilter, ARGUMENTS.showActive) />
  </cfif>
</cffunction>

<!--- SIMPLE SEARCH --->
<cffunction name="simpleSearch" access="public" output="false" returntype="query" hint="I run a simple search of all terms provided across multiple speaker fields.">
	<cfargument name="searchTerm" type="string" required="true" hint="I am the search term to use for this search.">
	<cfargument name="isOnline" type="string" required="false" default="false" hint="I am a flag to determine if only online speakers are returned." />
	<cfargument name="cache" type="boolean" required="false" default="false" hint="I am a flag to determine if this query should be cached." />
	<cfargument name="cacheTime" type="any" required="false" default="#CreateTimeSpan(0,0,0,0)#" hint="I am the timespan to cache this query (Use CreateTimeSpan())." />
	<cfargument name="orderBy" type="string" required="false" default="lastName, firstName" hint="I am the column(s) (and optional ordinal ASC or DESC) that records should be ordered by." />
	<cfargument name="showActive" type="boolean" required="false" default="true" hint="I am a flag to determine if active or inactive users should be returned." />
	
	<!--- var scope --->
	<cfset var variables.qGetSpeakers = '' />
	<cfset var queryName = 'qGetSpeakers' />
	<cfset var variables['db' & Hash(ARGUMENTS.searchTerm)] = '' />
	<cfset var iX = 0 />
	<cfset var thisTerm = '' />
	
	<!--- check if we're caching this query --->
	<cfif cache>
		<!--- we are, set the name of the query to a hash of the search terms --->
		<cfset queryName = 'db' & Hash(ARGUMENTS.searchTerm) />
	</cfif>	
	
	<!--- query (and possibly cache) the list of speakers by looping through the search term(s) --->
	<!--- for each of the first name, last name, twitter handle, specialties and locations --->
	<cfquery name="#queryName#" datasource="#variables.instance.datasource.getDSN()#" username="#variables.instance.datasource.getUsername()#" password="#variables.instance.datasource.getPassword()#" cachedwithin="#ARGUMENTS.cacheTime#">
		SELECT s.speakerKey, s.email, s.firstName, s.lastName, s.specialties, s.locations, s.majorCity, s.isOnline
		FROM speakers s
		LEFT JOIN users u ON u.userId = s.userId
		WHERE ( u.role = <cfqueryparam value="speaker" cfsqltype="cf_sql_varchar" />
				AND u.isActive = <cfqueryparam value="1" cfsqltype="cf_sql_bit" />
		)		
		AND ((  
		<!--- first name loop --->
		<cfloop from="1" to="#ListLen(ARGUMENTS.searchTerm,' ')#" index="iX">
			LOWER(s.firstName) LIKE <cfqueryparam value="%#LCase(ListGetAt(ARGUMENTS.searchTerm,iX,' '))#%" cfsqltype="cf_sql_varchar" />
			<cfif NOT iX EQ ListLen(ARGUMENTS.searchTerm,' ')> OR </cfif>
		</cfloop>
		)
		OR (
		<!--- last name loop --->
		<cfloop from="1" to="#ListLen(ARGUMENTS.searchTerm,' ')#" index="iX">
			LOWER(s.lastName) LIKE <cfqueryparam value="%#LCase(ListGetAt(ARGUMENTS.searchTerm,iX,' '))#%" cfsqltype="cf_sql_varchar" />
			<cfif NOT iX EQ ListLen(ARGUMENTS.searchTerm,' ')> OR </cfif>
		</cfloop>
		)
		OR ( 
		<!--- specialties loop --->
		<cfloop from="1" to="#ListLen(ARGUMENTS.searchTerm,' ')#" index="iX">
			LOWER(s.specialties) LIKE <cfqueryparam value="%#LCase(ListGetAt(ARGUMENTS.searchTerm,iX,' '))#%" cfsqltype="cf_sql_varchar" />
			<cfif NOT iX EQ ListLen(ARGUMENTS.searchTerm,' ')> OR </cfif>
		</cfloop>
		)
		OR ( 
		<!--- locations --->
			LOWER(s.locations) LIKE <cfqueryparam value="%#LCase(ARGUMENTS.searchTerm)#%" cfsqltype="cf_sql_varchar" />	
		)
		OR ( 
		<!--- Major City --->
			LOWER(s.majorCity) LIKE <cfqueryparam value="%#LCase(ARGUMENTS.searchTerm)#%" cfsqltype="cf_sql_varchar" />	
		))
		<cfif ARGUMENTS.isOnline>
			AND s.isOnline = <cfqueryparam value="1" cfsqltype="cf_sql_tinyint" />
		</cfif>
		ORDER BY #ARGUMENTS.orderBy#
	</cfquery>
	
	<!--- return the query by name --->
	<cfreturn variables[queryName] />
</cffunction>	

<!--- COMPLEX SEARCH --->
<cffunction name="complexSearch" access="public" output="false" returntype="query" hint="I run a complex AND search of all terms provided across multiple speaker fields.">
	<cfargument name="searchTerms" type="string" required="true" hint="I am the search terms list to use for this search.">
	<cfargument name="isOnline" type="string" required="false" default="false" hint="I am a flag to determine if only online speakers are returned." />
	<cfargument name="cache" type="boolean" required="false" default="false" hint="I am a flag to determine if this query should be cached." />
	<cfargument name="cacheTime" type="any" required="false" default="#CreateTimeSpan(0,0,0,0)#" hint="I am the timespan to cache this query (Use CreateTimeSpan())." />
	<cfargument name="orderBy" type="string" required="false" default="lastName, firstName" hint="I am the column(s) (and optional ordinal ASC or DESC) that records should be ordered by." />
	<cfargument name="showActive" type="boolean" required="false" default="true" hint="I am a flag to determine if active or inactive users should be returned." />
	
	<!--- var scope --->
	<cfset var variables.qGetSpeakers = '' />
	<cfset var queryName = 'qGetSpeakers' />
	<cfset var variables['db' & Hash(ARGUMENTS.searchTerms)] = '' />
	<cfset var iX = 0 />
	<cfset var iY = 0 />
	<cfset var thisTerm = '' />
	
	<!--- check if we're caching this query --->
	<cfif cache>
		<!--- we are, set the name of the query to a hash of the search terms --->
		<cfset queryName = 'db' & Hash(ARGUMENTS.searchTerms) />
	</cfif>	
	
	<!--- query (and possibly cache) the list of speakers by looping through the search term(s) --->
	<!--- for each of the first name, last name, twitter handle, specialties and locations --->
	<cfquery name="#queryName#" datasource="#variables.instance.datasource.getDSN()#" username="#variables.instance.datasource.getUsername()#" password="#variables.instance.datasource.getPassword()#" cachedwithin="#ARGUMENTS.cacheTime#">
		SELECT s.speakerKey, s.email, s.firstName, s.lastName, s.specialties, s.locations, s.isOnline
		FROM speakers s
		LEFT JOIN users u ON u.userId = s.userId
		WHERE ( u.role = <cfqueryparam value="speaker" cfsqltype="cf_sql_varchar" />
				AND u.isActive = <cfqueryparam value="1" cfsqltype="cf_sql_bit" />
		)		
		<!--- loop through 'AND' terms --->
		<cfloop from="1" to="#ListLen(ARGUMENTS.searchTerms)#" index="iY">
			AND ((  
			<!--- first name loop --->
			<cfloop from="1" to="#ListLen(ListGetAt(ARGUMENTS.searchTerms,iY),' ')#" index="iX">
				LOWER(s.firstName) LIKE <cfqueryparam value="%#LCase(ListGetAt(ListGetAt(ARGUMENTS.searchTerms,iY),iX,' '))#%" cfsqltype="cf_sql_varchar" />
				<cfif NOT iX EQ ListLen(ListGetAt(ARGUMENTS.searchTerms,iY),' ')> OR </cfif>
			</cfloop>
			)
			OR (
			<!--- last name loop --->
			<cfloop from="1" to="#ListLen(ListGetAt(ARGUMENTS.searchTerms,iY),' ')#" index="iX">
				LOWER(s.lastName) LIKE <cfqueryparam value="%#LCase(ListGetAt(ListGetAt(ARGUMENTS.searchTerms,iY),iX,' '))#%" cfsqltype="cf_sql_varchar" />
				<cfif NOT iX EQ ListLen(ListGetAt(ARGUMENTS.searchTerms,iY),' ')> OR </cfif>
			</cfloop>
			)
			OR ( 
			<!--- specialties loop --->
			<cfloop from="1" to="#ListLen(ListGetAt(ARGUMENTS.searchTerms,iY),' ')#" index="iX">
				LOWER(s.specialties) LIKE <cfqueryparam value="%#LCase(ListGetAt(ListGetAt(ARGUMENTS.searchTerms,iY),iX,' '))#%" cfsqltype="cf_sql_varchar" />
				<cfif NOT iX EQ ListLen(ListGetAt(ARGUMENTS.searchTerms,iY),' ')> OR </cfif>
			</cfloop>
			)
			OR ( 
			<!--- locations --->
				LOWER(s.locations) LIKE <cfqueryparam value="%#LCase(ARGUMENTS.searchTerm)#%" cfsqltype="cf_sql_varchar" />	
			)
			OR ( 
			<!--- Major City --->
				LOWER(s.majorCity) LIKE <cfqueryparam value="%#LCase(ARGUMENTS.searchTerm)#%" cfsqltype="cf_sql_varchar" />	
			))
		<!--- end looping through 'AND' terms --->
		</cfloop>
		<cfif ARGUMENTS.isOnline>
			AND s.isOnline = <cfqueryparam value="1" cfsqltype="cf_sql_tinyint" />
		</cfif>
		ORDER BY #ARGUMENTS.orderBy#
	</cfquery>
		
	<!--- return the query by name --->
	<cfreturn variables[queryName] />
</cffunction>	

<!--- PRIVATE METHODS --->
<!--- QUERY - CACHE ALL --->
<cffunction name="cacheAllSpeakers" access="private" output="false" returntype="any" hint="I run a query and will return all speakers records. If a filter has been applied, I will refine results based on the filter.">
  <cfargument name="filter" type="struct" required="false" default="#StructNew()#" hint="I am a structure used to filter the query." />
  <cfargument name="showActive" type="boolean" required="false" default="true" hint="I am a flag to determine if active or inactive users should be returned." />
  <cfset var cachedQueryName = '' />
	<cfloop collection="#ARGUMENTS.filter#" item="thisFilter">
		<cfset cachedQueryName = cachedQueryName & thisFilter & ARGUMENTS.filter[thisFilter] />
	</cfloop>
	<cfset cachedQueryName = 'db' & Hash(cachedQueryName,'MD5') />
	<cfquery name="#cachedQueryName#" datasource="#variables.instance.datasource.getDSN()#" username="#variables.instance.datasource.getUsername()#" password="#variables.instance.datasource.getPassword()#" cachedwithin="#ARGUMENTS.filter.cacheTime#">
		SELECT s.speakerKey, s.userId, s.firstName, s.lastName, s.email, s.phone, s.showPhone, s.twitter, s.showTwitter, s.blog, s.bio, s.specialties, s.locations, s.majorCity, s.isOnline, s.isACP, s.isAEL, s.isUGM, s.isOther
		FROM speakers s
		LEFT JOIN users u ON u.userId = s.userId
		WHERE ( u.role = <cfqueryparam value="speaker" cfsqltype="cf_sql_varchar" />
			AND u.isActive = <cfqueryparam value="#ARGUMENTS.showActive#" cfsqltype="cf_sql_bit" />
		)  
	<cfif NOT structIsEmpty(ARGUMENTS.filter)>
    <!--- filter is applied --->
    <cfif structKeyExists(ARGUMENTS.filter, 'userId')>
		AND s.userId = <cfqueryparam value="#ARGUMENTS.filter.userId#" cfsqltype="cf_sql_integer" />
    </cfif>
    <cfif structKeyExists(ARGUMENTS.filter, 'firstName')>
		AND s.firstName = <cfqueryparam value="#ARGUMENTS.filter.firstName#" cfsqltype="cf_sql_varchar" />
    </cfif>
    <cfif structKeyExists(ARGUMENTS.filter, 'lastName')>
		AND s.lastName = <cfqueryparam value="#ARGUMENTS.filter.lastName#" cfsqltype="cf_sql_varchar" />
    </cfif>
    <cfif structKeyExists(ARGUMENTS.filter, 'email')>
		AND s.email = <cfqueryparam value="#ARGUMENTS.filter.email#" cfsqltype="cf_sql_varchar" />
    </cfif>
    <cfif structKeyExists(ARGUMENTS.filter, 'phone')>
		AND s.phone = <cfqueryparam value="#ARGUMENTS.filter.phone#" cfsqltype="cf_sql_varchar" />
    </cfif>
    <cfif structKeyExists(ARGUMENTS.filter, 'twitter')>
		AND s.twitter = <cfqueryparam value="#ARGUMENTS.filter.twitter#" cfsqltype="cf_sql_varchar" />
    </cfif>
    <cfif structKeyExists(ARGUMENTS.filter, 'specialties')>
		AND s.specialties = <cfqueryparam value="#ARGUMENTS.filter.specialties#" cfsqltype="cf_sql_varchar" />
    </cfif>
    <cfif structKeyExists(ARGUMENTS.filter, 'locations')>
		AND s.locations = <cfqueryparam value="#ARGUMENTS.filter.locations#" cfsqltype="cf_sql_varchar" />
    </cfif>
    <cfif structKeyExists(ARGUMENTS.filter, 'isACP')>
		AND s.isACP = <cfqueryparam value="#ARGUMENTS.filter.isACP#" cfsqltype="cf_sql_bit" />
    </cfif>
    <cfif structKeyExists(ARGUMENTS.filter, 'isAEL')>
		AND s.isAEL = <cfqueryparam value="#ARGUMENTS.filter.isAEL#" cfsqltype="cf_sql_bit" />
    </cfif>
    <cfif structKeyExists(ARGUMENTS.filter, 'isUGM')>
		AND s.isUGM = <cfqueryparam value="#ARGUMENTS.filter.isUGM#" cfsqltype="cf_sql_bit" />
    </cfif>
    <cfif structKeyExists(ARGUMENTS.filter, 'isOther')>
		AND s.isOther = <cfqueryparam value="#ARGUMENTS.filter.isOther#" cfsqltype="cf_sql_bit" />
    </cfif>
    <cfif structKeyExists(ARGUMENTS.filter, 'order_by')>
	ORDER BY s.#ARGUMENTS.filter.order_by#
    </cfif>
  </cfif>
  </cfquery>
  <cfreturn variables[cachedQueryName] />
</cffunction>

<!--- QUERY - FILTER ALL --->
<cffunction name="filterAllSpeakers" access="private" output="false" returntype="any" hint="I run a query and will return all speakers records. If a filter has been applied, I will refine results based on the filter.">
  <cfargument name="filter" type="struct" required="false" default="#StructNew()#" hint="I am a structure used to filter the query." />  
  <cfargument name="showActive" type="boolean" required="false" default="true" hint="I am a flag to determine if active or inactive users should be returned." />
  <cfset var qGetSpeakers = '' />

  <cfquery name="qGetSpeakers" datasource="#variables.instance.datasource.getDSN()#" username="#variables.instance.datasource.getUsername()#" password="#variables.instance.datasource.getPassword()#">
		SELECT s.speakerKey, s.userId, s.firstName, s.lastName, s.email, s.phone, s.showPhone, s.twitter, s.showTwitter, s.blog, s.bio, s.specialties, s.locations, s.majorCity, s.isOnline, s.isACP, s.isAEL, s.isUGM, s.isOther
		FROM speakers s
		LEFT JOIN users u ON u.userId = s.userId
		WHERE ( u.role = <cfqueryparam value="speaker" cfsqltype="cf_sql_varchar" />
			AND u.isActive = <cfqueryparam value="#ARGUMENTS.showActive#" cfsqltype="cf_sql_bit" />
		)  
	<cfif NOT structIsEmpty(ARGUMENTS.filter)>
    <!--- filter is applied --->
    <cfif structKeyExists(ARGUMENTS.filter, 'userId')>
		AND s.userId = <cfqueryparam value="#ARGUMENTS.filter.userId#" cfsqltype="cf_sql_integer" />
    </cfif>
    <cfif structKeyExists(ARGUMENTS.filter, 'firstName')>
		AND s.firstName = <cfqueryparam value="#ARGUMENTS.filter.firstName#" cfsqltype="cf_sql_varchar" />
    </cfif>
    <cfif structKeyExists(ARGUMENTS.filter, 'lastName')>
		AND s.lastName = <cfqueryparam value="#ARGUMENTS.filter.lastName#" cfsqltype="cf_sql_varchar" />
    </cfif>
    <cfif structKeyExists(ARGUMENTS.filter, 'email')>
		AND s.email = <cfqueryparam value="#ARGUMENTS.filter.email#" cfsqltype="cf_sql_varchar" />
    </cfif>
    <cfif structKeyExists(ARGUMENTS.filter, 'phone')>
		AND s.phone = <cfqueryparam value="#ARGUMENTS.filter.phone#" cfsqltype="cf_sql_varchar" />
    </cfif>
    <cfif structKeyExists(ARGUMENTS.filter, 'twitter')>
		AND s.twitter = <cfqueryparam value="#ARGUMENTS.filter.twitter#" cfsqltype="cf_sql_varchar" />
    </cfif>
    <cfif structKeyExists(ARGUMENTS.filter, 'specialties')>
		AND s.specialties = <cfqueryparam value="#ARGUMENTS.filter.specialties#" cfsqltype="cf_sql_varchar" />
    </cfif>
    <cfif structKeyExists(ARGUMENTS.filter, 'locations')>
		AND s.locations = <cfqueryparam value="#ARGUMENTS.filter.locations#" cfsqltype="cf_sql_varchar" />
    </cfif>
    <cfif structKeyExists(ARGUMENTS.filter, 'isACP')>
		AND s.isACP = <cfqueryparam value="#ARGUMENTS.filter.isACP#" cfsqltype="cf_sql_bit" />
    </cfif>
    <cfif structKeyExists(ARGUMENTS.filter, 'isAEL')>
		AND s.isAEL = <cfqueryparam value="#ARGUMENTS.filter.isAEL#" cfsqltype="cf_sql_bit" />
    </cfif>
    <cfif structKeyExists(ARGUMENTS.filter, 'isUGM')>
		AND s.isUGM = <cfqueryparam value="#ARGUMENTS.filter.isUGM#" cfsqltype="cf_sql_bit" />
    </cfif>
    <cfif structKeyExists(ARGUMENTS.filter, 'isOther')>
		AND s.isOther = <cfqueryparam value="#ARGUMENTS.filter.isOther#" cfsqltype="cf_sql_bit" />
    </cfif>
    <cfif structKeyExists(ARGUMENTS.filter, 'order_by')>
	ORDER BY s.#ARGUMENTS.filter.order_by#
    </cfif>
  </cfif>
  </cfquery>
  <cfreturn qGetSpeakers />
  </cffunction>
</cfcomponent>

