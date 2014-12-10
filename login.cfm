<cfparam name="FORM.email" default="" type="string" />
<cfparam name="FORM.password" default="" type="string" />
<cfparam name="FORM['ff' & LCase(Hash('seedId','SHA-256'))]" default="" type="string" />
<cfparam name="errorMsg" default="" type="string" />

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
		<cfset errorMsg = '<p>We&apos;re sorry but we could not validate your login based on the information you provided. Please try again.</p>' />
	
	</cfif>
	
	<!--- ensure we don't have any errors --->
	<cfif NOT Len(errorMsg)>
	
		<!--- no errors, get the user object by the provided email --->
		<cfset userObj = APPLICATION.UserDAO.getUserByEmail(saniForm.email) />
		<!--- create a hash of the stored password plus the seed value provided by the form --->
		<cfset passHash = LCase(Hash(userObj.getPassword() & FORM['ff' & LCase(Hash('seedId','SHA-256'))],'SHA-384')) />
		
		<!--- check if the stored password matches the password submitted --->
		<cfif NOT FindNoCase(passHash,saniForm.password)>
		
			<!--- password mismatch, set an error message to be displayed --->
			<cfset errorMsg = '<p>We&apos;re sorry but we could not validate your login based on the information you provided. Please try again.</p>' />
		
		<!--- otherwise --->	
		<cfelse>
		
			<!--- password matches, generate a session id --->
			<cfset sid = APPLICATION.utils.generateSessionId() />
			<!--- generate an encrypted version of the session id to store in the cookie --->
			<cfset cSid = APPLICATION.utils.dataEnc(sid, 'cookie') />
			<!--- send the session cookie --->
			<cfcookie name="#APPLICATION.cookieName#" value="#cSid#" expires="never" />
			<!--- add the session to the database --->
			<cfset APPLICATION.userDAO.addSession(sessionId = sid, user = userObj) />
			
			<!--- redirect the user to the speakers area --->
			<cflocation url="cfslpriv/index.cfm" addtoken="false" />
		
		<!--- end checking if the stored password matches the password submitted --->	
		</cfif>
	
	<!--- end checking if this user exists in the database --->
	</cfif>

<!--- end checking if the form was submitted --->
</cfif>

<!--- generate a seed id for later hashing with CryptoJS --->
<cfset seedId = 's' & LCase(Left(Hash(CreateUUID()),RandRange(8,16))) />
<!--- generate a seed value for later hashing with CryptoJS --->
<cfset seedVal = Left(Hash(CreateUUID(),'SHA-512'),RandRange(16,32)) />

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="shortcut icon" href="favicon.ico">

    <title><cfoutput>#APPLICATION.siteName#</cfoutput> &raquo; Sign In</title>

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
          <a class="navbar-brand" href="index.cfm"><cfoutput>#APPLICATION.siteLongName#</cfoutput></a> <span class="navbar-brand">&raquo; Sign In</span>
        </div>
      </div>
    </div>

	<br />

    <div class="container">

		<cfif Len(errorMsg)>
		
		<div class="panel panel-danger">
		  <div class="panel-heading">Sign In Required</div>
		  	<div class="panel-body">
		  	<cfoutput>#errorMsg#</cfoutput>
		  </div>
		</div>
		
		</cfif>

      <form class="form-signin" role="form" method="post" action="login.cfm" onSubmit="hashIt();">
	  <cfoutput>
	  	<input type="hidden" id="#seedId#" name="ff#LCase(Hash('seedId','SHA-256'))#" value="#seedVal#" />
        <h2 class="form-signin-heading">#APPLICATION.siteName# Sign In</h2>
	  </cfoutput>
	  <div class="form-group">
        <input type="email" name="email" class="form-control" placeholder="Email address" required autofocus>
	  </div>
	  <div class="form-group">
        <input type="password" name="password" class="form-control" placeholder="Password" id="password" required>
	  </div>
        <button name="btn_Submit" class="btn btn-lg btn-success btn-block" type="submit">Sign in</button>
		<br />
		
        <label class="checkbox">
          Forgot your password? <a href="reset.cfm">Reset it here</a>.
        </label>
      </form>
	  
    </div> <!--- /container --->

    <script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
    <script src="//netdna.bootstrapcdn.com/bootstrap/3.3.1/js/bootstrap.min.js"></script>
	<script src="//cdn.vsgcom.net/js/sha384.js"></script>
	<cfoutput>
	<script type="text/javascript">
		var $pwd = $('##password');
		var $sd = $('###seedId#');
			
		function hashIt() {
			$pwd.val(CryptoJS.SHA384($pwd.val()));
			$pwd.val(CryptoJS.SHA384($pwd.val() + $sd.val()));
		};
	</script>
	</cfoutput>
  </body>
</html>
