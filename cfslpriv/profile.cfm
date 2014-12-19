<cfparam name="FORM.email" default="" type="string" />
<cfparam name="FORM.password" default="" type="string" />
<cfparam name="FORM.fName" default="" type="string" />
<cfparam name="FORM.lName" default="" type="string" />
<cfparam name="FORM.showPhone" default="0" type="boolean" />
<cfparam name="FORM.phone" default="" type="string" />
<cfparam name="FORM.showTwitter" default="0" type="boolean" />
<cfparam name="FORM.twitter" default="" type="string" />
<cfparam name="FORM.countries" default="" type="string" />
<cfparam name="FORM.states" default="" type="string" />
<cfparam name="FORM.otherLocations" default="" type="string" />
<cfparam name="FORM.specialties" default="" type="string" />
<cfparam name="FORM.programs" default="" type="string" />
<cfparam name="FORM.capcha" default="999" />
<cfparam name="FORM['ff' & Hash('capcha')]" default="#APPLICATION.formZero#" type="string" />

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
			bio 			= saniform.bio,
			capcha 			= saniForm.capcha
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
	
	<!--- decrypt the capcha answer --->
	<cfset cAnswer = APPLICATION.utils.dataDec(saniForm['ff' & Hash('capcha')], 'form') />
	
	<!--- verify the capcha is correct --->
	<cfif saniForm.capcha EQ cAnswer>
		<cfset validCapcha = true />
	<cfelse>
		<cfset validCapcha = false />
	</cfif>	
	
	<!--- check if the sum of the capcha is not equal to the expected sum --->
	<cfif NOT validCapcha>
		<!--- capcha mismatch, set an error message to display --->
		<cfset errorMsg = '<p>We&apos;re sorry, but you did not enter the correct sum of the two numbers. You may have added the numbers incorrectly, typo&apos;d the answer, or at worst... you may not be human. Please try again.</p>' />
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
		
		<!--- redirect to success --->
		<cflocation url="success.cfm?v#Hash('mode','SHA-256')#=#Hash('profile')#" addtoken="false" />
	
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

    <title><cfoutput>#APPLICATION.siteName#</cfoutput> &raquo; Dashboard &raquo; Edit Profile</title>

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
          <a class="navbar-brand" href="../index.cfm"><cfoutput>#APPLICATION.siteLongName#</cfoutput></a> <a class="navbar-brand" href="index.cfm">&raquo; Dashboard</a> <span class="navbar-brand">&raquo; Edit Profile</span>
        </div>
        <div class="navbar-collapse collapse">
          <ul class="nav navbar-nav navbar-right">
		  	<li><a href="index.cfm">Dashboard</a></li>
            <li><a href="profile.cfm">Edit Profile</a></li>
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
			<p>To modify your information in our database, simply edit and submit the following form providing information about you, locations you can present at and your specialties or general speaking topics.</p> 
		  </div>
		</div>
		
		</cfif>
			
		<form class="form-horizontal" role="form" method="post" action="#CGI.SCRIPT_NAME#">
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
			<a href="change.cfm">Change Password</a>			
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
		  <label class="col-md-4 control-label" for="otherLocations">Locations</label>  
		  <div class="col-md-4">
		  <input id="otherLocations" name="otherLocations" placeholder="Online, Toronto, Paris" class="form-control input-md" type="text" value="#speakerObj.getLocations()#">
		  <span class="help-block">Enter location(s) separated by commas</span>  
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
			<label for="programs-4">
			  <input name="programs" id="programs-4" value="ACL" type="checkbox"<cfif speakerObj.getIsACL()> checked="checked"</cfif>>
			  Adobe Campus Leader (ACL)
			</label>
			</div>
		  <div class="checkbox">
			<label for="programs-5">
			  <input name="programs" id="programs-5" value="AET" type="checkbox"<cfif speakerObj.getIsAET()> checked="checked"</cfif>>
			  Adobe Education Trainer (AET)
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

		<!--- generate a random number set to sum for use with human validation --->
		<cfset firstNum = RandRange(1,16) />
		<cfset lastNum = RandRange(16,32) />
		<!--- calculate and encrypt the expected sum --->
		<cfset sumNum = APPLICATION.utils.dataEnc(value = (firstNum + lastNum), mode = 'form') />
		<!--- Text input--->
		<cfoutput>
		<div class="form-group">
		  <label class="col-md-4 control-label" for="capcha">What is #firstNum# + #lastNum#?</label>  
		  <div class="col-md-2">
		  <input id="capcha" name="capcha" placeholder="Add the two numbers" class="form-control input-sm" type="text">
		  <input type="hidden" name="ff#Hash('capcha')#" value="#sumNum#" />
		  </div>
		</div>
		</cfoutput>
				
		<!--- Button (Double) --->
		<div class="form-group">
		  <label class="col-md-4 control-label" for="submit"></label>
		  <div class="col-md-8">
			<button id="submit" name="btn_Submit" type="submit" class="btn btn-success">Update Profile</button>
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
