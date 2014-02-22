<!--- check if the page was called without a speaker key in the path --->
<cfif CGI.PATH_INFO EQ CGI.SCRIPT_NAME OR NOT Len(CGI.PATH_INFO)>
	<!--- it was, redirect to the home page --->
	<cflocation url="index.cfm" addtoken="false" />
</cfif>

<!--- get a speaker object from the passed in path info (truncated to remove the /) --->
<cfset speakerObj = APPLICATION.speakerDAO.getSpeakerByKey(Right(CGI.PATH_INFO,Len(CGI.PATH_INFO)-1)) />

<!--- check if the speaker object returned has a valid speaker key --->
<cfif NOT Len(speakerObj.getSpeakerKey())>
	<!--- invalid key passed, redirect to the home page --->
	<cflocation url="index.cfm" addtoken="false" />
</cfif>

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">
    <!-----<link rel="shortcut icon" href="../../assets/ico/favicon.ico">----->

    <title>UGS List &raquo; Speaker Information</title>

    <link href="../css/bootstrap.min.css" rel="stylesheet">
    <link href="../css/jumbotron.css" rel="stylesheet">
	<link href="../css/datepicker.css" rel="stylesheet">
	<link href="../css/datepicker3.css" rel="stylesheet">

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
          <a class="navbar-brand" href="../index.cfm">User Group Speaker List</a>
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
				    <td><strong>Speaker Name</strong></td>
					<td>#speakerObj.getFirstName()# #speakerObj.getLastName()#</td>
				  </tr>
				  <tr>
				    <td><strong>Specialties</strong></td>
					<td>#speakerObj.getSpecialties()#</td>
				  </tr>
				  <tr>
				    <td><strong>Location(s)</strong></td>
					<td>#speakerObj.getLocations()#</td>
				  </tr>
				  <tr>
				    <td><strong>Program(s)</strong></td>
					<td>
						<ul>
						<cfif speakerObj.getIsACP()><li>Adobe Community Professional (ACP)</li></cfif>
						<cfif speakerObj.getIsAEL()><li>Adobe E-Learning Professional (AEL)</li></cfif>
						<cfif speakerObj.getIsUGM()><li>Adobe User Group Manager (UGM)</li></cfif>
						<cfif speakerObj.getIsOther()><li>Other design/development program member</li></cfif>
						</ul>
					</td>
				  </tr>
				  <tr>
				    <td><strong>Contact Details:</strong></td>
					<td>
						<ul>
						<cfif speakerObj.getShowPhone() AND Len(speakerObj.getPhone())><li>Phone: #speakerObj.getPhone()#</li></cfif>
						<cfif speakerObj.getShowTwitter() AND Len(speakerObj.getTwitter())><li>Twitter: #speakerObj.getTwitter()#</li></cfif>
						</ul>
					</td>
				  </tr>
				</cfoutput>
				</tbody>
			  </table>

			</div><!---- /panel ---->	
			  
		  <br />
		  
		  <form class="form-horizontal" role="form" method="post" action="request.cfm">
		  <cfoutput>
			<input type="hidden" name="ff#Hash('speakerKey','SHA-384')#" value="#speakerObj.getSpeakerKey()#" />
			<fieldset>
			
			<!--- Form Name --->
			<legend>Email Speaker &raquo; Request For Event</legend>
			
			<!--- Text input--->
			<div class="form-group">
			  <label class="col-md-4 control-label" for="cName">Your Name</label>  
			  <div class="col-md-4">
			  <input id="cName" name="cName" placeholder="John Doe" class="form-control input-md" required type="text">
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
			  <input id="email" name="email" placeholder="someone@someplace.com" class="form-control input-md" required type="text">
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
				<button id="btn_Submit" name="btn_Submit" class="btn btn-success">Request Speaker</button>
				<button id="btn_Reset" name="btn_Reset" class="btn btn-danger">Clear Form</button>
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

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
    <script src="../js/bootstrap.min.js"></script>
	<script src="../js/bootstrap-datepicker.js"></script>
	<script type="text/javascript">
		$(function() {
			$('#eventDate').datepicker({ autoclose: true });
		});
	</script>
  </body>
</html>
