<cfparam name="FORM.search" default="" type="string" />
<cfparam name="URL['v' & Hash('delete','SHA-256')]" default="#APPLICATION.urlZero#" type="string" />
<cfparam name="URL['v' & Hash('confirm','SHA-256')]" default="#APPLICATION.urlZero#" type="string" />
<cfparam name="URL['v' & Hash('inactive','SHA-256')]" default="1" type="boolean" />

<!--- check for the existence of the session cookie --->
<cfif IsDefined('COOKIE.#APPLICATION.cookieName#')>
	<!--- cookie exists, get this speaker object --->
	<cfset speakerObj = APPLICATION.speakerDAO.getSpeakerByUserId(APPLICATION.userDAO.getUserIdFromSession(COOKIE[APPLICATION.cookieName])) />
<!--- otherwise, check if we're in debug mode --->
<cfelseif APPLICATION.debugOn>	
	<!--- we are, get the first available speaker for test --->
	<cfset speakerObj = APPLICATION.speakerDAO.getSpeakerById(1) />
<!--- otherwise --->
<cfelse>	
	<!--- cookie does not exist and we're not in debug mode, redirect to the login page --->
	<cflocation url="../login.cfm" addtoken="false" />
<!--- end checking for the existence of the session cookie --->
</cfif>

<!--- get this user object --->
<cfset userObj = APPLICATION.userDAO.getUserById(speakerObj.getUserId()) />

<!--- check if this user is an administrator --->
<cfif NOT FindNoCase('admin',userObj.getRole())>
	<!--- it isn't, redirect to the login page --->
	<cflocation url="../login.cfm" addtoken="false" />
</cfif>

<!--- decrypt the delete variable (zero by default) --->
<cfset delSpeakerKey = APPLICATION.utils.dataDec(URL['v' & Hash('delete','SHA-256')], 'url') />
<!--- decrypt the confirm variable (zero by default) --->
<cfset conSpeakerKey = APPLICATION.utils.dataDec(URL['v' & Hash('confirm','SHA-256')], 'url') />

<!--- check if the delete speaker key is not numeric (not zero) --->
<cfif NOT IsNumeric(delSpeakerKey)>

	<!--- it's not numeric, get the speaker object for the passed key --->
	<cfset speakerObj = APPLICATION.speakerDAO.getSpeakerByKey(delSpeakerKey) />
	
</cfif>

<!--- check if the confirm speaker key is not numeric (not zero) --->
<cfif NOT IsNumeric(conSpeakerKey)>

	<!--- it's not numeric, get the speaker object for the passed key --->
	<cfset speakerObj = APPLICATION.speakerDAO.getSpeakerByKey(conSpeakerKey) />
	<!--- delete the user object --->
	<cfset APPLICATION.userDAO.deleteUserById(speakerObj.getUserId()) />
	<!--- delete the speaker object --->
	<cfset APPLICATION.speakerDAO.deleteSpeakerById(speakerObj.getSpeakerId()) />
	
	<!--- encrypt the full name of the speaker --->
	<cfset encFullName = APPLICATION.utils.dataEnc(speakerObj.getFirstName() & ' ' & speakerObj.getLastName(), 'url') />
	
	<!--- redirect to success --->
	<cflocation url="success.cfm?v#Hash('mode','SHA-256')#=#Hash('delete')#&v#Hash('name','SHA-256')#=#encFullName#" addtoken="false" />
	
</cfif>

<!--- check if the user is requesting a simple search --->
<cfif NOT FindNoCase(' AND ',FORM.search) AND Len(Trim(FORM.search))>

	<!--- user requested simple search, get simple results --->
	<cfset qGetResults = APPLICATION.speakerGateway.simpleSearch(
		searchTerm = HTMLEditFormat(FORM.search),
		showActive = URL['v' & Hash('inactive','SHA-256')]
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
		showActive = URL['v' & Hash('inactive','SHA-256')]
	) />	

<!--- otherwise, neither simple nor complex search requested --->
<cfelse>

	<!--- get all speakers --->
	<cfset qGetResults = APPLICATION.speakerGateway.filter(showActive = URL['v' & Hash('inactive','SHA-256')]) />

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

    <title><cfoutput>#APPLICATION.siteName#</cfoutput> &raquo; Administration &raquo; Manage <cfif URL['v' & Hash('inactive','SHA-256')]>Active<cfelse>Inactive</cfif> Speakers</title>

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
      <div class="container-fluid">
        <div class="navbar-header">
          <a class="navbar-brand" href="../index.cfm"><cfoutput>#APPLICATION.siteLongName#</cfoutput></a> <span class="navbar-brand">&raquo; Administration</span>
        </div>
        <div class="navbar-collapse collapse">
          <ul class="nav navbar-nav navbar-right">
            <li><a href="admin.cfm">Administration</a></li>
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
			<div class="panel panel-primary">
			  <div class="panel-heading">Manage <cfif URL['v' & Hash('inactive','SHA-256')]>Active<cfelse>Inactive</cfif> Speakers</div>
			  <div class="panel-body">
				<p>You can manage speakers using the table below to edit their information or remove them from the database.</p>
				<p>To sort speakers, click on the header for the column you wish to sort by, click again to reverse the sort order.</p>
				<hr />
				<p>To search for speakers by name, location and/or specialties simply input your search terms below. Optionally, use AND to search multiple terms.</p>
				<div class="col-md-3">
			    <form class="form-horizontal" role="form" method="post" action="admin.cfm">
				  <p><input type="search" class="form-control input-md" name="search" placeholder="Enter search term AND search term" required></p>
				  <p><button type="submit" class="btn btn-primary">Search Speakers</button></p>
			    </form>
				</div>
				<p class="text-right"><small>
					<cfif URL['v' & Hash('inactive','SHA-256')]>
						<cfoutput><a href="#CGI.SCRIPT_NAME#?v#Hash('inactive','SHA-256')#=0">Show Inactive Speakers</a></cfoutput>
					<cfelse>
						<cfoutput><a href="#CGI.SCRIPT_NAME#?v#Hash('inactive','SHA-256')#=1">Show Active Speakers</a></cfoutput>
					</cfif>
				</small></p>
				<p class="text-right"><small><a href="../signup.cfm" target="_blank">Add New Speaker</a></small></p>
			  </div>
			
			  <table class="table sortable table-striped">
				<thead>
				  <tr>
					<th>Speaker Name</th>
					<th>Location(s)</th>
					<th>Specialties</th>
					<th class="text-center">Edit</th>
					<th class="text-center">Remove</th>
				  </tr>
				</thead>
				<tbody>
				<cfoutput query="qGetResults">
					<cfset thisUser = APPLICATION.utils.dataEnc(qGetResults.speakerKey, 'url') />
				  <tr>
					<td class="col-md-2">#qGetResults.firstName# #qGetResults.lastName#</td>
					<td class="col-md-3">#ListChangeDelims(qGetResults.locations,', ')#</td>
					<td class="col-md-3">#ListChangeDelims(qGetResults.specialties,', ')#</td>
					<td class="col-md-1 text-center"><a href="editUser.cfm?v#Hash('speakerKey','SHA-256')#=#thisUser#" class="btn btn-info"><span class="glyphicon glyphicon-pencil"></span></a></td>
					<td class="col-md-1 text-center"><a href="#CGI.SCRIPT_NAME#?v#Hash('delete','SHA-256')#=#thisUser#" class="btn btn-danger"><span class="glyphicon glyphicon-remove"></span></a></td>					
				  </tr>
				</cfoutput>
				</tbody>
			  </table>
			</div>	
		</div>
	  </div>

      <hr>

      <cfinclude template="../includes/footer.cfm" />
    </div> <!--- /container --->

    <script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
    <script src="//netdna.bootstrapcdn.com/bootstrap/3.3.1/js/bootstrap.min.js"></script>
	<script src="//cdn.vsgcom.net/js/bootstrap-sortable.js"></script>
	
		  
	  <cfif NOT IsNumeric(delSpeakerKey)>

		<!--- Modal --->
		<div class="modal fade" id="confirm" tabindex="-1" role="dialog" aria-labelledby="confirmLabel" aria-hidden="true">
		  <div class="modal-dialog">
			<div class="modal-content">
			  <div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title" id="confirmLabel">Really Remove Speaker?</h4>
			  </div>
			  <div class="modal-body">
				<p>Are you sure you really wish to remove <strong><cfoutput>#speakerObj.getFirstName()# #speakerObj.getLastName()#</cfoutput></strong>?</p>
			  </div>
			  <div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
				<button type="button" id="remove" class="btn btn-danger" data-dismiss="modal">Remove User</button>
			  </div>
			</div>
		  </div>
		</div>
		
		<script type="text/javascript">
			$('#remove').on('click', function (e) {
			<cfoutput>
			  window.location.href = '#CGI.SCRIPT_NAME#?v#Hash("confirm","SHA-256")#=#URL["v" & Hash("delete","SHA-256")]#';
			</cfoutput>
			})

			$('#confirm').modal('show');
		
		</script>
	  
	  </cfif>
	
  </body>
</html>
