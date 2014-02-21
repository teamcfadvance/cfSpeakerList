<cfparam name="FORM.search" default="" />
<cfparam name="FORM.mode" default="#Hash('browse','SHA-512')#" />

<!--- check if the user is requesting a simple search --->
<cfif NOT FindNoCase(' AND ',FORM.search) AND Len(FORM.search)>

	<!--- user requested simple search, get simple results --->
	<cfset qGetResults = APPLICATION.speakerGateway.simpleSearch(
		searchTerm = HTMLEditFormat(FORM.search)
	) />

<!--- otherwise, check if the user is requesting a complex search (using 'AND') --->	
<cfelseif FindNoCase(' AND ',FORM.search)>

	<!--- user requested a complex search, set null list value --->
	<cfset searchList = '' />
	
	<!--- loop through search terms by ' AND ' --->
	<cfloop from="1" to="#ListLen(HTMLEditFormat(FORM.search),' AND ')#" index="iX">
		<!--- set individual search terms into a list --->
		<cfset searchList = ListAppend(searchList,ListGetAt(HTMLEditFormat(FORM.search),iX,' AND ')) />
	</cfloop>

	<!--- perform complex search on the list of terms --->
	<cfset qGetResults = APPLICATION.speakerGateway.complexSearch(
		searchTerms = searchList
	) />	

<!--- otherwise, neither simple nor complex search requested --->
<cfelse>

	<!--- get a blank query to return --->
	<cfset qGetResults = APPLICATION.speakerGateway.filter(
		firstName	= 'EA5E9CBBDE7019808D178C0E758D82656B6AD3E944239CB2A1C3C103506F4F64DD4B7B29904EA7D77656371648882C5F303357E2A5914998F5EB4497C92F87482F991B7969F8CC52A96E42D99A444E53B5E51B2AC3EDE153579D1633E256A20DB35AB10416F563E3AFCC4B2FCEAEBE822131A4708F0981EDE9D6E002E4F2EF24D53D4772339339CAEFB00EAC90C0B154'
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

    <title>UGS List &raquo; Speakers</title>

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
          <a class="navbar-brand" href="index.cfm">User Group Speaker List</a>
        </div>
      </div>
    </div>

	<br />

    <div class="container">
	  <div class="row">
        <div class="col-md-12">
			<cfif qGetResults.RecordCount OR APPLICATION.debugOn>
			<div class="panel panel-primary">
			  <div class="panel-heading">Matching Speakers</div>
			  <div class="panel-body">
				<p>The following list of speakers matched your <cfif FindNoCase(Hash('browse','SHA-512'),FORM.mode)>browse<cfelse>search</cfif> request. Click on the name of any speaker to see more info and to request them to speak at your event.</p>
			  </div>
			
			  <table class="table sortable">
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
					<td><strong><a href="si.cfm/#qGetResults.speakerKey#">#APPLICATION.utils.dataDec(qGetResults.firstName)# #APPLICATION.utils.dataDec(qGetResults.lastName)#</a></strong></td>
					<td>#qGetResults.locations#</td>
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
				<p>No speakers matched your <cfif FindNoCase(Hash('browse','SHA-512'),FORM.mode)>browse<cfelse>search</cfif> request. <cfif FindNoCase(Hash('browse','SHA-512'),FORM.mode)>There are no speakers available in the location you have browsed. Please check back often as our list is constantly expanding to include new speakers.<cfelse>You can try narrowing your search or adding 'AND' between search terms to broaden your search.</cfif></p>
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
