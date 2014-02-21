<!--- COMPONENT --->
<cfcomponent displayname="User" output="false" hint="I am the User class.">
<cfproperty name="userId" type="string" default="" />
<cfproperty name="username" type="string" default="" />
<cfproperty name="password" type="string" default="" />
<cfproperty name="role" type="string" default="" />
<cfproperty name="isActive" type="string" default="" />

<!--- PSEUDO-CONSTRUCTOR --->
<cfset variables.instance = {
	userId = '',
	username = '',
	password = '',
	role = '',
	isActive = ''
} />

<!--- INIT --->
<cffunction name="init" access="public" output="false" returntype="any" hint="I am the constructor method for the User class.">
  <cfargument name="userId" type="string" required="true" default="" hint="" />
  <cfargument name="username" type="string" required="true" default="" hint="" />
  <cfargument name="password" type="string" required="true" default="" hint="" />
  <cfargument name="role" type="string" required="true" default="" hint="" />
  <cfargument name="isActive" type="string" required="true" default="" hint="" />
  <!--- set the initial values of the bean --->
  <cfscript>
	setUserId(ARGUMENTS.userId);
	setUsername(ARGUMENTS.username);
	setPassword(ARGUMENTS.password);
	setRole(ARGUMENTS.role);
	setIsActive(ARGUMENTS.isActive);
  </cfscript>
  <cfreturn this>
</cffunction>

<!--- SETTERS --->
<cffunction name="setUserId" access="public" output="false" hint="I set the userId value into the variables.instance scope.">
  <cfargument name="userId" type="string" required="true" default="" hint="I am the userId value." />
  <cfset variables.instance.userId = ARGUMENTS.userId />
</cffunction>

<cffunction name="setUsername" access="public" output="false" hint="I set the username value into the variables.instance scope.">
  <cfargument name="username" type="string" required="true" default="" hint="I am the username value." />
  <cfset variables.instance.username = ARGUMENTS.username />
</cffunction>

<cffunction name="setPassword" access="public" output="false" hint="I set the password value into the variables.instance scope.">
  <cfargument name="password" type="string" required="true" default="" hint="I am the password value." />
  <cfset variables.instance.password = ARGUMENTS.password />
</cffunction>

<cffunction name="setRole" access="public" output="false" hint="I set the role value into the variables.instance scope.">
  <cfargument name="role" type="string" required="true" default="" hint="I am the role value." />
  <cfset variables.instance.role = ARGUMENTS.role />
</cffunction>

<cffunction name="setIsActive" access="public" output="false" hint="I set the isActive value into the variables.instance scope.">
  <cfargument name="isActive" type="string" required="true" default="" hint="I am the isActive value." />
  <cfset variables.instance.isActive = ARGUMENTS.isActive />
</cffunction>

<!--- GETTERS --->
<cffunction name="getUserId" access="public" output="false" returntype="string" hint="I return the userId value.">
  <cfreturn variables.instance.userId />
</cffunction>

<cffunction name="getUniqueID" access="public" output="false" returntype="string" hint="I return the userId value. (alternate/ legacy method)">
  <cfreturn variables.instance.userId />
</cffunction>

<cffunction name="getUsername" access="public" output="false" returntype="string" hint="I return the username value.">
  <cfreturn variables.instance.username />
</cffunction>

<cffunction name="getPassword" access="public" output="false" returntype="string" hint="I return the password value.">
  <cfreturn variables.instance.password />
</cffunction>

<cffunction name="getRole" access="public" output="false" returntype="string" hint="I return the role value.">
  <cfreturn variables.instance.role />
</cffunction>

<cffunction name="getIsActive" access="public" output="false" returntype="string" hint="I return the isActive value.">
  <cfreturn variables.instance.isActive />
</cffunction>

<!--- UTILITY METHODS --->
<cffunction name="getMemento" access="public" output="false" hint="I return a struct of the variables.instance scope.">
  <cfreturn variables.instance />
</cffunction>
</cfcomponent>
