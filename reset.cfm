<cfparam name="FORM.email" default="" type="string" />

<cfset errorMsg = '' />

<!--- check if there is an existing session cookie in this request --->
<cfif IsDefined('COOKIE.#APPLICATION.cookieName#')>
	<!--- existing session cookie, expire the existing session --->
	<cfset APPLICATION.userDAO.expireSession(COOKIE[APPLICATION.cookieName]) />
	<!--- and expire the cookie --->
	<cfcookie name="#APPLICATION.cookieName#" value="" expires="now" />
</cfif>

<!--- check if the form was submitted --->
<cfif IsDefined('FORM.btn_Submit')>

	<!--- it was, sanitize the form values --->
	<cfset saniForm = APPLICATION.utils.sanitize(FORM) />

	<!--- process required fields --->
	<cfset reqCheck = APPLICATION.utils.checkRequired(
		fields = {
			email 		= saniForm.email,
			password 	= saniForm.password
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

	<!--- check if this user exists in the database --->
	<cfif NOT APPLICATION.userDAO.checkIfUserExists(saniForm.email)>
	
		<!--- user doesn't exist, set an error message to be displayed --->
		<cfset errorMsg = '<p>We&apos;re sorry but we could not validate your email based on the information you provided. Please try again.</p>' />
	
	<!--- otherwise --->	
	<cfelse>
	
		<!--- user exists, get the user object by the provided email --->
		<cfset userObj = getUserByEmail(saniForm.email) />
		<!--- generate a password --->
		<cfset newPass  = APPLICATION.util.generatePassword() />
		<!--- set the new password for this user --->
		<cfset userObj.setPassword(LCase(Hash(newPass,'SHA-384'))) />
		<!--- and save the user to persist the value to the database --->
		<cfset APPLICATION.userDAO.saveUser(userObj) />

		<!--- email the new password to the user --->
		<cfmail to="#saniForm.email#" from="#APPLICATION.fromEmail#" subject="#APPLICATION.siteName# Password Reset" bcc="#APPLICATION.bccEmail#" charset="utf-8">
		 <cfmailpart type="html">
		 	<h4>#APPLICATION.siteName# Password Reset</h4>
			<p>We have received your request for a password reset. Your password has been reset to:</p>
			<p>#newPass#</p>
			<p>&nbsp;</p>
			<p>Please use this new password the next time you login to #APPLICATION.siteName#.</p>
			<p>&nbsp;</p>
			<p>Sincerely,<br />The #APPLICATION.siteName# Team</p>
		 </cfmailpart>
		 <cfmailpart type="plain">
			#APPLICATION.siteName# Password Reset#cR##cR#
			We have received your request for a password reset. Your password has been reset to:#cR##cR##cR#
			#newPass##cR##cR##cR#
			Please use this new password the next time you login to #APPLICATION.siteName#.#cR##cR#
			Sincerely,#cR#
			The #APPLICATION.siteName# Team#cR##cR#
		 </cfmailpart>
		</cfmail>	
	
	<!--- end checking if this user exists in the database --->	
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
    <!----<link rel="shortcut icon" href="../../assets/ico/favicon.ico">---->

    <title>UGS List &raquo; Password Reset</title>

    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/signin.css" rel="stylesheet">

    <!--- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries --->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
      <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>

  <body>

    <div class="container">

		<cfif Len(errorMsg)>
		
		<div class="panel panel-danger">
		  <div class="panel-heading">Password Reset Incomplete</div>
		  	<div class="panel-body">
		  	<cfoutput>#errorMsg#</cfoutput>
		  </div>
		</div>
		
		<cfelse>
		
		<div class="panel panel-primary">
		  <div class="panel-heading">Password Reset</div>
		  	<div class="panel-body">
		  	<p>To reset your password, simply enter your email address below and click 'Reset Password'. A new system generated password will be emailed to you.</p>
		  </div>
		</div>
		
		</cfif>

      <form class="form-signin" role="form" method="post" action="#CGI.SCRIPT_NAME#" >
	  <cfoutput>
        <h2 class="form-signin-heading">Password Reset</h2>
	  </cfoutput>
        <input type="email" class="form-control" placeholder="Email address" required autofocus>
		<br />
        <button name="btn_Submit" class="btn btn-lg btn-success btn-block" type="submit">Reset Password</button>
      </form>
	  
    </div> <!--- /container --->

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
    <script src="js/bootstrap.min.js"></script>
  </body>
</html>
