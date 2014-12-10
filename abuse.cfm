<cfparam name="URL['v' & Hash('speakerKey','SHA-256')]" default="" type="string" />
<cfparam name="FORM['ff' & Hash('speakerKey','SHA-384')]" default="" type="string" />
<cfparam name="FORM.abuse" default="" type="string" />

<!--- set a null error message to check for later --->
<cfset errorMsg = '' />
<!--- set a default flag for abuse in a speaker listing to false --->
<cfset speakerAbuse = false />
<!--- set default abuse reported flag to false --->
<cfset abuseReported = false />

<!--- check if the form was submitted --->
<cfif IsDefined('FORM.btn_Submit')>

	<!--- it was, sanitize the form values --->
	<cfset saniForm = APPLICATION.utils.sanitize(FORM) />

	<!--- process required fields --->
	<cfset reqCheck = APPLICATION.utils.checkRequired(
		fields = {
			abuse = saniForm.abuse
		}
	) />
	
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
	
	<!--- check if a speaker key was provided --->
	<cfif Len(FORM['ff' & Hash('speakerKey','SHA-384')])>
		<!--- it was, get the data for the speaker --->
		<cfset speakerObj = APPLICATION.speakerDAO.getSpeakerByKey(FORM['ff' & Hash('speakerKey','SHA-384')]) />
		<!--- set the speaker abuse flag to true --->
		<cfset speakerAbuse = true />
	</cfif>
	
	<!--- ensure we have no errors --->
	<cfif NOT Len(errorMsg)>
	
		<!--- set abuse reported to true --->
		<cfset abuseReported = true />
	
		<!--- carriage return --->
		<cfset cR = Chr(10) & Chr(13) />
	
		<!---no errors, send an abuse report --->
		<cfmail to="#APPLICATION.abuseEmail#" from="#APPLICATION.fromEmail#" subject="#APPLICATION.siteName# Abuse Reported" bcc="#APPLICATION.bccEmail#" charset="utf-8">
		 <cfmailpart type="html">
		 	<h4>#APPLICATION.siteName# Abuse Reported</h4>
			<p>Abuse has been reported in the system by a user. Details of the abuse provided by the user is:</p>
			<p>#saniForm.abuse#</p>
			<cfif speakerAbuse>
				<cfdump var="#speakerObj.getMemento()#" label="Speaker Reported For Abuse" />
			</cfif>
			<p>&nbsp;</p>
			<p>Sincerely,<br />The #APPLICATION.siteName# Team</p>
		 </cfmailpart>
		 <cfmailpart type="plain">
			#APPLICATION.siteName# Abuse Reported#cR##cR#
			Abuse has been reported in the system by a user. Details of the abuse provided by the user is:#cR##cR##cR#
			#saniForm.abuse##cR##cR##cR#
			<cfif speakerAbuse>
				<cfdump var="#speakerObj.getMemento()#" label="Speaker Reported For Abuse" format="text" />
			</cfif>
			Sincerely,#cR#
			The #APPLICATION.siteName# Team#cR##cR#
		 </cfmailpart>
		</cfmail>	
	
	<!--- end ensuring we have no errors --->	
	</cfif>	

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

    <title><cfoutput>#APPLICATION.siteName#</cfoutput> &raquo; Report Abuse</title>

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
          <a class="navbar-brand" href="index.cfm"><cfoutput>#APPLICATION.siteLongName#</cfoutput></a> <span class="navbar-brand">&raquo; Report Abuse</span>
        </div>
      </div>
    </div>

	<br />


    <div class="container">
	<cfoutput>
		<form role="form" method="post" action="#CGI.SCRIPT_NAME#">
		<cfif Len(URL['v' & Hash('speakerKey','SHA-256')])>
			<input type="hidden" name="ff#Hash('speakerKey','SHA-384')#" value="#URL['v' & Hash('speakerKey','SHA-256')]#" />
		</cfif>
	</cfoutput>
	  <div class="row">
	  	<div class="col-md-12">
		
			<cfif NOT abuseReported>
		
			<div class="panel panel-danger">
			  <div class="panel-heading">Report Abuse</div>
				<div class="panel-body">
					<cfif Len(errorMsg)>
						<cfoutput>#errorMsg#</cfoutput>
					</cfif>
					<p>To report abuse, please enter a description of why you feel our system has been abused (e.g. &apos;Speaker listed is spam&apos;, &apos;I did not sign up with my email&apos;, etc.) and we will review your complaint and take appropriate action.</p>
					<textarea class="form-control" id="abuse" name="abuse"></textarea>
			  	</div>
			</div>	
			
			<cfelse>
		
			<div class="panel panel-info">
			  <div class="panel-heading">Abuse Report Complete</div>
				<div class="panel-body">
					<p>Your abuse report has been sent to our abuse response team for investigation. Thank you for helping to ensure that our system remains abuse free.</p>
			  	</div>
			</div>	
			
			</cfif>
			
			
				
		</div>
	  </div>
	  <cfif NOT abuseReported>
	  <div class="row">
	  	<div class="col-md-12">
			<button id="submit" name="btn_Submit" type="submit" class="btn btn-danger">Report Abuse</button>		
		</div>
	  </div>
	  </cfif>
	  
	  </form>
	  
      <hr>

      <cfinclude template="includes/footer.cfm" />
    </div> <!--- /container --->

    <script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
    <script src="//netdna.bootstrapcdn.com/bootstrap/3.3.1/js/bootstrap.min.js"></script>
  </body>
</html>
