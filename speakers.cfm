<cfparam name="FORM.search" default="" type="string" />
<cfparam name="FORM.mode" default="#Hash('browse','SHA-512')#" type="string" />
<cfparam name="FORM.onlineSearch" default="false" type="boolean" />

<!--- check if the user is requesting a simple search --->
<cfif NOT FindNoCase(' AND ',FORM.search) AND Len(Trim(FORM.search))>

	<!--- user requested simple search, get simple results --->
	<cfset qGetResults = APPLICATION.speakerGateway.simpleSearch(
		searchTerm = HTMLEditFormat(FORM.search),
		isOnline = FORM.onlineSearch
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
		searchTerms = searchList,
		isOnline = FORM.onlineSearch
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
    <link rel="shortcut icon" href="favicon.ico">

    <title><cfoutput>#APPLICATION.siteName#</cfoutput> &raquo; Speaker List</title>

    <link href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css" rel="stylesheet">
    <link href="//cdn.vsgcom.net/css/jumbotron.css" rel="stylesheet">
    <link href="//cdn.vsgcom.net/css/bootstrap-sortable.css" rel="stylesheet">

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
				<p>The following list of speakers matched your <cfif FindNoCase(Hash('browse','SHA-512'),FORM.mode)>browse request<cfelse>search request for &apos;<cfoutput><abbr title="Submitted Search Terms" class="initialism">#FORM.search#</abbr></cfoutput>&apos;</cfif>.</p>
				<p>To sort speakers, click on the header for the column you wish to sort by, click again to reverse the sort order.</p>
				<p>Speakers who present online are represented with the symbol: <span class="glyphicon glyphicon-globe"></p>
				<p>Click on the name of any speaker to see their speaker profile, and to request them to speak at your event.</p>
			  </div>
			
			  <table class="table sortable table-striped">
				<thead>
				  <tr>
				  	<th>&nbsp;</th>
					<th>Speaker Name</th>
					<th>Location(s)</th>
					<th>Closest City</th>
					<th>Specialties</th>
				  </tr>
				</thead>
				<tbody>
				<cfoutput query="qGetResults">
				<cfset speakerEmail = APPLICATION.utils.dataDec(qGetResults.email, 'repeatable') />
				  <tr>
				  	<td class="col-md-1"><img src="http://www.gravatar.com/avatar/#lCase( hash( lCase( speakerEmail ) ) )#?s=32&r=R&d=#UrlEncodedFormat('http://cdn.vsgcom.net/img/blank_profile_32px.png')#" /></td>
					<td class="col-md-3"><strong><a href="si.cfm/#qGetResults.speakerKey#" data-toggle="tooltip" data-placement="top" title="" data-original-title="Click here to see the speaker profile for #qGetResults.firstName# #qGetResults.lastName#.">#qGetResults.firstName# #qGetResults.lastName#</a></strong><cfif qGetResults.isOnline>&nbsp;&nbsp;&nbsp;&nbsp;<span class="glyphicon glyphicon-globe" data-toggle="tooltip" data-placement="top" title="" data-original-title="#qGetResults.firstName# #qGetResults.lastName# presents online."></span></cfif></td>
					<td class="col-md-3">#ListChangeDelims(qGetResults.locations,', ')#</td>
					<td class="col-md-2">#qGetResults.majorCity#</td>
					<td class="col-md-4">#ListChangeDelims(qGetResults.specialties,', ')#</td>
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

    <script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
    <script src="//netdna.bootstrapcdn.com/bootstrap/3.3.1/js/bootstrap.min.js"></script>
	<script src="//cdn.vsgcom.net/js/bootstrap-sortable.js"></script>
	<script>
			$("[data-toggle='tooltip']").tooltip(); 
	</script>
  </body>
</html>
