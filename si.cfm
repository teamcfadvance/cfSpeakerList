<!--- check if the page was called without a speaker key in the path --->
<cfif CGI.PATH_INFO EQ CGI.SCRIPT_NAME OR NOT Len(CGI.PATH_INFO)>
	<!--- it was, redirect to the home page --->
	<cflocation url="index.cfm" addtoken="false" />
</cfif>

<!--- get a speaker object from the passed in path info (truncated to remove the /) --->
<cfset speakerObj = APPLICATION.speakerDAO.getSpeakerByKey(ListGetAt(CGI.PATH_INFO,1,'/')) />

<!--- check if the speaker object returned has a valid speaker key --->
<cfif NOT Len(speakerObj.getSpeakerKey())>
	<!--- invalid key passed, redirect to the home page --->
	<cflocation url="../index.cfm" addtoken="false" />
</cfif>

<!--- check if speaker feedback is enabled --->
<cfif APPLICATION.sendSpeakerFeedbackRequests>

	<!--- it is, get speaker feedback for this speaker --->
	<cfset qGetSpeakerFeedback = APPLICATION.speakerFeedbackGateway.filter(
		speakerId = speakerObj.getSpeakerId()
	) />

	<!--- zero overall stars --->
	<cfset overallStars = 0 />

	<!--- check there is feedback to process --->
	<cfif qGetSpeakerFeedback.RecordCount>
		<!--- there is, get weighted average of all factors --->
		<cfset punctualityStars = Int( ArraySum( ListToArray( ValueList( qGetSpeakerFeedback.punctuality ) ) ) / qGetSpeakerFeedback.RecordCount ) />
		<cfif punctualityStars GT 5>
			<cfset punctualityStars = 5>
		</cfif>
		<cfif punctualityStars LT 0>
			<cfset punctualityStars = 0>
		</cfif>
		<cfset preparednessStars = Int( ArraySum( ListToArray( ValueList( qGetSpeakerFeedback.preparedness ) ) ) / qGetSpeakerFeedback.RecordCount ) />
		<cfif preparednessStars GT 5>
			<cfset preparednessStars = 5>
		</cfif>
		<cfif preparednessStars LT 0>
			<cfset preparednessStars = 0>
		</cfif>
		<cfset knowledgeStars = Int( ArraySum( ListToArray( ValueList( qGetSpeakerFeedback.knowledge ) ) ) / qGetSpeakerFeedback.RecordCount ) />
		<cfif knowledgeStars GT 5>
			<cfset knowledgeStars = 5>
		</cfif>
		<cfif knowledgeStars LT 0>
			<cfset knowledgeStars = 0>
		</cfif>
		<cfset qualityStars = Int( ArraySum( ListToArray( ValueList( qGetSpeakerFeedback.quality ) ) ) / qGetSpeakerFeedback.RecordCount ) />
		<cfif qualityStars GT 5>
			<cfset qualityStars = 5>
		</cfif>
		<cfif qualityStars LT 0>
			<cfset qualityStars = 0>
		</cfif>
		<cfset satisfactionStars = Int( ArraySum( ListToArray( ValueList( qGetSpeakerFeedback.punctuality ) ) ) / qGetSpeakerFeedback.RecordCount ) />
		<cfif satisfactionStars GT 5>
			<cfset satisfactionStars = 5>
		</cfif>
		<cfif satisfactionStars LT 0>
			<cfset satisfactionStars = 0>
		</cfif>
		<cfset recommendStars = Int( ArraySum( ListToArray( ValueList( qGetSpeakerFeedback.punctuality ) ) ) / qGetSpeakerFeedback.RecordCount ) />
		<cfif recommendStars GT 5>
			<cfset recommendStars = 5>
		</cfif>
		<cfif recommendStars LT 0>
			<cfset recommendStars = 0>
		</cfif>
		<cfset overallStars = Int( ( punctualityStars + preparednessStars + knowledgeStars + qualityStars + satisfactionStars + recommendStars ) / 6 ) />
		<cfif overallStars GT 5>
			<cfset overallStars = 5>
		</cfif>
		<cfif overallStars LT 0>
			<cfset overallStars = 0>
		</cfif>
	</cfif>
	
</cfif>

<!--- check if speaker request statistics are enabled --->
<cfif APPLICATION.showRequestStats>

	<!--- they are, get speaker requests --->
	<cfset qGetSpeakerRequests = APPLICATION.speakerRequestGateway.filter(
		speakerId = speakerObj.getSpeakerId()
	) />

	<!--- zero out total requests --->
	<cfset totalRequests = 0 />

	<!--- assign/compute values for statistics --->
	<cfif qGetSpeakerRequests.RecordCount>
		<cfset totalRequests = qGetSpeakerRequests.RecordCount />
		<cfset totalRequestsPercent = totalRequests * 10>
		<cfset totalAccepted = Int( ArraySum( ListToArray( ValueList( qGetSpeakerRequests.isAccepted ) ) ) ) />
		<cftry>
			<cfset totalAcceptedPercent = Int( ( totalAccepted / totalRequests ) * 100 ) />
		<cfcatch type="any">
			<cfset totalAcceptedPercent = 0 />
		</cfcatch>
		</cftry>
		<cfset totalCompleted = Int( ArraySum( ListToArray( ValueList( qGetSpeakerRequests.isCompleted ) ) ) ) />
		<cftry>
			<cfset totalCompletedPercent = Int( (totalCompleted / totalRequests ) * 100 ) />
		<cfcatch type="any">
			<cfset totalCompletedPercent = 0 />
		</cfcatch>
		</cftry>
	</cfif>
	
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

    <title><cfoutput>#APPLICATION.siteName#</cfoutput> &raquo; Speaker Information</title>

    <link href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css" rel="stylesheet">
    <link href="//cdn.vsgcom.net/css/jumbotron.css" rel="stylesheet">
	<link href="//cdn.vsgcom.net/css/datepicker.css" rel="stylesheet">
	<link href="//cdn.vsgcom.net/css/datepicker3.css" rel="stylesheet">
	<link href="//cdn.vsgcom.net/css/star-rating.min.css" rel="stylesheet">
	<link href="/cdn.vsgcom.net/css/jquery.easy-pie-chart.css" rel="stylesheet">

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
          <a class="navbar-brand" href="../index.cfm"><cfoutput>#APPLICATION.siteLongName#</cfoutput></a> <span class="navbar-brand">&raquo; Speaker Information</span>
        </div>
      </div>
    </div>

	<br />

    <div class="container">
	  <div class="row">
        <div class="col-md-12">
			<div class="panel panel-primary">
			  <div class="panel-heading">Speaker Information</div>
			
			  <table class="table">
				<tbody>
				<cfoutput>
				  <tr>
				    <td><strong>Speaker Gravatar</strong></td>
					<td><img src="http://www.gravatar.com/avatar/#lCase( hash( lCase( speakerObj.getEmail() ) ) )#?s=180&r=R&d=#UrlEncodedFormat('http://cdn.vsgcom.net/img/blank_profile_180px.png')#" /></td>
				  </tr>
				  <tr>
				    <td><strong>Speaker Name</strong></td>
					<td>#speakerObj.getFirstName()# #speakerObj.getLastName()#</td>
				  </tr>
				  <tr>
				    <td><strong>Specialties</strong></td>
					<td>#ListChangeDelims(speakerObj.getSpecialties(),', ')#</td>
				  </tr>
				  <tr>
				    <td><strong>Location(s)</strong></td>
					<td>#ListChangeDelims(speakerObj.getLocations(),', ')#</td>
				  </tr>
				  <tr>
				  	<td><strong>Presents Online</strong></td>
				  	<td><cfif speakerObj.getIsOnline()>Yes<cfelse>No</cfif></td>
				  </tr>
				  <tr>
				  	<td><strong>Closest Major City</strong></td>
				  	<td>#speakerObj.getMajorCity()#</td>
				  </tr>
				  <tr>
				    <td><strong>Biography</strong></td>
					<td width="80%">#APPLICATION.utils.decodeVal( speakerObj.getBio() )#</td>
				  </tr>
				  <tr>
				    <td><strong>Program(s)</strong></td>
					<td>
						<ul>
						<cfif speakerObj.getIsACP()><li>Adobe Community Professional (ACP)</li></cfif>
						<cfif speakerObj.getIsAEL()><li>Adobe Education Leader (AEL)</li></cfif>
						<cfif speakerObj.getIsAET()><li>Adobe Education Trainer (AET)</li></cfif>
						<cfif speakerObj.getIsACL()><li>Adobe Campus Leader (ACL)</li></cfif>
						<cfif speakerObj.getIsUGM()><li>Adobe User Group Manager (UGM)</li></cfif>
						<cfif speakerObj.getIsOther()><li>Other design/development program member</li></cfif>
						<cfif NOT speakerObj.getIsACP() AND NOT speakerObj.getIsAEL() AND NOT speakerObj.getIsUGM() AND NOT speakerObj.getIsOther() AND NOT speakerObj.getIsAET() AND NOT speakerObj.getIsACL()><li>Not in any program</li></cfif>
						</ul>
					</td>
				  </tr>
				  <tr>
				    <td><strong>Contact Details:</strong></td>
					<td>
						<ul>
						<cfif speakerObj.getShowPhone() AND Len(speakerObj.getPhone())><li>Phone: #APPLICATION.utils.formatPhone(speakerObj.getPhone())#</li></cfif>
						<cfif speakerObj.getShowTwitter() AND Len(speakerObj.getTwitter())><li>Twitter: <a href="https://twitter.com/#speakerObj.getTwitter()#" target="_blank">#speakerObj.getTwitter()#</a></li></cfif>
						<cfif (NOT speakerObj.getShowPhone() OR NOT Len(speakerObj.getPhone())) AND (NOT speakerObj.getShowTwitter() OR NOT Len(speakerObj.getTwitter()))><li>No details published, use contact form below</li></cfif>
						<cfif Len( speakerObj.getBlog() )><li>Website/Blog: <a href="#APPLICATION.utils.decodeVal( speakerObj.getBlog() )#" target="_blank">#speakerObj.getBlog()#</a></li></cfif>
						</ul>
					</td>
				  </tr>
				  <!--- check if speaker feedback is enabled --->
				  <cfif APPLICATION.sendSpeakerFeedbackRequests>
				  <tr>
				  	<td><strong>Feedback</strong></td>
				  	<td><cfif overallStars>
				  		<table style="font-size:.95em;">				  		
				  		<tr>
				  			<td><strong>Overall Rating:</strong></td>
				  			<td><input id="overall" type="number" class="rating" value="#overallStars#" data-size="xs" data-stars="5" data-disabled="true" data-show-clear="false"></td>
				  		</tr>
				  		<tr>
				  			<td><strong>Punctuality:</strong></td>
				  			<td><input id="punctuality" type="number" class="rating" value="#punctualityStars#" data-size="xs" data-stars="5" data-disabled="true" data-show-clear="false"></td>
				  		</tr>
				  		<tr>
				  			<td><strong>Preparedness:</strong></td>
				  			<td><input id="preparedness" type="number" class="rating" value="#preparednessStars#" data-size="xs" data-stars="5" data-disabled="true" data-show-clear="false"></td>
				  		</tr>
				  		<tr>
				  			<td><strong>Knowledge:</strong></td>
				  			<td><input id="knowledge" type="number" class="rating" value="#knowledgeStars#" data-size="xs" data-stars="5" data-disabled="true" data-show-clear="false"></td>
				  		</tr>
				  		<tr>
				  			<td><strong>Quality:</strong></td>
				  			<td><input id="quality" type="number" class="rating" value="#qualityStars#" data-size="xs" data-stars="5" data-disabled="true" data-show-clear="false"></td>
				  		</tr>
				  		<tr>
				  			<td><strong>Satisfaction:</strong></td>
				  			<td><input id="satisfaction" type="number" class="rating" value="#satisfactionStars#" data-size="xs" data-stars="5" data-disabled="true" data-show-clear="false"></td>
				  		</tr>
				  		<tr>
				  			<td><strong>Recommended:</strong></td>
				  			<td><input id="recommend" type="number" class="rating" value="#recommendStars#" data-size="xs" data-stars="5" data-disabled="true" data-show-clear="false"></td>
				  		</tr>
				  		<!---<tr>
				  			<td colspan="2"><a href="../reviews.cfm/#speakerObj.getSpeakerKey()#" target="_blank" class="btn btn-primary">Read Reviews</td>
				  		</tr>--->
				  		</table>
				  		<cfelse>
				  			<ul><li>This speaker has not been reviewed yet.</li></ul>
				  		</cfif>
				  	</td>
				  </tr>
				  </cfif>
				  <!--- check if speaker request statistics are enabled --->
				  <cfif APPLICATION.showRequestStats>
				  <tr>
				  	<td><strong>Request Statistics</strong></td>
				  	<td>
				  		<cfif totalRequests>
				  			<div style="float:left; margin-right:20px; width:200px;" data-toggle="tooltip" data-placement="top" title="" data-original-title="#totalRequests# requests made through #APPLICATION.siteName#.">
								<div id="total-requests" class="chart text-center" data-percent="#totalRequestsPercent#"></div>
								<div class="text-center"><strong>Total Requests</strong></div>
							</div>
							<div style="float:left; margin-right:20px; width:200px;" data-toggle="tooltip" data-placement="top" title="" data-original-title="#totalAccepted# requests accepted through #APPLICATION.siteName#.">
								<div id="accepted-requests" class="chart text-center" data-percent="#totalAcceptedPercent#"></div>
								<div class="text-center"><strong>Requests Accepted</strong></div>
							</div>
							<cfif APPLICATION.sendSpeakerFeedbackRequests>
								<div style="float:left; width:200px;" data-toggle="tooltip" data-placement="top" title="" data-original-title="#totalCompleted# requests completed through #APPLICATION.siteName#.">
									<div id="complete-requests" class="chart text-center" data-percent="#totalCompletedPercent#"></div>
									<div class="text-center"><strong>Requests Completed</strong></div>
								</div>								
							</cfif>
				  		<cfelse>
				  			<ul><li>This speaker has not been requested yet.</li></ul>
				  		</cfif>
				  	</td>
				  </tr>
				  </cfif>
				</cfoutput>
				</tbody>
			  </table>

			</div><!---- /panel ---->	
			
			<cfoutput><div class="text-right"><small><a href="../abuse.cfm?v#Hash('speakerKey','SHA-256')#=#speakerObj.getSpeakerKey()#">Report abuse</a></small></div></cfoutput>
			  
		  <br />
		  
		  <form class="form-horizontal" role="form" id="request" method="post" action="../request.cfm">
		  <cfoutput>
			<input type="hidden" name="ff#Hash('speakerKey','SHA-384')#" value="#speakerObj.getSpeakerKey()#" />
			#APPLICATION.utils.getRandomFormField()#
			<fieldset>
			
			<!--- Form Name --->
			<legend>Email Speaker &raquo; Request For Event</legend>
			
			<!--- Text input--->
			<div class="form-group">
			  <label class="col-md-4 control-label" for="cName">Your Name</label>  
			  <div class="col-md-4">
			  <input id="cName" name="cName" placeholder="John Doe" class="form-control input-md" required autofocus type="text">
			  </div>
			</div>
			
			<!--- Text input--->
			<div class="form-group">
			  <label class="col-md-4 control-label" for="cName">Organization Name</label>  
			  <div class="col-md-4">
			  <input id="orgName" name="orgName" placeholder="Team CF Advance" class="form-control input-md" required type="text">
			  </div>
			</div>
			
			<!--- Text input--->
			<div class="form-group">
			  <label class="col-md-4 control-label" for="email">Your Email</label>  
			  <div class="col-md-4">
			  <input id="email" name="email" placeholder="someone@someplace.com" class="form-control input-md" required type="email">
				  <span class="help-block">Shared only with the speaker you&apos;re requesting</span>  
			  </div>
			</div>
			
			<!--- Text input--->
			<div class="form-group">
			  <label class="col-md-4 control-label" for="eventName">Event Name</label>  
			  <div class="col-md-4">
			  <input id="eventName" name="eventName" placeholder="My Great Conference" class="form-control input-md" required type="text">
				  <span class="help-block">Enter the name of your event</span>  
			  </div>
			</div>
			
			<!--- Text input--->
			<div class="form-group">
			  <label class="col-md-4 control-label" for="venue">Venue/Location</label>  
			  <div class="col-md-4">
				  <input id="venue" name="venue" placeholder="Online or Metro D.C." class="form-control input-md" required type="text">
				  <span class="help-block">Enter the venue and/or location for your event</span>  
			  </div>
			</div>
			
			<!--- Text input--->
			<div class="form-group">
			  <label class="col-md-4 control-label" for="eventDate">Date</label>  
			  <div class="col-md-2">  
			    <div class="input-group date">
				  <input id="eventDate" name="eventDate" placeholder="#DateFormat(DateAdd('d',30,Now()),'mm/dd/yyyy')#" class="form-control input-md" required type="text">
			  	  <span class="help-block">Enter the date of your event</span>  
				</div>
			  </div>
			</div>
			
			<!--- Text input--->
			<div class="form-group">
			  <label class="col-md-4 control-label" for="eventTime">Time</label>  
			  <div class="col-md-2">
			  <input id="eventTime" name="eventTime" placeholder="7:00 PM EST" class="form-control input-md" required type="text">
			  <span class="help-block">Enter the time in HH:MM AM/PM TZ format</span>  
			  </div>
			</div>
			
			<!--- Text input--->
			<div class="form-group">
			  <label class="col-md-4 control-label" for="venue">Expected Attendees</label>  
			  <div class="col-md-2">
				  <input id="attendees" name="attendees" placeholder="10" class="form-control input-md" required type="text">
				  <span class="help-block">Enter the number of attendees expected at your event</span>  
			  </div>
			</div>
			
			<!--- Text input--->
			<div class="form-group">
			  <label class="col-md-4 control-label" for="specialty">Topic/Specialty</label>  
			  <div class="col-md-4">
				  <input id="specialty" name="specialty" placeholder="CFML" class="form-control input-md" required type="text">
				  <span class="help-block">Enter the topic or specialty you would like this speaker to present on</span>  
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
				<button type="submit" id="btn_Submit" name="btn_Submit" class="btn btn-success">Request Speaker</button>
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
	<script src="//ajax.aspnetcdn.com/ajax/jquery.validate/1.11.1/jquery.validate.min.js"></script>
    <script src="//netdna.bootstrapcdn.com/bootstrap/3.3.1/js/bootstrap.min.js"></script>
	<script src="//cdn.vsgcom.net/js/bootstrap-datepicker.js"></script>
	<script src="//cdn.vsgcom.net/js/star-rating.min.js"></script>
	<script src="//cdn.vsgcom.net/js/jquery.easypiechart.min.js"></script>
	<script type="text/javascript">
		$(function() {
			$('#eventDate').datepicker({ autoclose: true });

			$('.chart').easyPieChart({
		        animate: 2000,
		        barColor: '#251eef',
		        trackColor: '#e2e2ff',
		        scaleColor: '#00000',
		        lineWidth: 8
		    });

			$("[data-toggle='tooltip']").tooltip(); 

			$('#request').validate({
				errorClass: 'text-danger',
				rules: {
					cName: {
						required: true,
						minlength: 2,
						maxlength: 150
					},
					orgName: {
						required: true,
						minlength: 2,
						maxlength: 150
					},
					email: {
						required: true,
						email: true	
					},
					venue: {
						required: true,
						minLength: 2,
						maxlength: 150
					},
					eventDate: {
						required: true,
						date: true	
					},
					eventTime: {
						required: true,
						maxlength: 12
					},
					attendees: {
						required: true,
						digits: true,
						maxlength: 4
					},
					specialty: {
						required: true,
						minlength: 2,
						maxlength: 150
					},
					capcha: {
						required: true,
						digits: true,
						maxlength: 2
					}
				},
				messages: {
					cName: {
						required: 'Please specify your name.',
						minlength: 'Your name must be at least 2 characters.',
						maxlength: 'Your name must not exceed 150 characters.'
					},
					orgName: {
						required: 'Please specify your organization name.',
						minlength: 'Your organization name must be at least 2 characters.',
						maxlength: 'Your organization name must not exceed 150 characters.'
					},
					email: {
						required: 'Please specify your email address',
						email: 'Your email address should be in the format: someone@someplace.tld.'	
					},
					venue: {
						required: 'Please specify a venue/location for this event.',
						minlength: 'Your venue/location must be at least 2 characters.',
						maxlength: 'Your venue/location must not exceed 150 characters.'
					},
					eventDate: {
						required: 'Please specify the date of your event.',
						date: 'You must enter a valid date in MM/DD/YYYY format.'	
					},
					eventTime: {
						required: 'Please specify the time of your event in HH:MM AM/PM TZ format.',
						maxlength: 'Your event time must not exceed 12 characters.'
					},
					attendees: {
						required: 'Please specify the expected number of attendees.',
						digits: 'You must only enter the digits 0 through 9.',
						maxlength: 'The number of attendees should not exceed four digits.'
					},
					specialty: {
						required: 'Please specity the topic/specialty for this event.',
						minlength: 'Your topic request must be at least 2 characters.',
						maxlength: 'Your topic request must not exceed 150 characters.'
					},
					capcha: {
						required: 'Please add the two numbers and enter the sum in this field.',
						digits: 'You must only enter the digits 0 through 9.',
						maxlength: 'The sum should not exceed two digits.'
					}
				}
				
			});
			
		});

		$('#punctuality').rating({
			starCaptions: {
				1: 'Missed Speaking',
				2: 'Very Late (30 mins+)',
				3: 'Late (15 mins+)',
				4: 'On Time',
				5: 'Ahead Of Schedule'
			}
		});
		
		$('#preparedness').rating({
			starCaptions: {
				1: 'Totally Unprepared',
				2: 'Unprepared',
				3: 'Slightly Unprepared',
				4: 'Prepared',
				5: 'Very Prepared'
			}
		});
		
		$('#knowledge').rating({
			starCaptions: {
				1: 'Knew Nothing',
				2: 'Knew Too Little',
				3: 'Knew Some',
				4: 'Knew Most',
				5: 'Knew All'
			}
		});
		
		$('#quality').rating({
			starCaptions: {
				1: 'Very Poor',
				2: 'Poor',
				3: 'Fair',
				4: 'Good',
				5: 'Excellent'
			}
		});
		
		$('#satisfaction').rating({
			starCaptions: {
				1: 'Completely Unsatisfied',
				2: 'Very Unsatisfied',
				3: 'Unsatisfied',
				4: 'Satisfied',
				5: 'Very Satisfied'
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
