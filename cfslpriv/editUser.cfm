<cfparam name="URL['v' & Hash('speakerKey','SHA-256')]" default="#APPLICATION.urlZero#" type="string">
<cfparam name="FORM.email" default="" type="string" />
<cfparam name="FORM.password" default="" type="string" />
<cfparam name="FORM.fName" default="" type="string" />
<cfparam name="FORM.lName" default="" type="string" />
<cfparam name="FORM.showPhone" default="0" type="boolean" />
<cfparam name="FORM.phone" default="" type="string" />
<cfparam name="FORM.showTwitter" default="0" type="boolean" />
<cfparam name="FORM.twitter" default="" type="string" />
<cfparam name="FORM.blog" default="" type="string" />
<cfparam name="FORM.countries" default="" type="string" />
<cfparam name="FORM.states" default="" type="string" />
<cfparam name="FORM.otherLocations" default="" type="string" />
<cfparam name="FORM.online" default="" type="string" />
<cfparam name="FORM.specialties" default="" type="string" />
<cfparam name="FORM.programs" default="" type="string" />
<cfparam name="FORM.activeUser" default="0" type="boolean" />
<cfparam name="URL['ff' & Hash('speakerKey','SHA-384')]" default="#APPLICATION.urlZero#" type="string">

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
	<!--- it is, redirect to the admin dashboard --->
	<cflocation url="../login.cfm" addtoken="false" />
</cfif>

<!--- now that we've verified we're an admin, check if the button has been submitted --->
<cfif IsDefined('FORM.btn_Submit')>
	<!--- it is, get the speaker key from the form --->
	<cfset thisSpeakerKey = APPLICATION.utils.dataDec(FORM['ff' & Hash('speakerKey','SHA-384')], 'url') />
<!--- otherwise --->	
<cfelse>
	<!--- it isn't, get the speaker key of the user to edit from the URL --->
	<cfset thisSpeakerKey = APPLICATION.utils.dataDec(URL['v' & Hash('speakerKey','SHA-256')], 'url') />
</cfif>

<!--- get this users speaker object --->
<cfset speakerObj = APPLICATION.speakerDAO.getSpeakerByKey(thisSpeakerKey) />
<!--- get this users user object --->
<cfset userObj = APPLICATION.userDAO.getUserById(speakerObj.getUserId()) />

<!--- set a null error message to check for later --->
<cfset errorMsg = '' />

<!--- check if the form was submitted --->
<cfif IsDefined('FORM.btn_Submit')>

	<!--- it was, sanitize the form values --->
	<cfset saniForm = APPLICATION.utils.sanitize(FORM) />

	<!--- process required fields --->
	<cfset reqCheck = APPLICATION.utils.checkRequired(
		fields = {
			email 			= saniForm.email,
			fName 			= saniForm.fName,
			lName 			= saniForm.lName,
			otherLocations 	= saniForm.otherLocations,
			specialties 	= saniForm.specialties,
			bio 			= saniForm.bio
		}
	) />
	
	<!--- check if the required fields were not provided --->
	<cfif NOT reqCheck.result>
		<!--- some fields not provided, set an error message to display --->
		<cfset errorMsg = '<p>We&apos;re sorry, but the following fields are required but were not provided:</p><ul>' />
		<!--- loop through the missing fields --->
		<cfloop from="1" to="#ListLen(reqCheck.fields)#" index="iX">
			<!--- add this field as a list item --->
			<cfset errorMsg = errorMsg & '<li>#LCase(ListGetAt(reqCheck.fields,iX))#</li>' />
		</cfloop>
		<cfset errorMsg = errorMsg & '</ul>' />
	</cfif>
	
	<!--- check if phone was provided, if it is numeric after filtering out non-numeric chars and is at least 10 digits long --->
	<cfif Len(saniForm.phone) AND (NOT IsNumeric(ReReplace(saniForm.phone,'[^0-9]','','ALL')) OR NOT Len(ReReplace(saniForm.phone,'[^0-9]','','ALL')) GTE 10)>
		<!--- password doesn't meet complexity requirements, set an error message to display --->
		<cfset errorMsg = '<p>We&apos;re sorry, but your phone number must contain only (, ), +, -, [space] and 0-9 characters and must contain at least 10 digits. Please try again.</p>' />
	</cfif> 
	
	<!--- ensure we have no errors --->
	<cfif NOT Len(errorMsg)>	
	
		<!--- update the username in the user object --->
		<cfset userObj.setUsername(saniForm.email) />
		<cfset userObj.setIsActive(saniForm.activeUser) />
		
		<!--- and save the user object --->
		<cfset userObj.setUserId(APPLICATION.userDAO.saveUser(userObj)) />
		
		<!--- concatenate and sort locations --->
		<cfset tempSpeakerLocs = ListSort(ListAppend(ListAppend(saniForm.countries, saniForm.states),saniForm.otherLocations),'textnocase') />
		
		<!--- set a blank list to populate --->
		<cfset thisSpeakerLocs = '' />
		
		<!--- loop through temporary locations --->
		<cfloop from="1" to="#ListLen(tempSpeakerLocs)#" index="iX">
			<!--- check if this temporary location is in the perm location list --->
			<cfif NOT ListFind(thisSpeakerLocs,ListGetAt(tempSpeakerLocs,iX))>
				<!--- it isn't, add it to the perm location list --->
				<cfset thisSpeakerLocs = ListAppend(thisSpeakerLocs,ListGetAt(tempSpeakerLocs,iX)) />
			</cfif>
		</cfloop>
		
		<!--- format the phone number based on digit length --->	
		<cfset formattedPhone = APPLICATION.utils.formatPhone(saniForm.phone) />
		
		<!--- update the speaker object --->
		<cfset speakerObj.setFirstName(saniForm.fName) />
		<cfset speakerObj.setLastName(saniForm.lName) />
		<cfset speakerObj.setEmail(saniForm.email) />
		<cfset speakerObj.setPhone(formattedPhone) />
		<cfset speakerObj.setShowPhone(saniForm.showPhone) />
		<cfset speakerObj.setTwitter(saniForm.twitter) />
		<cfset speakerObj.setBlog( saniForm.blog ) />
		<cfset speakerObj.setShowTwitter(saniForm.showTwitter) />
		<cfset speakerObj.setSpecialties(ListSort(saniForm.specialties,'textnocase')) />
		<cfset speakerObj.setBlog( saniForm.blog ) />
		<cfset speakerObj.setBio( saniForm.bio ) />
		<cfset speakerObj.setLocations(thisSpeakerLocs) />
		<cfset speakerObj.setMajorCity( saniForm.majorCity ) />
		<cfset speakerObj.setIsOnline( saniForm.online ) />
		<cfset speakerObj.setIsACP((ListFindNoCase(saniForm.programs,'acp') ? 1 : 0)) />
		<cfset speakerObj.setIsAEL((ListFindNoCase(saniForm.programs,'ael') ? 1 : 0)) />
		<cfset speakerObj.setIsUGM((ListFindNoCase(saniForm.programs,'ugm') ? 1 : 0)) />
		<cfset speakerObj.setIsOther((ListFindNoCase(saniForm.programs,'other') ? 1 : 0)) />
		
		<!--- and save the speaker object --->	
		<cfset speakerObj.setSpeakerId(APPLICATION.speakerDAO.saveSpeaker(speakerObj)) />
	
		<!--- encrypt the full name of the speaker --->
		<cfset encFullName = APPLICATION.utils.dataEnc(speakerObj.getFirstName() & ' ' & speakerObj.getLastName(), 'url') />
		
		<!--- redirect to success --->
		<cflocation url="success.cfm?v#Hash('mode','SHA-256')#=#Hash('edit')#&v#Hash('name','SHA-256')#=#encFullName#" addtoken="false" />
	
	<!--- end ensuring we have no errors --->	
	</cfif>

<!--- end checking if the form was submitted --->	
</cfif>

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
    <link rel="shortcut icon" href="../favicon.ico">

    <title><cfoutput>#APPLICATION.siteName#</cfoutput> &raquo; Administration &raquo; Edit Speaker</title>

    <link href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css" rel="stylesheet">
    <link href="//cdn.vsgcom.net/css/jumbotron.css" rel="stylesheet">
    <link href="//cdn.vsgcom.net/css/bootstrap3-wysihtml5.min.css" rel="stylesheet">

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
          <a class="navbar-brand" href="../index.cfm"><cfoutput>#APPLICATION.siteLongName#</cfoutput></a> <span class="navbar-brand">&raquo; Edit Speaker</span>
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
	  <cfoutput>
	  	<!--- check if there is an error message to display --->
	  	<cfif Len(errorMsg)>
		
		<div class="panel panel-danger">
		  <div class="panel-heading">An Error Occurred Editing Your Profile</div>
		  <div class="panel-body">
			#errorMsg#
		  </div>
		</div>
		
		<cfelse>
		
		<div class="panel panel-primary">
		  <div class="panel-heading">Edit Speaker Profile Form</div>
		  <div class="panel-body">
			<p>To modify the speaker information in the database, simply edit and submit the following form providing information about them, locations they can present at and their specialties or general speaking topics.</p> 
		  </div>
		</div>
		
		</cfif>
			
		<form class="form-horizontal" role="form" method="post" action="#CGI.SCRIPT_NAME#">
		<input type="hidden" name="ff#Hash('speakerKey','SHA-384')#" value="#URL['v' & Hash('speakerKey','SHA-256')]#" />
		<fieldset>
		
		<!--- Form Name --->
		<legend>Edit Speaker Profile Form</legend>
		
		<!--- Text input--->
		<div class="form-group">
		  <label class="col-md-4 control-label" for="email">Email</label>  
		  <div class="col-md-4">
		  <input id="email" name="email" placeholder="someone@someplace.com" class="form-control input-md" required autofocus type="email" value="#speakerObj.getEmail()#">
		  <span class="help-block">Used to login and receive contacts, never shared publicly</span>  
		  </div>
		</div>
		
		<!--- Password input--->
		<div class="form-group">
		  <label class="col-md-4 control-label" for="password">Password</label>
		  <div class="col-md-4">
			<a href="../reset.cfm" target="_blank">Reset Password</a>			
		  </div>
		</div>
		
		<!--- Text input--->
		<div class="form-group">
		  <label class="col-md-4 control-label" for="fName">First Name</label>  
		  <div class="col-md-4">
		  <input id="fName" name="fName" placeholder="John" class="form-control input-md" required type="text" value="#speakerObj.getFirstName()#">
			
		  </div>
		</div>
		
		<!--- Text input--->
		<div class="form-group">
		  <label class="col-md-4 control-label" for="lName">Last Name</label>  
		  <div class="col-md-4">
		  <input id="lName" name="lName" placeholder="Doe" class="form-control input-md" required type="text" value="#speakerObj.getLastName()#">
			
		  </div>
		</div>
		
		<!--- Prepended checkbox --->
		<div class="form-group">
		  <label class="col-md-4 control-label" for="phone">Telephone</label>
		  <div class="col-md-4">
			<div class="input-group">
			  <span class="input-group-addon">     
				  <input type="checkbox" name="showPhone" value="1"<cfif speakerObj.getShowPhone()> checked="checked"</cfif>>     
			  </span>
			  <input id="phone" name="phone" class="form-control" placeholder="(999) 999-9999" type="tel" value="#speakerObj.getPhone()#">
			</div>
			<p class="help-block">Optional, check box to show publicly</p>
		  </div>
		</div>
		
		<!--- Prepended checkbox --->
		<div class="form-group">
		  <label class="col-md-4 control-label" for="twitter">Twitter</label>
		  <div class="col-md-4">
			<div class="input-group">
			  <span class="input-group-addon">     
				  <input type="checkbox" name="showTwitter" value="1"<cfif speakerObj.getShowTwitter()> checked="checked"</cfif>>     
			  </span>
			  <input id="twitter" name="twitter" class="form-control" placeholder="@myhandle" type="text" value="#speakerObj.getTwitter()#">
			</div>
			<p class="help-block">Optional, check box to show publicly</p>
		  </div>
		</div>
		
		<!--- Text input--->
		<div class="form-group">
		  <label class="col-md-4 control-label" for="blog">Website/Blog URL</label>  
		  <div class="col-md-4">
		  <input id="blog" name="blog" placeholder="http://blog.domain.tld" class="form-control input-md" type="text" value="#speakerObj.getBlog()#">
		  <span class="help-block">Optional, shown publicly</span>  
		  </div>
		</div>
		
		<!--- Text input--->
		<div class="form-group">
		  <label class="col-md-4 control-label" for="majorCity">Closest Major City</label>  
		  <div class="col-md-4">
		  <input id="majorCity" name="majorCity" placeholder="Richmond" class="form-control input-md" type="text" value="#speakerObj.getMajorCity()#">
		  <span class="help-block">Enter thclosest major city to you</span>  
		  </div>
		</div>
		
		<!--- Text input--->
		<div class="form-group">
		  <label class="col-md-4 control-label" for="otherLocations">Locations</label>  
		  <div class="col-md-4">
		  <input id="otherLocations" name="otherLocations" placeholder="Online, Toronto, Paris" class="form-control input-md" type="text" value="#speakerObj.getLocations()#">
		  <span class="help-block">Enter location(s) separated by commas</span>  
		  </div>
		</div>
		
		<!--- Checkbox --->
		<div class="form-group">
		  <label class="col-md-4 control-label" for="programs">Present Online?</label>
		  <div class="col-md-4">
		  	<div class="checkbox">
				<label for="online">
				  <input name="online" id="online" value="1" type="checkbox"<cfif speakerObj.getIsOnline()> checked="checked"</cfif>>
				  Yes, I present online
				</label>
			</div>
		  </div>
		</div>
		
		<!--- Textarea --->
		<div class="form-group">
		  <label class="col-md-4 control-label" for="specialties">Specialties/Speaking Topics</label>
		  <div class="col-md-4">                     
			<textarea class="form-control" id="specialties" name="specialties"><cfif Len(speakerObj.getSpecialties())>#speakerObj.getSpecialties()#<cfelse>HTML5, CSS3, CFML, Web Design</cfif></textarea>
		  <span class="help-block">Enter your specialties separated by commas</span>  
		  </div>
		</div>
		
		<!--- Textarea --->
		<div class="form-group">
		  <label class="col-md-4 control-label" for="bio">Biography</label>
		  <div class="col-md-4">                     
			<textarea class="form-control" id="bio" name="bio"><cfif Len(speakerObj.getBio())>#APPLICATION.utils.decodeVal(speakerObj.getBio())#<cfelse></cfif></textarea>
		  <span class="help-block">Enter your biography</span>  
		  </div>
		</div>
		
		<!--- Multiple Checkboxes --->
		<div class="form-group">
		  <label class="col-md-4 control-label" for="programs">I am an</label>
		  <div class="col-md-4">
		  <div class="checkbox">
			<label for="programs-0">
			  <input name="programs" id="programs-0" value="ACP" type="checkbox"<cfif speakerObj.getIsACP()> checked="checked"</cfif>>
			  Adobe Community Professional (ACP)
			</label>
			</div>
		  <div class="checkbox">
			<label for="programs-1">
			  <input name="programs" id="programs-1" value="AEL" type="checkbox"<cfif speakerObj.getIsAEL()> checked="checked"</cfif>>
			  Adobe Education Leader (AEL)
			</label>
			</div>
		  <div class="checkbox">
			<label for="programs-2">
			  <input name="programs" id="programs-2" value="UGM" type="checkbox"<cfif speakerObj.getIsUGM()> checked="checked"</cfif>>
			  Adobe User Group Manager (UGM)
			</label>
			</div>
		  <div class="checkbox">
			<label for="programs-3">
			  <input name="programs" id="programs-3" value="Other" type="checkbox"<cfif speakerObj.getIsOther()> checked="checked"</cfif>>
			  Other design/development program member
			</label>
			</div>
		  </div>
		</div>
		
		<!--- Single Checkbox --->
		<div class="form-group">
		  <label class="col-md-4 control-label" for="programs">Show In Listing?</label>
		  <div class="col-md-4">
		    <div class="checkbox">
			  <label for="activeUser">
			    <input name="activeUser" id="activeUser" value="1" type="checkbox"<cfif userObj.getIsActive()> checked="checked"</cfif>>
			    Speaker Is Shown In Listing When Checked
			  </label>
		    </div>
		  </div>
		</div>
				
		<!--- Button (Double) --->
		<div class="form-group">
		  <label class="col-md-4 control-label" for="submit"></label>
		  <div class="col-md-8">
			<button id="submit" name="btn_Submit" type="submit" class="btn btn-success">Update Speaker</button>
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
    <script src="//cdn.vsgcom.net/js/bootstrap3-wysihtml5.all.min.js"></script>
    <script>
		$('#bio').wysihtml5({
			toolbar: {
			    "font-styles": true, //Font styling, e.g. h1, h2, etc. Default true
			    "emphasis": true, //Italics, bold, etc. Default true
			    "lists": true, //(Un)ordered lists, e.g. Bullets, Numbers. Default true
			    "html": false, //Button which allows you to edit the generated HTML. Default false
			    "link": false, //Button to insert a link. Default true
			    "image": true, //Button to insert an image. Default true,
			    "color": false, //Button to change color of font  
			    "blockquote": false, //Blockquote  
			    "size": 'sm' //default: none, other options are xs, sm, lg
			}
		});
	</script>
  </body>
</html>
