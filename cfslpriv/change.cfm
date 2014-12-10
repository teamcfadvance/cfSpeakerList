<cfparam name="FORM.oPassword" default="" type="string" />
<cfparam name="FORM.nPassword" default="" type="string" />
<cfparam name="FORM.vPassword" default="" type="string" />

<!--- check for the existence of the session cookie --->
<cfif IsDefined('COOKIE.#APPLICATION.cookieName#')>
	<!--- cookie exists, get this speaker object --->
	<cfset userObj = APPLICATION.userDAO.getUserById(APPLICATION.userDAO.getUserIdFromSession(COOKIE[APPLICATION.cookieName])) />
<!--- otherwise, check if we're in debug mode --->
<cfelseif APPLICATION.debugOn>	
	<!--- we are, get the first available speaker for test --->
	<cfset userObj = APPLICATION.userDAO.getUserById(1) />
<!--- otherwise --->
<cfelse>	
	<!--- cookie does not exist and we're not in debug mode, redirect to the login page --->
	<cflocation url="../login.cfm" addtoken="false" />
<!--- end checking for the existence of the session cookie --->
</cfif>

<!--- set a null error message to check for later --->
<cfset errorMsg = '' />

<!--- check if the form was submitted --->
<cfif IsDefined('FORM.btn_Submit')>

	<!--- it was, sanitize the form values --->
	<cfset saniForm = APPLICATION.utils.sanitize(FORM) />

	<!--- process required fields --->
	<cfset reqCheck = APPLICATION.utils.checkRequired(
		fields = {
			oPassword	= saniForm.oPassword,
			nPassword	= saniForm.nPassword,
			vPassword	= saniForm.vPassword
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
	
	<!--- check that the stored password matches the current password --->
	<cfif NOT LCase(Hash(saniForm.oPassword,'SHA-384')) EQ userObj.getPassword()>
		<!--- password mismatch, set an error message to display --->
		<cfset errorMsg = '<p>We&apos;re sorry, but your current password could not be verified. Please ensure you&apos;ve typed the password correctly, and try again.</p>' />
	</cfif> 
		
	<!--- check if the new password and verification password match --->
	<cfif NOT Find(saniForm.nPassword,saniForm.vPassword)>
		<!--- password mismatch, set an error message to display --->
		<cfset errorMsg = '<p>We&apos;re sorry, but your password and verification password do not match. Please try again.</p>' />
	</cfif> 
	
	<!--- check the password meets complexity requirements --->
	<cfif NOT ReFind('[a-z]',saniForm.nPassword) OR NOT ReFind('[A-Z]',saniForm.nPassword) OR NOT ReFind('[0-9]',saniForm.nPassword) OR NOT Len(saniForm.nPassword) GTE 8>
		<!--- password doesn't meet complexity requirements, set an error message to display --->
		<cfset errorMsg = '<p>We&apos;re sorry, but your password does not meet complexity requirements for this system. Your password must be at least eight (8) characters long, and contain at least one lowercase (a through z), uppercase (A through Z) and number (0 through 9) to be accepted. Please try again.</p>' />
	</cfif>

	
	<!--- ensure we have no errors --->
	<cfif NOT Len(errorMsg)>	
		
		<!--- update the password --->
		<cfset userObj.setPassword(LCase(Hash(saniForm.nPassword,'SHA-384'))) />
		
		<!--- and save the user object --->	
		<cfset userObj.setUserId(APPLICATION.userDAO.saveUser(userObj)) />
		
		<!--- redirect to success --->
		<cflocation url="success.cfm?v#Hash('mode','SHA-256')#=#Hash('change')#" addtoken="false" />
	
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
    <link rel="shortcut icon" href="../favicon.ico">

    <title><cfoutput>#APPLICATION.siteName#</cfoutput> &raquo; Dashboard &raquo; Change Password</title>

    <link href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css" rel="stylesheet">
    <link href="//cdn.vsgcom.net/css/jumbotron.css" rel="stylesheet">
    <link href="//cdn.vsgcom.net/css/strength-meter.min.css" rel="stylesheet">

    <!--- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries --->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
      <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>

  <body>

    <div class="navbar navbar-inverse navbar-fixed-top" role="navigation">
      <div class="container-fluid">
        <div class="navbar-header">
          <a class="navbar-brand" href="../index.cfm"><cfoutput>#APPLICATION.siteLongName#</cfoutput></a> <a class="navbar-brand" href="index.cfm">&raquo; Dashboard</a> <span class="navbar-brand">&raquo; Change Password</span>
        </div>
        <div class="navbar-collapse collapse">
          <ul class="nav navbar-nav navbar-right">
		  	<li><a href="index.cfm">Dashboard</a></li>
            <li><a href="profile.cfm">Edit Profile</a></li>
            <li><a href="change.cfm">Change Password</a></li>
            <li><a href="../login.cfm">Logout</a></li>
          </ul>
        </div>
      </div>
    </div>

	<br />

    <div class="container">
	  <div class="row">
        <div class="col-md-12">
	  <cfoutput>
	  	<!--- check if there is an error message to display --->
	  	<cfif Len(errorMsg)>
		
		<div class="panel panel-danger">
		  <div class="panel-heading">An Error Occurred Changing Your Password</div>
		  <div class="panel-body">
			#errorMsg#
		  </div>
		</div>
		
		<cfelse>
		
		<div class="panel panel-primary">
		  <div class="panel-heading">Change Password Form</div>
		  <div class="panel-body">
			<p>To change your password, enter your current password, new password and verify your password using the form below. Click 'Change Password' to change your password.</p> 
		  </div>
		</div>
		
		</cfif>
			
		<form class="form-horizontal" role="form" method="post" action="#CGI.SCRIPT_NAME#">
		<fieldset>
		
		<!--- Form Name --->
		<legend>Change Password Form</legend>
		
		
		<!--- Password input--->
		<div class="form-group">
		  <label class="col-md-4 control-label" for="oPassword">Current Password</label>
		  <div class="col-md-4">
			<input id="oPassword" name="oPassword" placeholder="Enter your current password" class="form-control input-md" required type="password">
		  </div>
		</div>
		
		
		<!--- Password input--->
		<div class="form-group">
		  <label class="col-md-4 control-label" for="nPassword">New Password</label>
		  <div class="col-md-4">
			<input id="nPassword" name="nPassword" placeholder="My$tR0ngP@$sW0Rd#Year( Now() )#" class="form-control input-md" required type="password">
		  </div>
		</div>
		
		<!--- Password input--->
		<div class="form-group">
		  <label class="col-md-4 control-label" for="vPassword">Verify Password</label>
		  <div class="col-md-4">
			<input id="vPassword" name="vPassword" placeholder="As entered above" class="form-control input-md" required type="password">
		  </div>
		</div>
						
		<!--- Button (Double) --->
		<div class="form-group">
		  <label class="col-md-4 control-label" for="submit"></label>
		  <div class="col-md-8">
			<button id="submit" name="btn_Submit" type="submit" class="btn btn-success">Change Password</button>
			<button id="reset" name="btn_Reset" type="reset" class="btn btn-danger">Clear Form</button>
		  </div>
		</div>
		
		</fieldset>
		</form>
	  </cfoutput>
		</div>
	  </div>

      <hr>

      <cfinclude template="../includes/footer.cfm" />
    </div> <!--- /container --->

    <script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
    <script src="//netdna.bootstrapcdn.com/bootstrap/3.3.1/js/bootstrap.min.js"></script>
    <script src="//cdn.vsgcom.net/js/strength-meter.min.js"></script>
    <script>
    	$(function() {
    		$('#nPassword').strength({showMeter: true, toggleMask: false});
    	})
    </script>
  </body>
</html>
