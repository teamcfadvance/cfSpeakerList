

<!--- get cached county data for countries select field --->
<cfset qGetCountries = APPLICATION.countryGateway.filter(cache = true, cacheTime = CreateTimeSpan(30,0,0,0)) />
<!--- get cached state data for states select field --->
<cfset qGetStates = APPLICATION.stateGateway.filter(cache = true, cacheTime = CreateTimeSpan(30,0,0,0)) />

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">
    <!----<link rel="shortcut icon" href="../../assets/ico/favicon.ico">---->

    <title><cfoutput>#APPLICATION.siteName#</cfoutput> &raquo; Browse Speakers</title>

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
	<form role="form" method="post" action="speakers.cfm">
	  <div class="row">
	  	<div class="col-md-12">
			<div class="panel panel-info">
			  <div class="panel-heading">Browse By Location</div>
				<div class="panel-body">
				  <p>To browse by location, simply select the state, if browsing the United States, or the country, if browsing by country, of the speaker you wish to locate and click the 'Browse By Location' button.</p>
			  </div>
			</div>		
		</div>
	  </div>
	  <div class="row">
        <div class="col-md-6">
			<div class="panel panel-primary">
			  <div class="panel-heading">Browse By State</div>
				<div class="panel-body">
					<select id="state" name="search" class="form-control">
						<option value="" selected>--- SELECT STATE ---</option>
					<cfoutput query="qGetStates">
						<option value="#qGetStates.state#">#qGetStates.state#</option>
					</cfoutput>
					</select>
			  </div>
			</div>
		</div>
		<div class="col-md-6">
			<div class="panel panel-primary">
			  <div class="panel-heading">OR Browse By Country</div>
				<div class="panel-body">
					<select id="country" name="search" class="form-control">
						<option value="" selected>--- OR SELECT COUNTRY ---</option>
					<cfoutput query="qGetCountries">
						<option value="#qGetCountries.country#">#qGetCountries.country#</option>
					</cfoutput>
					</select>
			  </div>
			</div>
		</div>
	  </div><!--- /row --->
	  <div class="row">
	  	<div class="col-md-12">
			<button id="submit" name="btn_Submit" type="submit" class="btn btn-info">Browse By Location</button>		
		</div>
	  </div>
	  
	  </form>
	  
      <hr>

      <cfinclude template="includes/footer.cfm" />
    </div> <!--- /container --->

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
    <script src="js/bootstrap.min.js"></script>
  </body>
</html>
