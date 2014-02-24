<!--- set a default null error message --->
<cfset errorMsg = '' />
<!--- check if the path equals the script name --->
<cfif NOT CGI.PATH_INFO EQ CGI.SCRIPT_NAME>
	<!--- it doesn't, ensure the path passed has two values --->
	<cfif ListLen(CGI.PATH_INFO,'/') NEQ 2>
		<!--- it doesn't, set an error message --->
		<cfset errorMsg = '<p>We&apos;re sorry, but we did not receive the values we expected in your request. Please try your request again. If you continue to experience issues, please try to copy and paste the provided URL into your browser, ensure there are no line breaks.</p>' />
	<!--- otherwise --->
	<cfelse>
		<!--- it has two values, get a speaker object from the first passed path value --->
		<cfset speakerObj = APPLICATION.speakerDAO.getSpeakerByKey(ListGetAt(CGI.PATH_INFO,1,'/')) />
		<!--- and decrypt the second value to get the original email timestamp --->
		<cfset ts = APPLICATION.utils.dataDec(ListGetAt(CGI.PATH_INFO,2,'/'), 'cookie') />
		<!--- check if the provided timestamp is a valid date or if it is greater than the timeout set --->
		<cfif NOT IsDate(ts) OR DateDiff('h',ts,Now()) GT APPLICATION.verificationTimeout>
			<!--- invalid date or already timed out, set an error message --->
			<cfset errorMsg = '<p>We&apos;re sorry, but your verification email has expired.' />
			<!--- check if we have a valid speaker object, and the previous mail timestamp is less than 7 days old --->
			<cfif Len(speakerObj.getSpeakerId()) AND NOT DateDiff('h',ts,Now()) GT 167>
				<!--- it is, resend the verification email --->
				<cfset APPLICATION.utils.emailVerification(email = speakerObj.getEmail(), key = speakerObj.getSpeakerKey()) />
				<!--- and notify the user the verification has been resent --->
				<cfset errorMsg = errorMsg & ' We have sent another verification email to you at the email address you provided when you signed up. Please be sure to click the link in this newer email before the verification expiration in #APPLICATION.verificationTimeout# hours.</p>' />
			<!--- otherwise --->
			<cfelse>
				<cfset errorMsg = errorMsg & ' We are unable to resend another verification email at this time. Please contact us at <a href="mailto:#APPLICATION.emailFrom#">#APPLICATION.emailFrom#</a> to let us know you&apos;re having difficulties and we can assist in getting your account verified and your information published.</p>' />
			<!--- end checking if we have a valid speaker object, and the previous mail timestamp is less than 7 days old --->
			</cfif>			
		<!--- otherwise --->
		<cfelse>
			<!--- within timeout, check if this is a valid speaker object --->
			<cfif NOT Len(speakerObj.getSpeakerId())>
				<!--- it isn't, set an error message --->
				<cfset errorMsg = '<p>We&apos;re sorry, but we did not receive the values we expected in your request. Please try your request again. If you continue to experience issues, please try to copy and paste the provided URL into your browser, ensure there are no line breaks.</p>' />
			<!--- otherwise --->
			<cfelse>
				<!--- get a user object from the speaker object's user id --->
				<cfset userObj = APPLICATION.userDAO.getUserById(speakerObj.getUserId()) />
				<!--- set the user as active (publishing their information) --->
				<cfset userObj.setIsActive(1) />
				<!--- save the user object to persist this change back to the database --->
				<cfset userObj.setUserId(APPLICATION.userDAO.saveUser(userObj)) />
			<!--- end checking if this is a valid speaker object --->
			</cfif>
		<!--- end checking if the provided timestamp is a valid date or if it is greater than the timeout set --->
		</cfif>
	<!--- end ensuring the path passed has two values --->
	</cfif>
<!--- otherwise --->
<cfelse>
	<!--- the path equals the script name, so notify user to check their email --->
	<cfset errorMsg = '<p>An email has been sent to you at the email address you provided during sign-up. You must click the link within that email within the next #APPLICATION.verificationTimeout# hours to have your speaker information published in our database.</p>' />
<!--- end checking if the path equals the script name --->
</cfif>

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">
    <!----<link rel="shortcut icon" href="../../assets/ico/favicon.ico">---->

    <title><cfoutput>#APPLICATION.siteName#</cfoutput> &raquo; Verify Email Result</title>

    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/jumbotron.css" rel="stylesheet">

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
          <a class="navbar-brand" href="index.cfm">User Group Speaker List</a>
        </div>
      </div>
    </div>

	<br />

    <div class="container">
	  <div class="row">
        <div class="col-md-12">
	  
	  		<cfif Len(errorMsg)>
			

			<div class="panel panel-danger">
			  <div class="panel-heading">Email Verification Incomplete</div>
			  <div class="panel-body">
				<cfoutput>#errorMsg#</cfoutput>
			  </div>
			</div>
			
			<cfelse>
			
			
			<div class="panel panel-success">
			  <div class="panel-heading">Email Verification Complete</div>
			  <div class="panel-body">
				<p>Congratulations! You have now verified your email address and your speaker information is now published in our database. To make changes to your speaker profile in the future, simply log in from our home page with your email address and the password you chose during sign up.</p>
			  </div>
			  <div class="panel-footer">
			  	<cfoutput><a class="btn btn-info" href="si.cfm/#ListGetAt(CGI.PATH_INFO,1,'/')#" role="button">Click here to view your information</a></cfoutput>
			  </div>
			</div>
			
			</cfif>			
	  
		</div>
	  </div>

      <hr>

      <cfinclude template="includes/footer.cfm" />
    </div> <!--- /container --->

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
    <script src="js/bootstrap.min.js"></script>
  </body>
</html>
