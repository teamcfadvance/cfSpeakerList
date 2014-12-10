<!--- check if the page was called without a speaker key in the path --->
<cfif CGI.PATH_INFO EQ CGI.SCRIPT_NAME OR NOT Len(CGI.PATH_INFO)>
	<!--- it was, redirect to the home page --->
	<cflocation url="index.cfm" addtoken="false" />
</cfif>

<cftry>

	<!--- set a variable to hold the decrypted request id --->
	<cfset decSpeakerRequestId = APPLICATION.utils.dataDec( ListGetAt(CGI.PATH_INFO,1,'/'), 'form' ) />

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

<!--- get a speaker object from the passed in path info --->
<cfset speakerRequestObj = APPLICATION.speakerRequestDAO.getSpeakerRequestById( decSpeakerRequestId ) />

<!--- check if the speaker object returned has a valid speaker request id --->
<cfif NOT Len(speakerRequestObj.getSpeakerRequestId())>
	<!--- invalid id passed, redirect to the home page --->
	<cflocation url="../index.cfm" addtoken="false" />
</cfif>

<!--- set the speaker request to accepted --->
<cfset speakerRequestObj.setIsAccepted( true ) />

<!--- save the speaker request --->
<cfset APPLICATION.speakerRequestDAO.saveSpeakerRequest( speakerRequestObj ) />

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="shortcut icon" href="../favicon.ico">

    <title><cfoutput>#APPLICATION.siteName#</cfoutput> &raquo; Speaker Request Accepted</title>

    <link href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css" rel="stylesheet">
    <link href="//cdn.vsgcom.net/css/jumbotron.css" rel="stylesheet">

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
          <a class="navbar-brand" href="../index.cfm"><cfoutput>#APPLICATION.siteLongName#</cfoutput></a> <span class="navbar-brand">&raquo; Speaker Request Accepted</span>
        </div>
      </div>
    </div>

	<br />

    <div class="container">
	  <div class="row">
        <div class="col-md-12">
			<div class="panel panel-primary">
			  <div class="panel-heading">Speaker Request Accepted</div>
			  <div style="margin:5px;">Congratulations! You've accepted the following speaking request!</div>
			
			  <table class="table">
				<tbody>
				<cfoutput>
				  <tr>
				    <td><strong>Requested By</strong></td>
					<td>#speakerRequestObj.getRequestedBy()#</td>
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

		</div>
	  </div><!---- /row ---->

      <hr>

      <cfinclude template="includes/footer.cfm" />
    </div> <!---- /container ---->

    <script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
    <script src="//netdna.bootstrapcdn.com/bootstrap/3.3.1/js/bootstrap.min.js"></script>
  </body>
</html>
