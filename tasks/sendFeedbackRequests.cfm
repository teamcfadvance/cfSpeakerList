<!--- get active, accepted requests from ( today minus APPLICATION.daysToFeedbackRequest ) --->
<cfset qGetActiveRequests = APPLICATION.speakerRequestGateway.filter(
	eventDate 	= DateAdd( 'd', APPLICATION.daysToFeedbackRequest, Now() ),
	isAccepted	= true,
	isActive	= true
) />

<!--- loop through ( today minus APPLICATION.daysToFeedbackRequest ) events and send feedback request email(s) --->
<cfloop query="qGetActiveRequests">

	<!--- get a speaker object for this request --->
	<cfset speakerObj = APPLICATION.speakerDAO.getSpeakerById( qGetActiveRequests.speakerId ) />

	<!--- check if the system sends speaker feedback requests --->
	<cfif APPLICATION.sendSpeakerFeedbackRequests>
	
		<!--- get a speaker feedback object for this speaker request --->
		<cfset speakerFeedbackObj = APPLICATION.speakerFeedbackDAO.getSpeakerFeedbackByRequestId( qGetActiveRequests.speakerRequestId ) />

		<!--- check if a speaker feedback has already been done --->
		<cfif NOT len( speakerFeedbackObj.getSpeakerFeedbackId() ) OR NOT speakerFeedbackObj.getSpeakerFeedbackId()>

			<!--- speaker request is not done, send speaker feedback request email --->
			<cfmail to="#APPLICATION.utils.dataDec( qGetActiveRequests.email )#" from="#APPLICATION.fromEmail#" subject="#APPLICATION.siteName# Speaker Feedback Request" bcc="#APPLICATION.bccEmail#" charset="utf-8">
			 <cfmailpart type="html">
			 	<h4>#APPLICATION.siteName# Speaker Feedback Request</h4>
				<p>Thank you for using #APPLICATION.siteName# to request #speakerObj.getFirstName()# #speakerObj.getLastName()# for your #qGetActiveRequests.eventName# event given at #qGetActiveRequests.venue# on #DateFormat( qGetActiveRequests.eventDate, 'mm/dd/yyyy' )# at #qGetActiveRequests.eventTime#.</p>
				<p>To ensure our speakers are high quality, we send out this feedback request #APPLICATION.daysToFeedbackRequest# days after the event and ask that you give us feedback about #speakerObj.getFirstName()# #speakerObj.getLastName()#. It only takes a couple minutes to rate the speaker with one to five stars, and an optional review. Please click the link below to get started!</p>
				<p><a href="http://#CGI.HTTP_HOST#/speaker_review.cfm/#APPLICATION.utils.dataEnc( qGetActiveRequests.speakerRequestId, 'url' )#">http://#CGI.HTTP_HOST#/speaker_review.cfm/#APPLICATION.utils.dataEnc( qGetActiveRequests.speakerRequestId, 'url' )#</a></p>
				<p>&nbsp;</p>
				<p>Sincerely,<br />The #APPLICATION.siteName# Team</p>
			 </cfmailpart>
			 <cfmailpart type="plain">
				#APPLICATION.siteName# Speaker Feedback Request#cR##cR#
				Thank you for using #APPLICATION.siteName# to request #speakerObj.getFirstName()# #speakerObj.getLastName()##cR#
				for your #qGetActiveRequests.eventName# event given at #qGetActiveRequests.venue# on #DateFormat( qGetActiveRequests.eventDate, 'mm/dd/yyyy' )# at #qGetActiveRequests.eventTime#.#cR##cR#
				To ensure our speakers are high quality, we send out this feedback request #APPLICATION.daysToFeedbackRequest# days#cR#
				after the event and ask that you give us feedback about #speakerObj.getFirstName()# #speakerObj.getLastName()#.#cR#
				It only takes a couple minutes to rate the speaker with one to five stars, and an optional review.#cR#
				Please click the link below to get started!#cR##cR#
				http://#CGI.HTTP_HOST#/speaker_review.cfm/#APPLICATION.utils.dataEnc( qGetActiveRequests.speakerRequestId, 'url' )##cR##cR#
				Sincerely,#cR#
				The #APPLICATION.siteName# Team#cR##cR#
			 </cfmailpart>
			</cfmail>	

		<!--- end checking if a speaker feedback has already been done --->
		</cfif>
	
	<!--- end checking if the system sends speaker feedback requests --->	
	</cfif>

	<!--- check if the system sends event feedback requests --->
	<cfif APPLICATION.sendEventFeedbackRequests>
	
		<!--- get an event feedback object for this speaker request --->
		<cfset eventFeedbackObj = APPLICATION.eventFeedbackDAO.getEventFeedbackByRequestId( qGetActiveRequests.speakerRequestId ) />

		<!--- check if an event feedback has already been done --->
		<cfif NOT len( eventFeedbackObj.getEventFeedbackId() ) OR NOT eventFeedbackObj.getEventFeedbackId()>

			<!--- speaker request is not done, send speaker feedback request email --->
			<cfmail to="#speakerObj.getEmail()#" from="#APPLICATION.fromEmail#" subject="#APPLICATION.siteName# Event Feedback Request" bcc="#APPLICATION.bccEmail#" charset="utf-8">
			 <cfmailpart type="html">
			 	<h4>#APPLICATION.siteName# Event Feedback Request</h4>
				<p>Thank you for publishing your speaker details on #APPLICATION.siteName# and acceptiong the request from #APPLICATION.utils.dataDec( qGetActiveRequests.requestedBy )# to present for the #qGetActiveRequests.eventName# event given at #qGetActiveRequests.venue# on #DateFormat( qGetActiveRequests.eventDate, 'mm/dd/yyyy' )# at #qGetActiveRequests.eventTime#.</p>
				<p>To ensure events and venues are high quality, we send out this feedback request #APPLICATION.daysToFeedbackRequest# days after the event and ask that you give us feedback about the #qGetActiveRequests.eventName# event given at #qGetActiveRequests.venue#. It only takes a couple minutes to rate the event with one to five stars, and an optional review. Please click the link below to get started!</p>
				<p><a href="http://#CGI.HTTP_HOST#/event_review.cfm/#APPLICATION.utils.dataEnc( qGetActiveRequests.speakerRequestId, 'url' )#">http://#CGI.HTTP_HOST#/event_review.cfm/#APPLICATION.utils.dataEnc( qGetActiveRequests.speakerRequestId, 'url' )#</a></p>
				<p>&nbsp;</p>
				<p>Sincerely,<br />The #APPLICATION.siteName# Team</p>
			 </cfmailpart>
			 <cfmailpart type="plain">
				#APPLICATION.siteName# Speaker Feedback Request#cR##cR#
				Thank you for publishing your speaker details on #APPLICATION.siteName# and acceptiong the request from #APPLICATION.utils.dataDec( qGetActiveRequests.requestedBy )##cR#
				to present for the #qGetActiveRequests.eventName# event given at #qGetActiveRequests.venue# on #DateFormat( qGetActiveRequests.eventDate, 'mm/dd/yyyy' )# at #qGetActiveRequests.eventTime#.#cR##cR#
				To ensure events and venues are high quality, we send out this feedback request #APPLICATION.daysToFeedbackRequest# days#cR#
				after the event and ask that you give us feedback about the #qGetActiveRequests.eventName# event given at #qGetActiveRequests.venue#.#cR#
				It only takes a couple minutes to rate the event with one to five stars, and an optional review.#cR#
				Please click the link below to get started!#cR##cR#
				http://#CGI.HTTP_HOST#/event_review.cfm/#APPLICATION.utils.dataEnc( qGetActiveRequests.speakerRequestId, 'url' )##cR##cR#
				Sincerely,#cR#
				The #APPLICATION.siteName# Team#cR##cR#
			 </cfmailpart>
			</cfmail>	

		<!--- end checking if an event feedback has already been done --->
		</cfif>
	
	<!--- end checking if the system sends event feedback requests --->	
	</cfif>

<!--- end looping through ( today minus APPLICATION.daysToFeedbackRequest ) events and send feedback request email(s) --->
</cfloop>