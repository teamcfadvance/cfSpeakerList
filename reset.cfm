<cfparam name="FORM.email" default="" type="string" />

<cfset errorMsg = '' />
<cfset passwordReset = false />

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
			email 		= saniForm.email
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
	
	</cfif>
	
	<!--- ensure we have no errors --->	
	<cfif NOT Len(errorMsg)>
	
		<!--- no errors, get the user object by the provided email --->
		<cfset userObj = APPLICATION.userDAO.getUserByEmail(saniForm.email) />
		<!--- generate a password --->
		<cfset newPass  = APPLICATION.utils.generatePassword() />
		<!--- set the new password for this user --->
		<cfset userObj.setPassword(LCase(Hash(newPass,'SHA-384'))) />
		<!--- and save the user to persist the value to the database --->
		<cfset APPLICATION.userDAO.saveUser(userObj) />
		
		<cfset passwordReset = true />
		
		<!--- carriage return --->
		<cfset cR = Chr(10) & Chr(13) />

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
    <link rel="shortcut icon" href="favicon.ico">

    <title><cfoutput>#APPLICATION.siteName#</cfoutput> &raquo; Password Reset</title>

    <link href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css" rel="stylesheet">
    <link href="//cdn.vsgcom.net/css/signin.css" rel="stylesheet">

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
          <a class="navbar-brand" href="index.cfm"><cfoutput>#APPLICATION.siteLongName#</cfoutput></a> <span class="navbar-brand">&raquo; Password Reset</span>
        </div>
      </div>
    </div>

	<br />
	
    <div class="container">

		<cfif Len(errorMsg)>
		
		<div class="panel panel-danger">
		  <div class="panel-heading">Password Reset Incomplete</div>
		  	<div class="panel-body">
		  	<cfoutput>#errorMsg#</cfoutput>
		  </div>
		</div>
		
		<cfelseif NOT passwordReset>
		
		<div class="panel panel-primary">
		  <div class="panel-heading">Password Reset</div>
		  	<div class="panel-body">
		  	<p>To reset your password, simply enter your email address below and click 'Reset Password'. A new system generated password will be emailed to you.</p>
		  </div>
		</div>
		
		<cfelseif passwordReset>
		
		<div class="panel panel-success">
		  <div class="panel-heading">Password Reset Complete</div>
		  	<div class="panel-body">
		  	<p>Your password has been reset and an email has been sent to your email address with your new password. Please use this new password to log in to <cfoutput>#APPLICATION.siteName#</cfoutput> in the future. You may change your password after you have logged in using the 'Change Password' link.</p>
		  </div>
			  <div class="panel-footer">
			  	<a class="btn btn-info" href="login.cfm" role="button">Click here to log in</a>
			  </div>
		</div>
		
		</cfif>
	  <cfif NOT passwordReset>
	  <cfoutput>
      <form class="form-signin" role="form" method="post" action="#CGI.SCRIPT_NAME#">
	  </cfoutput>
        <h2 class="form-signin-heading">Password Reset</h2>
        <input type="email" name="email" class="form-control" placeholder="Email address" required autofocus>
		<br />
        <button name="btn_Submit" class="btn btn-lg btn-success btn-block" type="submit">Reset Password</button>
      </form>
	  </cfif>
	  
    </div> <!--- /container --->

    <script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
    <script src="//netdna.bootstrapcdn.com/bootstrap/3.3.1/js/bootstrap.min.js"></script>
  </body>
</html>
