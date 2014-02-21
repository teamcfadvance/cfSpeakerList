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

    <title>UGS List</title>

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
          <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="index.cfm">User Group Speaker List</a>
        </div>
        <div class="navbar-collapse collapse">
          <form class="navbar-form navbar-right" role="form" method="post" action="login.cfm" onSubmit="hashIt();">
		  	<cfoutput><input type="hidden" id="#seedId#" name="ff#LCase(Hash('seedId','SHA-256'))#" value="#seedVal#" /></cfoutput>
            <div class="form-group">
              <input type="text" placeholder="Email" class="form-control" name="email" id="email">
            </div>
            <div class="form-group">
              <input type="password" placeholder="Password" class="form-control" name="password" id="password">
            </div>
            <button type="submit" class="btn btn-success">Sign in</button>
          </form>
        </div><!---/.navbar-collapse --->
      </div>
    </div>

    <div class="jumbotron">
      <div class="container">
        <h1>User Group Speaker List</h1>
        <p>This site is designed to allow development and design professionals who speak at user groups and conferences to add their information to our database, and those seeking speakers for their events to search our database to find suitable speakers and contact them.</p>
      </div>
    </div>

    <div class="container">
      <div class="row">
        <div class="col-md-4">
          <h2>Search Speakers</h2>
          <p>Enter your natural language search terms below to search for speakers by location, name, or specialty. Optionally, use AND to search multiple terms.</p>
		  <form class="form-horizontal" role="form" method="post" action="speakers.cfm">
		  	<cfoutput><input type="hidden" name="mode" value="#Hash('search','SHA-512')#" /></cfoutput>
			<p><input type="search" class="form-control input-md" name="search" placeholder="Enter search term AND search term"></p>
            <p><button type="submit" class="btn btn-primary">Search Speakers</button></p>
		  </form>
        </div>
        <div class="col-md-4">
          <h2>Browse Speakers</h2>
          <p>If you would prefer to browse through available speakers by location instead of searching for them, use our convenient browse functions to list speakers available in your area.</p>
		  <p>&nbsp;</p>
          <p><a class="btn btn-info" href="browse.cfm" role="button">Browse Speakers</a></p>
       </div>
        <div class="col-md-4">
          <h2>Speaker Sign Up</h2>
          <p>Are you a devlopment or design professional with experience and interest in speaking to user groups and at conferences? Use our easy sign-up form to add your information to our database!</p>
		  <p>&nbsp;</p>
          <p><a class="btn btn-success" href="signup.cfm" role="button">Sign Up Now</a></p>
        </div>
      </div>

      <hr>

      <cfinclude template="includes/footer.cfm" />
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
