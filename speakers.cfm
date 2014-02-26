<cfparam name="FORM.search" default="" />
<cfparam name="FORM.mode" default="#Hash('browse','SHA-512')#" />

<!--- check if the user is requesting a simple search --->
<cfif NOT FindNoCase(' AND ',FORM.search) AND Len(Trim(FORM.search))>

	<!--- user requested simple search, get simple results --->
	<cfset qGetResults = APPLICATION.speakerGateway.simpleSearch(
		searchTerm = HTMLEditFormat(FORM.search)
	) />

<!--- otherwise, check if the user is requesting a complex search (using 'AND') --->	
<cfelseif FindNoCase(' AND ',FORM.search)>

	<!--- user requested a complex search, set null list value --->
	<cfset searchList = '' />
	
	<!--- loop through search terms by ' AND ' --->
	<cfloop from="1" to="#ListLen(HTMLEditFormat(LCase(FORM.search)),' and ')#" index="iX">
		<!--- set individual search terms into a list --->
		<cfset searchList = ListAppend(searchList,ListGetAt(HTMLEditFormat(LCase(FORM.search)),iX,' and ')) />
	</cfloop>

	<!--- perform complex search on the list of terms --->
	<cfset qGetResults = APPLICATION.speakerGateway.complexSearch(
		searchTerms = searchList
	) />	

<!--- otherwise, neither simple nor complex search requested --->
<cfelse>

	<!--- get a blank query, this will notify the user that they have to start over --->
	<cfset qGetResults = APPLICATION.speakerGateway.filter(
		firstName	= Hash(RandRange(1000,999999),'SHA-512')
	) />

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

    <title><cfoutput>#APPLICATION.siteName#</cfoutput> &raquo; Speaker List</title>

    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/jumbotron.css" rel="stylesheet">
    <link href="css/bootstrap-sortable.css" rel="stylesheet">

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
          <a class="navbar-brand" href="index.cfm"><cfoutput>#APPLICATION.siteLongName#</cfoutput></a> <span class="navbar-brand">&raquo; Speaker List</span>
        </div>
      </div>
    </div>

	<br />

    <div class="container">
	  <div class="row">
        <div class="col-md-12">
			<cfif qGetResults.RecordCount>
			<div class="panel panel-primary">
			  <div class="panel-heading">Matching Speakers</div>
			  <div class="panel-body">
				<p>The following list of speakers matched your <cfif FindNoCase(Hash('browse','SHA-512'),FORM.mode)>browse request<cfelse>search request for &apos;<cfoutput><abbr title="Submitted Search Terms" class="initialism">#FORM.search#</abbr></cfoutput>&apos;</cfif> . Click on the name of any speaker to see more info and to request them to speak at your event.</p>
			  </div>
			
			  <table class="table sortable table-striped">
				<thead>
				  <tr>
					<th>Speaker Name</th>
					<th>Location(s)</th>
					<th>Specialties</th>
				  </tr>
				</thead>
				<tbody>
				<cfoutput query="qGetResults">
				  <tr>
					<td class="col-md-2"><strong><a href="si.cfm/#qGetResults.speakerKey#">#qGetResults.firstName# #qGetResults.lastName#</a></strong></td>
					<td class="col-md-3">#qGetResults.locations#</td>
					<td>#qGetResults.specialties#</td>
				  </tr>
				</cfoutput>
				</tbody>
			  </table>
			</div>
			<cfelse>
			<cfif FindNoCase(Hash('browse','SHA-512'),FORM.mode)>
				<cfset returnLink = 'browse.cfm' />
			<cfelse>
				<cfset returnLink = 'index.cfm' />
			</cfif>
			<div class="panel panel-danger">
			  <div class="panel-heading">No Matching Speakers</div>
			  <div class="panel-body">
				<p>No speakers matched your <cfif FindNoCase(Hash('browse','SHA-512'),FORM.mode)>browse request<cfelse>search request for &apos;<cfoutput><abbr title="Submitted Search Term(s)" class="initialism">#FORM.search#</abbr></cfoutput>&apos;</cfif>. <cfif FindNoCase(Hash('browse','SHA-512'),FORM.mode)>There are no speakers available in the location you have browsed. Please check back often as our list is constantly expanding to include new speakers.<cfelse>You can try to broaden your search by using less terms (e.g. &apos;HTML&apos; instead of &apos;HTML AND CSS&apos;).</cfif></p>
			  </div>
			  <div class="panel-footer">
			  	<cfoutput><a class="btn btn-info" href="#returnLink#" role="button">Click here to start over</a></cfoutput>
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
	<script src="js/bootstrap-sortable.js"></script>
  </body>
</html>
