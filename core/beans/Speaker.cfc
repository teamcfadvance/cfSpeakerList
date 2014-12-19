<!--- COMPONENT --->
<cfcomponent displayname="Speaker" output="false" hint="I am the Speaker class.">
<cfproperty name="speakerId" type="string" default="" />
<cfproperty name="userId" type="string" default="" />
<cfproperty name="firstName" type="string" default="" />
<cfproperty name="lastName" type="string" default="" />
<cfproperty name="email" type="string" default="" />
<cfproperty name="phone" type="string" default="" />
<cfproperty name="twitter" type="string" default="" />
<cfproperty name="blog" type="string" default="" />
<cfproperty name="bio" type="string" default="" />
<cfproperty name="specialties" type="string" default="" />
<cfproperty name="locations" type="string" default="" />
<cfproperty name="majorCity" type="string" default="" />
<cfproperty name="isOnline" type="string" default="" />
<cfproperty name="isACP" type="string" default="" />
<cfproperty name="isAEL" type="string" default="" />
<cfproperty name="isAET" type="string" default="" />
<cfproperty name="isACL" type="string" default="" />
<cfproperty name="isUGM" type="string" default="" />
<cfproperty name="isOther" type="string" default="" />

<!--- PSEUDO-CONSTRUCTOR --->
<cfset variables.instance = {
	speakerId = '',
	speakerKey = '',
	userId = '',
	firstName = '',
	lastName = '',
	email = '',
	phone = '',
	showPhone = '',
	twitter = '',
	showTwitter = '',
  blog = '',
  bio = '',
	specialties = '',
	locations = '',
  majorCity = '',
  isOnline = '',
	isACP = '',
	isAEL = '',
  isAET = '',
  isACL = '',
	isUGM = '',
	isOther = ''
} />

<!--- INIT --->
<cffunction name="init" access="public" output="false" returntype="any" hint="I am the constructor method for the Speaker class.">
  <cfargument name="speakerId" type="string" required="true" default="" hint="" />
  <cfargument name="speakerKey" type="string" required="true" default="" hint="" />
  <cfargument name="userId" type="string" required="true" default="" hint="" />
  <cfargument name="firstName" type="string" required="true" default="" hint="" />
  <cfargument name="lastName" type="string" required="true" default="" hint="" />
  <cfargument name="email" type="string" required="true" default="" hint="" />
  <cfargument name="phone" type="string" required="true" default="" hint="" />
  <cfargument name="showPhone" type="string" required="true" default="" hint="" />
  <cfargument name="twitter" type="string" required="true" default="" hint="" />
  <cfargument name="showTwitter" type="string" required="true" default="" hint="" />
  <cfargument name="blog" type="string" required="true" default="" hint="" />
  <cfargument name="bio" type="string" required="true" default="" hint="" />
  <cfargument name="specialties" type="string" required="true" default="" hint="" />
  <cfargument name="locations" type="string" required="true" default="" hint="" />
  <cfargument name="majorCity" type="string" required="true" default="" hint="" />
  <cfargument name="isOnline" type="string" required="true" default="" hint="" />
  <cfargument name="isACP" type="string" required="true" default="" hint="" />
  <cfargument name="isAEL" type="string" required="true" default="" hint="" />
  <cfargument name="isAET" type="string" required="true" default="" hint="" />
  <cfargument name="isACL" type="string" required="true" default="" hint="" />
  <cfargument name="isUGM" type="string" required="true" default="" hint="" />
  <cfargument name="isOther" type="string" required="true" default="" hint="" />
  <!--- set the initial values of the bean --->
  <cfscript>
	setSpeakerId(ARGUMENTS.speakerId);
	setSpeakerKey(ARGUMENTS.speakerKey);
	setUserId(ARGUMENTS.userId);
	setFirstName(ARGUMENTS.firstName);
	setLastName(ARGUMENTS.lastName);
	setEmail(ARGUMENTS.email);
	setPhone(ARGUMENTS.phone);
	setShowPhone(ARGUMENTS.showPhone);
	setTwitter(ARGUMENTS.twitter);
	setShowTwitter(ARGUMENTS.showTwitter);
  setBlog(ARGUMENTS.blog);
  setBio(ARGUMENTS.bio);
	setSpecialties(ARGUMENTS.specialties);
	setLocations(ARGUMENTS.locations);
  setMajorCity(ARGUMENTS.majorCity);
  setIsOnline(ARGUMENTS.isOnline);
	setIsACP(ARGUMENTS.isACP);
	setIsAEL(ARGUMENTS.isAEL);
  setIsAET(ARGUMENTS.isAET);
  setIsACL(ARGUMENTS.isACL);
	setIsUGM(ARGUMENTS.isUGM);
	setIsOther(ARGUMENTS.isOther);
  </cfscript>
  <cfreturn this>
</cffunction>

<!--- SETTERS --->
<cffunction name="setSpeakerId" access="public" output="false" hint="I set the speakerId value into the variables.instance scope.">
  <cfargument name="speakerId" type="string" required="true" default="" hint="I am the speakerId value." />
  <cfset variables.instance.speakerId = ARGUMENTS.speakerId />
</cffunction>

<cffunction name="setSpeakerKey" access="public" output="false" hint="I set the speakerKey value into the variables.instance scope.">
  <cfargument name="speakerKey" type="string" required="true" default="" hint="I am the speakerKey value." />
  <cfset variables.instance.speakerKey = ARGUMENTS.speakerKey />
</cffunction>

<cffunction name="setUserId" access="public" output="false" hint="I set the userId value into the variables.instance scope.">
  <cfargument name="userId" type="string" required="true" default="" hint="I am the userId value." />
  <cfset variables.instance.userId = ARGUMENTS.userId />
</cffunction>

<cffunction name="setFirstName" access="public" output="false" hint="I set the firstName value into the variables.instance scope.">
  <cfargument name="firstName" type="string" required="true" default="" hint="I am the firstName value." />
  <cfset variables.instance.firstName = ARGUMENTS.firstName />
</cffunction>

<cffunction name="setLastName" access="public" output="false" hint="I set the lastName value into the variables.instance scope.">
  <cfargument name="lastName" type="string" required="true" default="" hint="I am the lastName value." />
  <cfset variables.instance.lastName = ARGUMENTS.lastName />
</cffunction>

<cffunction name="setEmail" access="public" output="false" hint="I set the email value into the variables.instance scope.">
  <cfargument name="email" type="string" required="true" default="" hint="I am the email value." />
  <cfset variables.instance.email = ARGUMENTS.email />
</cffunction>

<cffunction name="setPhone" access="public" output="false" hint="I set the phone value into the variables.instance scope.">
  <cfargument name="phone" type="string" required="true" default="" hint="I am the phone value." />
  <cfset variables.instance.phone = ARGUMENTS.phone />
</cffunction>

<cffunction name="setShowPhone" access="public" output="false" hint="I set the showPhone value into the variables.instance scope.">
  <cfargument name="showPhone" type="string" required="true" default="" hint="I am the showPhone value." />
  <cfset variables.instance.showPhone = ARGUMENTS.showPhone />
</cffunction>

<cffunction name="setTwitter" access="public" output="false" hint="I set the twitter value into the variables.instance scope.">
  <cfargument name="twitter" type="string" required="true" default="" hint="I am the twitter value." />
  <cfset variables.instance.twitter = ARGUMENTS.twitter />
</cffunction>

<cffunction name="setShowTwitter" access="public" output="false" hint="I set the showTwitter value into the variables.instance scope.">
  <cfargument name="showTwitter" type="string" required="true" default="" hint="I am the showTwitter value." />
  <cfset variables.instance.showTwitter = ARGUMENTS.showTwitter />
</cffunction>

<cffunction name="setBlog" access="public" output="false" hint="I set the blog value into the variables.instance scope.">
  <cfargument name="blog" type="string" required="true" default="" hint="I am the blog value." />
  <cfset variables.instance.blog = ARGUMENTS.blog />
</cffunction>

<cffunction name="setBio" access="public" output="false" hint="I set the bio value into the variables.instance scope.">
  <cfargument name="bio" type="string" required="true" default="" hint="I am the bio value." />
  <cfset variables.instance.bio = ARGUMENTS.bio />
</cffunction>

<cffunction name="setSpecialties" access="public" output="false" hint="I set the specialties value into the variables.instance scope.">
  <cfargument name="specialties" type="string" required="true" default="" hint="I am the specialties value." />
  <cfset variables.instance.specialties = ARGUMENTS.specialties />
</cffunction>

<cffunction name="setLocations" access="public" output="false" hint="I set the locations value into the variables.instance scope.">
  <cfargument name="locations" type="string" required="true" default="" hint="I am the locations value." />
  <cfset variables.instance.locations = ARGUMENTS.locations />
</cffunction>

<cffunction name="setMajorCity" access="public" output="false" hint="I set the majorCity value into the variables.instance scope.">
  <cfargument name="majorCity" type="string" required="true" default="" hint="I am the majorCity value." />
  <cfset variables.instance.majorCity = ARGUMENTS.majorCity />
</cffunction>

<cffunction name="setIsOnline" access="public" output="false" hint="I set the isOnline value into the variables.instance scope.">
  <cfargument name="isOnline" type="string" required="true" default="" hint="I am the isOnline value." />
  <cfset variables.instance.isOnline = ARGUMENTS.isOnline />
</cffunction>

<cffunction name="setIsACP" access="public" output="false" hint="I set the isACP value into the variables.instance scope.">
  <cfargument name="isACP" type="string" required="true" default="" hint="I am the isACP value." />
  <cfset variables.instance.isACP = ARGUMENTS.isACP />
</cffunction>

<cffunction name="setIsAEL" access="public" output="false" hint="I set the isAEL value into the variables.instance scope.">
  <cfargument name="isAEL" type="string" required="true" default="" hint="I am the isAEL value." />
  <cfset variables.instance.isAEL = ARGUMENTS.isAEL />
</cffunction>

<cffunction name="setIsAET" access="public" output="false" hint="I set the isAET value into the variables.instance scope.">
  <cfargument name="isAET" type="string" required="true" default="" hint="I am the isAET value." />
  <cfset variables.instance.isAET = ARGUMENTS.isAET />
</cffunction>

<cffunction name="setIsACL" access="public" output="false" hint="I set the isACL value into the variables.instance scope.">
  <cfargument name="isACL" type="string" required="true" default="" hint="I am the isACL value." />
  <cfset variables.instance.isACL = ARGUMENTS.isACL />
</cffunction>

<cffunction name="setIsUGM" access="public" output="false" hint="I set the isUGM value into the variables.instance scope.">
  <cfargument name="isUGM" type="string" required="true" default="" hint="I am the isUGM value." />
  <cfset variables.instance.isUGM = ARGUMENTS.isUGM />
</cffunction>

<cffunction name="setIsOther" access="public" output="false" hint="I set the isOther value into the variables.instance scope.">
  <cfargument name="isOther" type="string" required="true" default="" hint="I am the isOther value." />
  <cfset variables.instance.isOther = ARGUMENTS.isOther />
</cffunction>

<!--- GETTERS --->
<cffunction name="getSpeakerId" access="public" output="false" returntype="string" hint="I return the speakerId value.">
  <cfreturn variables.instance.speakerId />
</cffunction>

<cffunction name="getSpeakerKey" access="public" output="false" returntype="string" hint="I return the speakerKey value.">
  <cfreturn variables.instance.speakerKey />
</cffunction>

<cffunction name="getUserId" access="public" output="false" returntype="string" hint="I return the userId value.">
  <cfreturn variables.instance.userId />
</cffunction>

<cffunction name="getFirstName" access="public" output="false" returntype="string" hint="I return the firstName value.">
  <cfreturn variables.instance.firstName />
</cffunction>

<cffunction name="getLastName" access="public" output="false" returntype="string" hint="I return the lastName value.">
  <cfreturn variables.instance.lastName />
</cffunction>

<cffunction name="getEmail" access="public" output="false" returntype="string" hint="I return the email value.">
  <cfreturn variables.instance.email />
</cffunction>

<cffunction name="getPhone" access="public" output="false" returntype="string" hint="I return the phone value.">
  <cfreturn variables.instance.phone />
</cffunction>

<cffunction name="getShowPhone" access="public" output="false" returntype="string" hint="I return the showPhone value.">
  <cfreturn variables.instance.showPhone />
</cffunction>

<cffunction name="getTwitter" access="public" output="false" returntype="string" hint="I return the twitter value.">
  <cfreturn variables.instance.twitter />
</cffunction>

<cffunction name="getShowTwitter" access="public" output="false" returntype="string" hint="I return the showTwitter value.">
  <cfreturn variables.instance.showTwitter />
</cffunction>

<cffunction name="getBlog" access="public" output="false" returntype="string" hint="I return the blog value.">
  <cfreturn variables.instance.blog />
</cffunction>

<cffunction name="getBio" access="public" output="false" returntype="string" hint="I return the bio value.">
  <cfreturn variables.instance.bio />
</cffunction>

<cffunction name="getSpecialties" access="public" output="false" returntype="string" hint="I return the specialties value.">
  <cfreturn variables.instance.specialties />
</cffunction>

<cffunction name="getLocations" access="public" output="false" returntype="string" hint="I return the locations value.">
  <cfreturn variables.instance.locations />
</cffunction>

<cffunction name="getMajorCity" access="public" output="false" returntype="string" hint="I return the majorCity value.">
  <cfreturn variables.instance.majorCity />
</cffunction>

<cffunction name="getIsOnline" access="public" output="false" returntype="string" hint="I return the isOnline value.">
  <cfreturn variables.instance.isOnline />
</cffunction>

<cffunction name="getIsACP" access="public" output="false" returntype="string" hint="I return the isACP value.">
  <cfreturn variables.instance.isACP />
</cffunction>

<cffunction name="getIsAEL" access="public" output="false" returntype="string" hint="I return the isAEL value.">
  <cfreturn variables.instance.isAEL />
</cffunction>

<cffunction name="getIsAET" access="public" output="false" returntype="string" hint="I return the isAET value.">
  <cfreturn variables.instance.isAET />
</cffunction>

<cffunction name="getIsACL" access="public" output="false" returntype="string" hint="I return the isACL value.">
  <cfreturn variables.instance.isACL />
</cffunction>

<cffunction name="getIsUGM" access="public" output="false" returntype="string" hint="I return the isUGM value.">
  <cfreturn variables.instance.isUGM />
</cffunction>

<cffunction name="getIsOther" access="public" output="false" returntype="string" hint="I return the isOther value.">
  <cfreturn variables.instance.isOther />
</cffunction>

<!--- UTILITY METHODS --->
<cffunction name="getMemento" access="public" output="false" hint="I return a struct of the variables.instance scope.">
  <cfreturn variables.instance />
</cffunction>
</cfcomponent>
