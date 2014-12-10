<!--- COMPONENT ---><cfcomponent displayname="SpeakerFeedbackDAO" output="false" hint="I am the SpeakerFeedbackDAO class."><!--- Pseudo-constructor ---><cfset variables.instance = {	datasource = ''} /><cffunction name="init" access="public" output="false" returntype="any" hint="I am the constructor method of the SpeakerFeedbackDAO class.">  <cfargument name="datasource" type="any" required="true" hint="I am the Datasource bean." />  <!--- Set the initial values of the Bean --->  <cfscript>	variables.instance.datasource = arguments.datasource;  </cfscript>  <cfreturn this></cffunction><!--- PUBLIC METHODS ---><!--- CREATE ---><cffunction name="createNewSpeakerFeedback" access="public" output="false" returntype="numeric" hint="I insert a new speakerFeedback record into the speaker_feedback table in the database.">  <cfargument name="speakerFeedback" type="any" required="true" hint="I am the SpeakerFeedback bean." />  <cfset var qPutSpeakerFeedback = '' />  <cfset var insertResult = '' />  <cftry>  <cfquery name="qPutSpeakerFeedback" datasource="#variables.instance.datasource.getDSN()#" username="#variables.instance.datasource.getUsername()#" password="#variables.instance.datasource.getPassword()#" result="insertResult">	INSERT INTO speaker_feedback		(		  speakerId,		  speakerRequestId,		  punctuality,		  preparedness,		  knowledge,		  quality,		  satisfaction,		  recommend,		  review		) VALUES (		  <cfqueryparam value="#ARGUMENTS.speakerFeedback.getSpeakerId()#" cfsqltype="cf_sql_integer" />,		  <cfqueryparam value="#ARGUMENTS.speakerFeedback.getSpeakerRequestId()#" cfsqltype="cf_sql_integer" />,		  <cfqueryparam value="#ARGUMENTS.speakerFeedback.getPunctuality()#" cfsqltype="cf_sql_tinyint" />,		  <cfqueryparam value="#ARGUMENTS.speakerFeedback.getPreparedness()#" cfsqltype="cf_sql_tinyint" />,		  <cfqueryparam value="#ARGUMENTS.speakerFeedback.getKnowledge()#" cfsqltype="cf_sql_tinyint" />,		  <cfqueryparam value="#ARGUMENTS.speakerFeedback.getQuality()#" cfsqltype="cf_sql_tinyint" />,		  <cfqueryparam value="#ARGUMENTS.speakerFeedback.getSatisfaction()#" cfsqltype="cf_sql_tinyint" />,		  <cfqueryparam value="#ARGUMENTS.speakerFeedback.getRecommend()#" cfsqltype="cf_sql_tinyint" />,		  <cfqueryparam value="#ARGUMENTS.speakerFeedback.getReview()#" cfsqltype="cf_sql_longvarchar" />		)  </cfquery>  <!--- catch any errors --->  <cfcatch type="any">	<cfset APPLICATION.utils.errorHandler(cfcatch) />	<cfreturn 0 />  </cfcatch>  </cftry>  <!--- return the id generated by the database ---><cfreturn insertResult.GENERATED_KEY /></cffunction><!--- RETRIEVE - BY ID ---><cffunction name="getSpeakerFeedbackById" access="public" output="false" returntype="any" hint="I return a SpeakerFeedback bean populated with the details of a specific speakerFeedback record.">  <cfargument name="id" type="numeric" required="true" hint="I am the numeric auto-increment id of the speakerFeedback to search for." />  <cfset var qGetSpeakerFeedback = '' />  <cfset var speakerFeedbackObject = '' />  <cftry>  <cfquery name="qGetSpeakerFeedback" datasource="#variables.instance.datasource.getDSN()#" username="#variables.instance.datasource.getUsername()#" password="#variables.instance.datasource.getPassword()#">	SELECT speakerFeedbackId, speakerId, speakerRequestId, punctuality, preparedness, knowledge, quality, satisfaction, recommend, review	FROM speaker_feedback	WHERE speakerFeedbackId = <cfqueryparam value="#ARGUMENTS.id#" cfsqltype="cf_sql_integer" />  </cfquery>  <!--- catch any errors --->  <cfcatch type="any">	<cfset APPLICATION.utils.errorHandler(cfcatch) />	<cfreturn createObject('component','core.beans.SpeakerFeedback').init() />  </cfcatch>  </cftry>  <cfif qGetSpeakerFeedback.RecordCount>    <cfreturn createObject('component','core.beans.SpeakerFeedback').init(	speakerFeedbackId	= qGetSpeakerFeedback.speakerFeedbackId,	speakerId        	= qGetSpeakerFeedback.speakerId,	speakerRequestId 	= qGetSpeakerFeedback.speakerRequestId,	punctuality      	= qGetSpeakerFeedback.punctuality,	preparedness     	= qGetSpeakerFeedback.preparedness,	knowledge        	= qGetSpeakerFeedback.knowledge,	quality          	= qGetSpeakerFeedback.quality,	satisfaction     	= qGetSpeakerFeedback.satisfaction,	recommend        	= qGetSpeakerFeedback.recommend,	review           	= qGetSpeakerFeedback.review    ) />  <cfelse>    <cfreturn createObject('component','core.beans.SpeakerFeedback').init() />  </cfif></cffunction><!--- RETRIEVE - BY REQUEST ID ---><cffunction name="getSpeakerFeedbackByRequestId" access="public" output="false" returntype="any" hint="I return a SpeakerFeedback bean populated with the details of a specific speakerFeedback record.">  <cfargument name="id" type="numeric" required="true" hint="I am the numeric request id of the speakerFeedback to search for." />  <cfset var qGetSpeakerFeedback = '' />  <cfset var speakerFeedbackObject = '' />  <cftry>  <cfquery name="qGetSpeakerFeedback" datasource="#variables.instance.datasource.getDSN()#" username="#variables.instance.datasource.getUsername()#" password="#variables.instance.datasource.getPassword()#">	SELECT speakerFeedbackId, speakerId, speakerRequestId, punctuality, preparedness, knowledge, quality, satisfaction, recommend, review	FROM speaker_feedback	WHERE speakerRequestId = <cfqueryparam value="#ARGUMENTS.id#" cfsqltype="cf_sql_integer" />  </cfquery>  <!--- catch any errors --->  <cfcatch type="any">	<cfset APPLICATION.utils.errorHandler(cfcatch) />	<cfreturn createObject('component','core.beans.SpeakerFeedback').init() />  </cfcatch>  </cftry>  <cfif qGetSpeakerFeedback.RecordCount>    <cfreturn createObject('component','core.beans.SpeakerFeedback').init(	speakerFeedbackId	= qGetSpeakerFeedback.speakerFeedbackId,	speakerId        	= qGetSpeakerFeedback.speakerId,	speakerRequestId 	= qGetSpeakerFeedback.speakerRequestId,	punctuality      	= qGetSpeakerFeedback.punctuality,	preparedness     	= qGetSpeakerFeedback.preparedness,	knowledge        	= qGetSpeakerFeedback.knowledge,	quality          	= qGetSpeakerFeedback.quality,	satisfaction     	= qGetSpeakerFeedback.satisfaction,	recommend        	= qGetSpeakerFeedback.recommend,	review           	= qGetSpeakerFeedback.review    ) />  <cfelse>    <cfreturn createObject('component','core.beans.SpeakerFeedback').init() />  </cfif></cffunction><!--- UPDATE ---><cffunction name="updateSpeakerFeedback" access="public" output="false" returntype="numeric" hint="I update this speakerFeedback record in the speaker_feedback table of the database.">  <cfargument name="speakerFeedback" type="any" required="true" hint="I am the SpeakerFeedback bean." />  <cfset var qUpdSpeakerFeedback = '' />  <cftry>  <cfquery name="qUpdSpeakerFeedback" datasource="#variables.instance.datasource.getDSN()#" username="#variables.instance.datasource.getUsername()#" password="#variables.instance.datasource.getPassword()#">	UPDATE speaker_feedback SET	  speakerId = <cfqueryparam value="#ARGUMENTS.speakerFeedback.getSpeakerId()#" cfsqltype="cf_sql_int" />,	  speakerRequestId = <cfqueryparam value="#ARGUMENTS.speakerFeedback.getSpeakerRequestId()#" cfsqltype="cf_sql_int" />,	  punctuality = <cfqueryparam value="#ARGUMENTS.speakerFeedback.getPunctuality()#" cfsqltype="cf_sql_tinyint" />,	  preparedness = <cfqueryparam value="#ARGUMENTS.speakerFeedback.getPreparedness()#" cfsqltype="cf_sql_tinyint" />,	  knowledge = <cfqueryparam value="#ARGUMENTS.speakerFeedback.getKnowledge()#" cfsqltype="cf_sql_tinyint" />,	  quality = <cfqueryparam value="#ARGUMENTS.speakerFeedback.getQuality()#" cfsqltype="cf_sql_tinyint" />,	  satisfaction = <cfqueryparam value="#ARGUMENTS.speakerFeedback.getSatisfaction()#" cfsqltype="cf_sql_tinyint" />,	  recommend = <cfqueryparam value="#ARGUMENTS.speakerFeedback.getRecommend()#" cfsqltype="cf_sql_tinyint" />,	  review = <cfqueryparam value="#ARGUMENTS.speakerFeedback.getReview()#" cfsqltype="cf_sql_longvarchar" />	WHERE speakerFeedbackId = <cfqueryparam value="#ARGUMENTS.speakerFeedback.getSpeakerFeedbackId()#" cfsqltype="cf_sql_integer" />  </cfquery>  <!--- catch any errors --->  <cfcatch type="any">	<cfset APPLICATION.utils.errorHandler(cfcatch) />	<cfreturn 0 />  </cfcatch>  </cftry>  <cfreturn ARGUMENTS.speakerFeedback.getSpeakerFeedbackId() /></cffunction><!--- DELETE ---><cffunction name="deleteSpeakerFeedbackByID" access="public" output="false" returntype="boolean" hint="I delete a speakerFeedback from speakerFeedback table in the database.">  <cfargument name="id" type="numeric" required="true" hint="I am the numeric auto-increment id of the speakerFeedback to delete." />  <cfset var qDelSpeakerFeedback = '' />  <cftry>    <cfquery name="qDelSpeakerFeedback" datasource="#variables.instance.datasource.getDSN()#" username="#variables.instance.datasource.getUsername()#" password="#variables.instance.datasource.getPassword()#">		DELETE FROM speaker_feedback		WHERE speakerFeedbackId = <cfqueryparam value="#ARGUMENTS.id#" cfsqltype="cf_sql_integer" />	</cfquery>    <cfcatch type="database">      <cfreturn false />    </cfcatch>  </cftry>  <cfreturn true /></cffunction><!--- UTILITY FUNCTIONS ---><!--- SAVE ---><cffunction name="saveSpeakerFeedback" access="public" output="false" returntype="any" hint="I handle saving a speakerFeedback either by creating a new entry or updating an existing one.">  <cfargument name="speakerFeedback" type="any" required="true" hint="I am the SpeakerFeedback bean." />  <cfif exists(ARGUMENTS.speakerFeedback)>	<cfreturn updateSpeakerFeedback(ARGUMENTS.speakerFeedback) />  <cfelse>	<cfreturn createNewSpeakerFeedback(ARGUMENTS.speakerFeedback) />  </cfif></cffunction><!--- EXISTS ---><cffunction name="exists" access="private" output="false" returntype="boolean" hint="I check to see if a specific SpeakerFeedback is in the database, using ID as the check.">  <cfargument name="speakerFeedback" type="any" required="true" hint="I am the SpeakerFeedback bean." />  <cfset var qGetSpeakerFeedback = '' />  <cfquery name="qGetSpeakerFeedback" datasource="#variables.instance.datasource.getDSN()#" username="#variables.instance.datasource.getUsername()#" password="#variables.instance.datasource.getPassword()#">	SELECT speakerFeedbackId FROM speaker_feedback	WHERE speakerFeedbackId = <cfqueryparam value="#ARGUMENTS.speakerFeedback.getSpeakerFeedbackId()#" cfsqltype="cf_sql_integer" />  </cfquery>  <cfif qGetSpeakerFeedback.RecordCount>	<cfreturn true />  <cfelse>	<cfreturn false />  </cfif></cffunction></cfcomponent>