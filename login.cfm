<cfparam name="FORM.email" default="" type="string" />
<cfparam name="FORM.password" default="" type="string" />
<cfparam name="FORM['ff' & LCase(Hash('seedId','SHA-256'))]" default="" />

<cfset errorMsg = '' />

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
	
	<!--- otherwise --->	
	<cfelse>
	
		<!--- user exists, get the user object by the provided email --->
		<cfset userObj = getUserByEmail(saniForm.email) />
		<!--- create a hash of the stored password plus the seed value provided by the form --->
		<cfset passHash = LCase(Hash(userObj.getPassword() & FORM['ff' & LCase(Hash('seedId','SHA-256'))],'SHA-384')) />
		
		<!--- check if the stored password matches the password submitted --->
		<cfif NOT FindNoCase(passHash,saniForm.password)>
		
			<!--- password mismatch, set an error message to be displayed --->
			<cfset errorMsg = '<p>We&apos;re sorry but we could not validate your login based on the information you provided. Please try again.</p>' />
		
		<!--- otherwise --->	
		<cfelse>
		
			<!--- password matches, check if there is an existing session cookie --->
			<cfif IsDefined('COOKIE.#APPLICATION.cookieName#') />
				<!--- there is, remove it and expire the session --->
				<cfset dSid = APPLICATION.utils.dataDec(COOKIE[APPLICATION.cookieName], 'cookie') />
				<cfcookie name="#APPLICATION.cookieName#" value="" expires="now" />
				<cfset APPLICATION.userDAO.expireSession(dSid) />
			</cfif>
			
			<!--- generate a session id --->
			<cfset sid = APPLICATION.utils.generateSessionId() />
			<!--- generate an encrypted version of the session id to store in the cookie --->
			<cfset cSid = APPLICATION.utils.dataEnc(sid, 'cookie') />
			<!--- send the session cookie --->
			<cfcookie name="#APPLICATION.cookieName#" value="#cSid#" expires="never" />
			<!--- add the session to the database --->
			<cfset APPLICATION.userDAO.addSession(sessionId = sid, user = userObj) />
			
			<!--- redirect the user to the speakers area --->
			<cflocation url="cfslpriv/index.cfm" addtoken="false" />
			
		</cfif>

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
    <!----<link rel="shortcut icon" href="../../assets/ico/favicon.ico">---->

    <title>UGS List &raquo; Sign-In</title>

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

      <form class="form-signin" role="form" method="post" action="login.cfm" onSubmit="hashIt();">
	  <cfoutput>
	  	<input type="hidden" id="#seedId#" name="ff#LCase(Hash('seedId','SHA-256'))#" value="#seedVal#" />
        <h2 class="form-signin-heading">#APPLICATION.siteName# Sign In</h2>
	  </cfoutput>
        <input type="email" class="form-control" placeholder="Email address" required autofocus>
        <input type="password" class="form-control" placeholder="Password" id="password" required>
        <button name="btn_Submit" class="btn btn-lg btn-success btn-block" type="submit">Sign in</button>
		<br />
		
        <label class="checkbox">
          Forgot your password? <a href="reset.cfm">Reset it here</a>.
        </label>
      </form>
	  
    </div> <!--- /container --->

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
    <script src="js/bootstrap.min.js"></script>
	<script src="js/sha384.js"></script>
	<cfoutput>
	<script type="text/javascript">
		var $pwd = $('##password');
		var $sd = $('###seedId#');
			
		function hashIt() {
			$pwd.val(CryptoJS.SHA384($pwd.val()));
			$pwd.val(CryptoJS.SHA384(pwd.val() + $sd.val()));
		};
	</script>
	</cfoutput>
  </body>
</html>
