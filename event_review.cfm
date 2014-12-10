<!--- check if the page was called without a speaker key in the path --->
<cfif CGI.PATH_INFO EQ CGI.SCRIPT_NAME OR NOT Len(CGI.PATH_INFO)>
	<!--- it was, redirect to the home page --->
	<cflocation url="index.cfm" addtoken="false" />
</cfif>

<cftry>

	<!--- set a variable to hold the decrypted request id --->
	<cfset decSpeakerRequestId = APPLICATION.utils.dataDec( ListGetAt(CGI.PATH_INFO,1,'/'), 'url' ) />

<cfcatch type="any">

	<!--- check if debug is on --->
	<cfif APPLICATION.debugOn>
		<!--- it is, dump debug data --->
		<cfdump var="#cfcatch#" />
		<cfabort />
	<!--- otherwise --->
	<cfelse>
		<!--- it isn't, redirect to index --->
		<cflocation url="../index.cfm" />		
	</cfif>

</cfcatch>
	
</cftry>


<!--- get a speaker object from the passed in path info (truncated to remove the /) --->
<cfset speakerRequestObj = APPLICATION.speakerRequestDAO.getSpeakerRequestById( decSpeakerRequestId ) />

<!--- check if the speaker object returned has a valid speaker request id --->
<cfif NOT Len(speakerRequestObj.getSpeakerRequestId())>
	<!--- invalid id passed, redirect to the home page --->
	<cflocation url="../index.cfm" addtoken="false" />
</cfif>

<!--- get a speaker review object for this request --->
<cfset eventFeedbackObj = APPLICATION.eventFeedbackDAO.getEventFeedbackByRequestId( speakerRequestObj.getSpeakerRequestId() ) />

<!--- check if this speaker has already received feedback on this request --->
<cfif Len(eventFeedbackObj.getEventFeedbackId()) OR eventFeedbackObj.getEventFeedbackId()>
	<!--- already reviewed, redirect to the home page --->
	<cflocation url="../index.cfm" addtoken="false" />	
</cfif>

<!--- get a speaker object from the speaker request object's speaker id --->
<cfset speakerObj = APPLICATION.speakerDAO.getSpeakerById( speakerRequestObj.getSpeakerId() ) />

<!--- check if the speaker object returned has a valid speaker id --->
<cfif NOT Len(speakerObj.getSpeakerId())>
	<!--- invalid key passed, redirect to the home page --->
	<cflocation url="../index.cfm" addtoken="false" />
</cfif>

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="shortcut icon" href="../favicon.ico">

    <title><cfoutput>#APPLICATION.siteName#</cfoutput> &raquo; Event Review</title>

    <link href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css" rel="stylesheet">
    <link href="//cdn.vsgcom.net/css/jumbotron.css" rel="stylesheet">
	<link href="//cdn.vsgcom.net/css/star-rating.min.css" rel="stylesheet">

    <!---- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries ---->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
      <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>

  <body>

    <div class="navbar navbar-inverse navbar-fixed-top" role="navigation">
      <div class="container">
        <div class="navbar-header">
          <a class="navbar-brand" href="../index.cfm"><cfoutput>#APPLICATION.siteLongName#</cfoutput></a> <span class="navbar-brand">&raquo; Event Review</span>
        </div>
      </div>
    </div>

	<br />

    <div class="container">
	  <div class="row">
        <div class="col-md-12">
			<div class="panel panel-primary">
			  <div class="panel-heading">General Information</div>
			
			  <table class="table">
				<tbody>
				<cfoutput>
				  <tr>
				    <td><strong>Requestor Name</strong></td>
					<td>#speakerRequestObj.getRequestedBy()#</td>
				  </tr>
				  <tr>
				    <td><strong>Reviewer Name</strong></td>
					<td>#speakerObj.getFirstName()# #speakerObj.getLastName()#</td>
				  </tr>
				  <tr>
				    <td><strong>Event Name</strong></td>
					<td>#speakerRequestObj.getEventName()#</td>
				  </tr>
				  <tr>
				    <td><strong>Venue/Location</strong></td>
					<td>#speakerRequestObj.getVenue()#</td>
				  </tr>
				</cfoutput>
				</tbody>
			  </table>

			</div><!---- /panel ---->

		  <br />
		  
		  <form class="form-horizontal" role="form" id="speaker-review" method="post" action="../do_review.cfm">
		  <cfoutput>
			<input type="hidden" name="ff#Hash('speakerRequestId','SHA-384')#" value="#APPLICATION.utils.dataEnc( speakerRequestObj.getSpeakerRequestId(), 'form' )#" />
			<input type="hidden" name="ff#Hash('reviewType','SHA-384')#" value="#APPLICATION.utils.dataEnc( 'event', 'form' )#" />
			#APPLICATION.utils.getRandomFormField()#
			<fieldset>
			
			<!--- Form Name --->
			<legend>Review Event &raquo; Leave Feedback</legend>
			
			<!--- Text input--->
			<div class="form-group">
			  <label class="col-md-4 control-label" for="venueQuality">Venue Quality</label>  
			  <div class="col-md-4">
			  <input id="venueQuality" name="venueQuality" type="number" class="rating" data-min="0" data-max="5" data-step="1" data-size="xs" data-stars="5" data-show-clear="false">
		  	  <span class="help-block">How was the quality of the venue/event you presented at?</span>  
			  </div>
			</div>
			
			<!--- Text input--->
			<div class="form-group">
			  <label class="col-md-4 control-label" for="difficulty">Difficulty</label>  
			  <div class="col-md-4">
			  <input id="difficulty" name="difficulty" type="number" class="rating" data-min="0" data-max="5" data-step="1" data-size="xs" data-stars="5" data-show-clear="false">
		  	  <span class="help-block">How difficult was it to find this venue/event?</span>  
			  </div>
			</div>
			
			<!--- Text input--->
			<div class="form-group">
			  <label class="col-md-4 control-label" for="avQuality">AV Quality</label>  
			  <div class="col-md-4">
			  <input id="avQuality" name="avQuality" type="number" class="rating" data-min="0" data-max="5" data-step="1" data-size="xs" data-stars="5" data-show-clear="false">
		  	  <span class="help-block">How was the quality of the Audio/Video equipment used by the venue?</span>  
			  </div>
			</div>
			
			<!--- Text input--->
			<div class="form-group">
			  <label class="col-md-4 control-label" for="applicability">Applicability</label>  
			  <div class="col-md-4">
			  <input id="applicability" name="applicability" type="number" class="rating" data-min="0" data-max="5" data-step="1" data-size="xs" data-stars="5" data-show-clear="false">
		  	  <span class="help-block">How applicable was the topic requested to the venue/event?</span>  
			  </div>
			</div>
			
			<!--- Text input--->
			<div class="form-group">
			  <label class="col-md-4 control-label" for="recommend">Recommend</label>  
			  <div class="col-md-4">
			  <input id="recommend" name="recommend" type="number" class="rating" data-min="0" data-max="5" data-step="1" data-size="xs" data-stars="5" data-show-clear="false">
		  	  <span class="help-block">Would you recommend this venue/event to others?</span>  
			  </div>
			</div>
		
			<!--- Textarea --->
			<div class="form-group">
			  <label class="col-md-4 control-label" for="review">Public Review (Optional)</label>
			  <div class="col-md-4">                     
				<textarea class="form-control" id="review" name="review"></textarea>
			  <span class="help-block">Enter your <strong>public</strong> comments about this venue and/or event.</span>  
			  </div>
			</div>
			
			
			<!---- generate a random number set to sum for use with human validation ---->
			<cfset firstNum = RandRange(1,16) />
			<cfset lastNum = RandRange(16,32) />
			<!---- calculate and encrypt the expected sum ---->
			<cfset sumNum = APPLICATION.utils.dataEnc(value = (firstNum + lastNum), mode = 'form') />
			<!--- Text input--->
			<div class="form-group">
			  <label class="col-md-4 control-label" for="capcha">What is #firstNum# + #lastNum#?</label>  
			  <div class="col-md-2">
				  <input id="capcha" name="capcha" placeholder="Add the two numbers" class="form-control input-md" required type="text">
				  <input type="hidden" name="ff#Hash('capcha')#" value="#sumNum#" />
			  </div>
			</div>
			
			<!--- Button (Double) --->
			<div class="form-group">
			  <label class="col-md-4 control-label" for="btn_Submit"></label>
			  <div class="col-md-8">
				<button type="submit" id="btn_Submit" name="btn_Submit" class="btn btn-success">Leave Event Feedback</button>
				<button type="reset" id="btn_Reset" name="btn_Reset" class="btn btn-danger">Clear Form</button>
			  </div>
			</div>
			
			</fieldset>
			</cfoutput>
			</form>	
		</div>
	  </div><!---- /row ---->

      <hr>

      <cfinclude template="includes/footer.cfm" />
    </div> <!---- /container ---->

    <script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
    <script src="//netdna.bootstrapcdn.com/bootstrap/3.3.1/js/bootstrap.min.js"></script>
	<script src="//cdn.vsgcom.net/js/star-rating.min.js"></script>
	<script type="text/javascript">
			
		$('#venueQuality').rating({
			starCaptions: {
				1: 'Very Poor',
				2: 'Poor',
				3: 'Fair',
				4: 'Good',
				5: 'Excellent'
			}
		});
		
		$('#difficulty').rating({
			starCaptions: {
				1: 'Could Not Find',
				2: 'Near Impossible',
				3: 'Difficult',
				4: 'Easy',
				5: 'Very Easy'
			}
		});
		
		$('#avQuality').rating({
			starCaptions: {
				1: 'Very Poor',
				2: 'Poor',
				3: 'Fair',
				4: 'Good',
				5: 'Excellent'
			}
		});
		
		$('#applicability').rating({
			starCaptions: {
				1: 'Very Poor',
				2: 'Poor',
				3: 'Fair',
				4: 'Good',
				5: 'Excellent'
			}
		});
					
		$('#recommend').rating({
			starCaptions: {
				1: 'Would Never Recommend',
				2: 'Might Not Reccomend',
				3: 'Might Recommend',
				4: 'Would Recommend',
				5: 'Absolutely Recommend'
			}
		});

	</script>
  </body>
</html>
