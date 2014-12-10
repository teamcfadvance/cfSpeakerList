<cfparam name="FORM['ff' & Hash('speakerRequestId','SHA-384')]" default="#APPLICATION.formZero#" type="string" />
<cfparam name="FORM['ff' & Hash('reviewType','SHA-384')]" default="#APPLICATION.formZero#" type="string" />
<cfparam name="FORM.punctuality" default="" type="string" />
<cfparam name="FORM.preparedness" default="" type="string" />
<cfparam name="FORM.knowledge" default="" type="string" />
<cfparam name="FORM.quality" default="" type="string" />
<cfparam name="FORM.satisfaction" default="" type="string" />
<cfparam name="FORM.recommend" default="" type="string" />
<cfparam name="FORM.venueQuality" default="" type="string" />
<cfparam name="FORM.difficulty" default="" type="string" />
<cfparam name="FOPM.avQuality" default="" type="string" />
<cfparam name="FORM.applicability" default="" type="string" />
<cfparam name="FORM.review" default="" type="string" />
<cfparam name="FORM['ff' & Hash('capcha')]" default="#APPLICATION.formZero#" type="string" />

<!--- make sure the form was submitted from this website --->
<cfif NOT APPLICATION.utils.checkReferer( CGI.HTTP_HOST, CGI.HTTP_REFERER )>
	<!--- it wasn't, redirect back to the index --->
	<cflocation url="index.cfm" />
</cfif>

<!--- set a null error message to check for later --->
<cfset errorMsg = '' />

<!--- check if the form was submitted --->
<cfif IsDefined('FORM.btn_Submit')>

	<!--- it was, sanitize the form values --->
	<cfset saniForm = APPLICATION.utils.sanitize(FORM) />

	<!--- get the speakerRequest --->
	<cfset speakerRequestObj = APPLICATION.speakerRequestDAO.getSpeakerRequestById( APPLICATION.utils.dataDec( FORM['ff' & Hash('speakerRequestId','SHA-384')], 'form' ) ) />

	<!--- ensure the speaker request object exists --->
	<cfif NOT Len( speakerRequestObj.getSpeakerRequestId() )>
		<!--- it doesn't, redirect back to the index --->
		<cflocation url="index.cfm" />		
	</cfif>

	<!--- get the reviewType --->
	<cfset reviewType = APPLICATION.utils.dataDec( FORM['ff' & Hash('reviewType','SHA-384')], 'form' ) />

	<!--- check if the review type is valid --->
	<cfif reviewType EQ 0>
		<!--- it isn't, redirect back to the index --->
		<cflocation url="index.cfm" />		
	</cfif>

	<!--- set a displayable value for the review type --->
	<cfset displayReviewType = UCase( Left( reviewType, 1) ) & Right( reviewType, len( reviewType) - 1 ) />

	<!--- check if the review type is 'speaker' and speaker feedback requests are enabled --->
	<cfif FindNoCase( 'speaker', reviewType ) AND APPLICATION.sendSpeakerFeedbackRequests>

		<!--- process required fields for speaker review --->
		<cfset reqCheck = APPLICATION.utils.checkRequired(
			fields = {
				punctuality 	= saniForm.punctuality,
				preparedness 	= saniForm.preparedness,
				knowledge 		= saniForm.knowledge,
				quality 		= saniForm.quality,
				satisfaction 	= saniForm.satisfaction,
				recommend 		= saniForm.recommend,
				review			= saniForm.review
			}
		) />

	<!--- otherwise , check if the review type is 'event' and event feedback requests are enabled --->
	<cfelseif FindNoCase( 'event', reviewType ) AND APPLICATION.sendEventFeedbackRequests>



		<!--- process required fields for event review --->
		<cfset reqCheck = APPLICATION.utils.checkRequired(
			fields = {
				venueQuality 	= saniForm.venueQuality,
				difficulty 		= saniForm.difficulty,
				avQuality 		= saniForm.avQuality,
				applicability	= saniForm.applicability,
				recommend 		= saniForm.recommend,
				review			= saniForm.review
			}
		) />

	<!--- otherwise --->
	<cfelse>

		<!--- neither review type was specified or neither review type is permitted, redirect to index --->
		<cflocation url="index.cfm" />

	</cfif>
	
	<!--- check if the required fields were not provided --->
	<cfif NOT reqCheck.result>
		<!--- some fields not provided, set an error message to display --->
		<cfset errorMsg = '<p>We&apos;re sorry, but the following fields are required but were not provided:</p><ul>' />
		<!--- loop through the missing fields --->
		<cfloop from="1" to="#ListLen(reqCheck.fields)#" index="iX">
			<!--- add this field as a list item --->
			<cfset errorMsg = errorMsg & '<li>#ListGetAt(reqCheck.fields,iX)#</li>' />
		</cfloop>
		<cfset errorMsg = errorMsg & '</ul>' />
	</cfif>
	
	<!--- verify the capcha is correct --->
	<cfif saniForm.capcha NEQ APPLICATION.utils.dataDec(saniForm['ff' & Hash('capcha')], 'form')>
		<!--- capcha mismatch, set an error message to display --->
		<cfset errorMsg = '<p>We&apos;re sorry, but you did not enter the correct sum of the two numbers. You may have added the numbers incorrectly, typo&apos;d the answer, or at worst... you may not be human. Please try again.</p>' />
	</cfif>	
	
	<!--- get the speaker object from the speaker request --->
	<cfset speakerObj = APPLICATION.speakerDAO.getSpeakerById( speakerRequestObj.getSpeakerId() ) />
	
	<!--- check if the speaker id provided returns a valid speaker --->
	<cfif NOT Len(speakerObj.getSpeakerId())>
		<!--- invalid speaker indicated, set an error message to display --->
		<cfset errorMsg = '<p>We&apos;re sorry, but we did not receive the values we expected in your request. Please try your request again.</p>' />
	</cfif>	
	
	<!--- ensure we have no errors --->
	<cfif NOT Len(errorMsg)>	

		<!--- we don't have any errors, check if the review type is 'speaker' --->
		<cfif FindNoCase( 'speaker', reviewType )>

			<!--- review type is 'speaker' --->
			<cfset speakerFeedbackObj = createObject('component','core.beans.SpeakerFeedback').init(
				speakerFeedbackId	= 0,
				speakerId        	= speakerObj.getSpeakerId(),
				speakerRequestId 	= speakerRequestObj.getSpeakerRequestId(),
				punctuality 		= saniForm.punctuality,
				preparedness 		= saniForm.preparedness,
				knowledge 			= saniForm.knowledge,
				quality 			= saniForm.quality,
				satisfaction 		= saniForm.satisfaction,
				recommend 			= saniForm.recommend,
				review				= saniForm.review
		    ) />

		    <cfset speakerFeedbackObj.setSpeakerFeedbackId( APPLICATION.speakerFeedbackDAO.saveSpeakerFeedback( speakerFeedbackObj ) ) />
	
		<!--- otherwise --->
		<cfelse>

			<!--- review type is 'event' --->
			<cfset eventFeedbackObj = createObject('component','core.beans.EventFeedback').init(
				eventFeedbackId 	= 0,
				speakerId        	= speakerObj.getSpeakerId(),
				speakerRequestId 	= speakerRequestObj.getSpeakerRequestId(),
				venueQuality    	= saniForm.venueQuality,
				difficulty      	= saniForm.difficulty,
				avQuality       	= saniForm.avQuality,
				applicability   	= saniForm.applicability,
				recommend       	= saniForm.recommend,
				review          	= saniForm.review
		    ) />

		    <cfset eventFeedbackObj.setEventFeedbackId( APPLICATION.eventFeedbackDAO.saveEventFeedback( eventFeedbackObj ) ) />

		<!--- end checking if the review type is 'speaker' --->
		</cfif>

		<!--- get a speaker feedback object for this speaker request id --->
		<cfset speakerFeedbackObj = APPLICATION.speakerFeedbackDAO.getSpeakerFeedbackByRequestId( speakerRequestObj.getSpeakerRequestId() ) />
		<!--- get an event feedback object for this speaker request id --->
		<cfset eventFeedbackObj = APPLICATION.eventFeedbackDAO.getEventFeedbackByRequestId( speakerRequestObj.getSpeakerRequestId() ) />

		<!--- check if both speaker and event feedback requests are enabled --->
		<cfif APPLICATION.sendSpeakerFeedbackRequests AND APPLICATION.sendEventFeedbackRequests>
			<!--- they are, check if both a speaker feedback and an event feedback have been completed --->
			<cfif len( speakerFeedbackObj.getSpeakerFeedbackId() ) AND len( eventFeedbackObj.getEventFeedbackId() )>
				<!--- they have, mark this request as inactive --->
				<cfset speakerRequestObj.setIsActive( false ) />				
			</cfif>
			<!--- check if the speaker feedback for punctuality indicates they completed the event --->
			<cfif len( speakerFeedbackObj.getPunctuality() ) AND speakerFeedbackObj.getPunctuality() GT 1>
				<!--- it does, mark the event complete --->
				<cfset speakerRequestObj.setIsCompleted( true ) />				
			</cfif>				
		<!--- otherwise, check if speaker feedback requests are enabled and speaker feedback has been completed --->
		<cfelseif APPLICATION.sendSpeakerFeedbackRequests AND len( speakerFeedbackObj.getSpeakerFeedbackId() )>
			<!--- they have, mark this request as inactive --->
			<cfset speakerRequestObj.setIsActive( false ) />
			<!--- check if the speaker feedback for punctuality indicates they completed the event --->
			<cfif len( speakerFeedbackObj.getPunctuality() ) AND speakerFeedbackObj.getPunctuality() GT 1>
				<!--- it does, mark the event complete --->
				<cfset speakerRequestObj.setIsCompleted( true ) />				
			</cfif>				
		<!--- otherwise, check if event feedback requests are enabled and event feedback has been completed --->
		<cfelseif APPLICATION.sendEventFeedbackRequests AND len ( eventFeedbackObj.getEventFeedbackId() )>
			<!--- they have, mark this request as inactive and complete --->
			<cfset speakerRequestObj.setIsActive( false ) />	
			<cfset speakerRequestObj.setIsCompleted( false ) />				
		</cfif>

		<!--- save the speaker request object --->
		<cfset APPLICATION.speakerRequestDAO.saveSpeakerRequest( speakerRequestObj ) />

	<!--- end ensuring we have no errors --->	
	</cfif>

<!--- otherwise --->
<cfelse>

	<!--- form not submitted, redirect back to the index --->
	<cflocation url="index.cfm" />		

<!--- end checking if the form was submitted --->	
</cfif>

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="shortcut icon" href="favicon.ico">

    <title><cfoutput>#APPLICATION.siteName#</cfoutput> &raquo; <cfoutput>#displayReviewType#</cfoutput> Review</title>

    <link href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css" rel="stylesheet">
    <link href="//cdn.vsgcom.net/css/jumbotron.css" rel="stylesheet">

    <!--- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries --->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
      <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>

  <body>

    <div class="navbar navbar-inverse navbar-fixed-top" role="navigation">
      <div class="container">
        <div class="navbar-header">
          <a class="navbar-brand" href="index.cfm"><cfoutput>#APPLICATION.siteLongName#</cfoutput></a> <span class="navbar-brand">&raquo; <cfoutput>#displayReviewType#</cfoutput> Review</span>
        </div>
      </div>
    </div>

	<br />

    <div class="container">
	  <div class="row">
        <div class="col-md-12">

	  		<cfif Len(errorMsg)>

			<div class="panel panel-danger">
			  <div class="panel-heading"><cfoutput>#displayReviewType#</cfoutput> Review Incomplete</div>
			  <div class="panel-body">
				<cfoutput>#errorMsg#</cfoutput>
			  </div>
			  <cfif Len( speakerRequestObj.getSpeakerRequestId() )>
			  <div class="panel-footer">
				<!--- we don't have any errors, check if the review type is 'speaker' --->
				

					<!--- it is, display speaker review link --->
				  	<cfoutput><a class="btn btn-info" href="<cfif FindNoCase( 'speaker', reviewType )>speaker<cfelse>event</cfif>_review.cfm/#APPLICATION.utils.dataEnc( speakerRequestObj.getSpeakerRequestId(), 'url' )#" role="button">Click here to try again</a></cfoutput>
			  </div>
			  </cfif>
			</div>
			
			<cfelse>
			
			<div class="panel panel-success">
			  <div class="panel-heading"><cfoutput>#displayReviewType#</cfoutput> Review Complete</div>
			  <div class="panel-body">
				<!--- we don't have any errors, check if the review type is 'speaker' --->
				<cfif FindNoCase( 'speaker', reviewType )>

					<!--- it is, display speaker review message --->
					<cfoutput><p>Congratulations! You have reviewed #speakerObj.getFirstName()# #speakerObj.getLastName()# for the #speakerRequestObj.getEventName()# event at #speakerRequestObj.getVenue()#. Thank you for taking the time to review this speaker and for using #APPLICATION.siteName# to contact speaker(s) for your event(s).</p></cfoutput>

				<!--- otherwise --->
				<cfelse>	

					<!--- it isn't, display event review message --->
					<cfoutput><p>Congratulations! You have reviewed the #speakerRequestObj.getEventName()# event at #speakerRequestObj.getVenue()#. Thank you for taking the time to review this venue/event and for using #APPLICATION.siteName# to publish your speaker information.</p></cfoutput>

				</cfif>
			  </div>
			</div>
			
			</cfif>	
	  
		</div>
	  </div>

      <hr>

      <cfinclude template="includes/footer.cfm" />
    </div> <!--- /container --->

    <script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
    <script src="//netdna.bootstrapcdn.com/bootstrap/3.3.1/js/bootstrap.min.js"></script>
  </body>
</html>
