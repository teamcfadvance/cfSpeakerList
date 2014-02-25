<cfparam name="URL['v' & Hash('mode','SHA-256')]" default="#Hash('change')#" type="string">

<cfset thisMode = URL['v' & Hash('mode','SHA-256')] />

<cfif thisMode EQ Hash('change')>
	<cfset heading = 'Password Change Complete' />
	<cfset body = '<p>You have successfully changed your password. Please use this new password the next time you login.</p>' />
<cfelseif thisMode EQ Hash('profile')>
	<cfset heading = 'Profile Update Complete' />
	<cfset body = '<p>You have successfully updated your profile.</p>' />
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

    <title><cfoutput>#APPLICATION.siteName#</cfoutput> &raquo; Dashboard</title>

    <link href="../css/bootstrap.min.css" rel="stylesheet">
    <link href="../css/jumbotron.css" rel="stylesheet">

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
          <a class="navbar-brand" href="../index.cfm">User Group Speaker List</a>
        </div>
        <div class="navbar-collapse collapse">
          <ul class="nav navbar-nav navbar-right">
		  	<li><a href="index.cfm">Dashboard</a></li>
            <li><a href="profile.cfm">Edit Profile</a></li>
            <li><a href="change.cfm">Change Password</a></li>
          </ul>
        </div>
      </div>
    </div>

    <div class="container">
      <div class="row">
        <div class="col-md-12 main">
			<div class="panel panel-success">
			  <div class="panel-heading"><cfoutput>#heading#</cfoutput></div>
			  <div class="panel-body">
				<cfoutput>#body#</cfoutput>
			  </div>
			  <div class="panel-footer">
			  	<cfoutput><a class="btn btn-info" href="index.cfm" role="button">Click here to return to the dashboard</a></cfoutput>
			  </div>
			</div>		          
        </div>
      </div>
	  
      <hr>

      <cfinclude template="../includes/footer.cfm" />
    </div>

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
    <script src="../js/bootstrap.min.js"></script>
  </body>
</html>
