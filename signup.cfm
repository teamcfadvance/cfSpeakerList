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

<!--- set a null error message to check for later --->
<cfset errorMsg = '' />

<!--- check if the form was submitted --->
<cfif IsDefined('FORM.btn_Submit')>

	<!--- it was, sanitize the form values --->
	<cfset saniForm = APPLICATION.utils.sanitize(FORM) />

	<!--- process required fields --->
	<cfset reqCheck = APPLICATION.utils.checkRequired(
		fields = {
			email 		= saniForm.email,
			vPassword	= saniForm.vPassword,
			password 	= saniForm.password,
			fName 		= saniForm.fName,
			lName 		= saniForm.lName,
			countries 	= saniForm.countries,
			specialties = saniForm.specialties,
			capcha 		= saniForm.capcha
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
	
	<!--- check if this username (email) already exists --->
	<cfset userExists = APPLICATION.userDAO.checkIfUserExists(saniForm.email) />
	
	<!--- check if the user already exists --->
	<cfif userExists>
		<!--- user already exists, set an error message to display --->
		<cfset errorMsg = '<p>We&apos;re sorry, but you&apos;re email is already in use on our system. If you already have an account, please <a href="login.cfm">log in</a>. If you have forgotten your password, you can <a href="reset.cfm">reset your password</a>. If you suspect your information has been used without your knowledge, please <a href="abuse.cfm">report abuse</a>.</p>' />
	</cfif> 
	
	<!--- check if the password and verification password match --->
	<cfif NOT Find(saniForm.password,saniForm.vPassword)>
		<!--- password mismatch, set an error message to display --->
		<cfset errorMsg = '<p>We&apos;re sorry, but your password and verification password do not match. Please try again.</p>' />
	</cfif> 
	
	<!--- check the password meets complexity requirements --->
	<cfif NOT ReFind('[a-z]',saniForm.password) OR NOT ReFind('[A-Z]',saniForm.password) OR NOT ReFind('[0-9]',saniForm.password) OR NOT Len(saniForm.password) GTE 8>
		<!--- password doesn't meet complexity requirements, set an error message to display --->
		<cfset errorMsg = '<p>We&apos;re sorry, but your password does not meet complexity requirements for this system. Your password must be at least eight (8) characters long, and contain at least one lowercase (a through z), uppercase (A through Z) and number (0 through 9) to be accepted. Please try again.</p>' />
	</cfif> 
	
	<!--- check if phone was provided, if it is numeric after filtering out non-numeric chars and is at least 10 digits long --->
	<cfif Len(saniForm.phone) AND (NOT IsNumeric(ReReplace(saniForm.phone,'[^0-9]','','ALL')) OR NOT Len(ReReplace(saniForm.phone,'[^0-9]','','ALL')) GTE 10)>
		<!--- password doesn't meet complexity requirements, set an error message to display --->
		<cfset errorMsg = '<p>We&apos;re sorry, but your phone number must contain only (, ), +, -, [space] and 0-9 characters and must contain at least 10 digits. Please try again.</p>' />
	</cfif> 
	
	<!--- ensure we have no errors --->
	<cfif NOT Len(errorMsg)>	
		
		<!--- no errors, create and populate a user object --->
		<cfset userObj = createObject('component','core.beans.User').init(
			userId  	= 0,
			username	= saniForm.email,
			password	= LCase(Hash(saniForm.password,'SHA-384')),
			role    	= 'speaker',
			isActive	= 0
		) />
		
		<!--- and save the user --->
		<cfset userObj.setUserId(APPLICATION.userDAO.saveUser(userObj)) />
		
		<!--- get a new key for the speaker --->
		<cfset thisSpeakerKey = APPLICATION.iusUtil.getShortUrl(
			table		= APPLICATION.iusTable,
			column		= APPLICATION.iusColumn,
			keyLength	= 8,
			method		= 'alphanum'
		) />
		
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
		
		<!--- create and populate a speaker object --->
		<cfset speakerObj = createObject('component','core.beans.Speaker').init(
			speakerId  	= 0,
			speakerKey	= thisSpeakerKey,
			userId     	= userObj.getUserId(),
			firstName  	= saniForm.fName,
			lastName   	= saniForm.lName,
			email      	= saniForm.email,
			phone      	= formattedPhone,
			showPhone	= saniForm.showPhone,
			twitter    	= saniForm.twitter,
			showTwitter	= saniForm.showTwitter,
			specialties	= saniForm.specialties,
			locations  	= thisSpeakerLocs,
			isACP      	= (ListFindNoCase(saniForm.programs,'acp') ? 1 : 0),
			isAEL      	= (ListFindNoCase(saniForm.programs,'ael') ? 1 : 0),
			isUGM      	= (ListFindNoCase(saniForm.programs,'ugm') ? 1 : 0),
			isOther    	= (ListFindNoCase(saniForm.programs,'other') ? 1 : 0)
		) />
		
		<!--- and save the speaker object --->	
		<cfset speakerObj.setSpeakerId(APPLICATION.speakerDAO.saveSpeaker(speakerObj)) />
		
		<!--- send verification email --->
		<cfset APPLICATION.utils.emailVerification(email = saniForm.email, key = thisSpeakerKey) />
		
		<!--- redirect to verification form --->
		<cflocation url="vid.cfm" addtoken="false" />
	
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
    <!----<link rel="shortcut icon" href="../../assets/ico/favicon.ico">---->

    <title><cfoutput>#APPLICATION.siteName#</cfoutput> &raquo; Speaker Sign-Up</title>

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
          <a class="navbar-brand" href="index.cfm"><cfoutput>#APPLICATION.siteLongName#</cfoutput></a> <span class="navbar-brand">&raquo; Speaker Sign Up</span>
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
		  <div class="panel-heading">An Error Occurred Processing Your Sign Up</div>
		  <div class="panel-body">
			#errorMsg#
		  </div>
		</div>
		
		<cfelse>
		
		<div class="panel panel-primary">
		  <div class="panel-heading">Speaker Sign Up Form</div>
		  <div class="panel-body">
			<p>To add your information to our database, simply fill out and submit the following form providing information about you, locations you can present at and your specialties or general speaking topics.</p> 
		  </div>
		</div>
		
		</cfif>
			
		<form class="form-horizontal" role="form" id="signup" method="post" action="#CGI.SCRIPT_NAME#">
		<fieldset>
		
		<!--- Form Name --->
		<legend>Speaker Sign Up Form</legend>
		
		<!--- Text input--->
		<div class="form-group">
		  <label class="col-md-4 control-label" for="email">Email</label>  
		  <div class="col-md-4">
		  <input id="email" name="email" placeholder="someone@someplace.com" class="form-control input-md" required autofocus type="email" value="#FORM.email#">
		  <span class="help-block">Used to login and receive contacts, never shared publicly</span>  
		  </div>
		</div>
		
		<!--- Password input--->
		<div class="form-group">
		  <label class="col-md-4 control-label" for="password">Password</label>
		  <div class="col-md-4">
			<input id="password" name="password" placeholder="Min 8 chars using each of a-z, A-Z and 0-9" class="form-control input-md" required type="password">
		  </div>
		</div>
		
		<!--- Password input--->
		<div class="form-group">
		  <label class="col-md-4 control-label" for="vPassword">Verify Password</label>
		  <div class="col-md-4">
			<input id="vPassword" name="vPassword" placeholder="As entered above" class="form-control input-md" required type="password">
		  </div>
		</div>
		
		<!--- Text input--->
		<div class="form-group">
		  <label class="col-md-4 control-label" for="fName">First Name</label>  
		  <div class="col-md-4">
		  <input id="fName" name="fName" placeholder="John" class="form-control input-md" required type="text" value="#FORM.fName#">
			
		  </div>
		</div>
		
		<!--- Text input--->
		<div class="form-group">
		  <label class="col-md-4 control-label" for="lName">Last Name</label>  
		  <div class="col-md-4">
		  <input id="lName" name="lName" placeholder="Doe" class="form-control input-md" required type="text" value="#FORM.lName#">
			
		  </div>
		</div>
		
		<!--- Prepended checkbox --->
		<div class="form-group">
		  <label class="col-md-4 control-label" for="phone">Telephone</label>
		  <div class="col-md-4">
			<div class="input-group">
			  <span class="input-group-addon">     
				  <input type="checkbox" name="showPhone" value="1"<cfif FORM.showPhone> checked="checked"</cfif>>     
			  </span>
			  <input id="phone" name="phone" class="form-control" placeholder="(999) 999-9999" type="tel" value="#FORM.phone#">
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
				  <input checked="checked" type="checkbox" name="showTwitter" value="1">     
			  </span>
			  <input id="twitter" name="twitter" class="form-control" placeholder="@myhandle" type="text" value="#FORM.twitter#">
			</div>
			<p class="help-block">Optional, check box to show publicly</p>
		  </div>
		</div>
		
		<!--- Select Multiple --->
		<div class="form-group">
		  <label class="col-md-4 control-label" for="country">Countries</label>
		  <div class="col-md-4">
			<select id="countries" name="countries" class="form-control" multiple="multiple">
			<cfloop query="qGetCountries">
				<option value="#qGetCountries.country#"<cfif (ListFindNoCase(FORM.countries,qGetCountries.country)) OR (NOT ListLen(FORM.countries) AND FindNoCase('united states',qGetCountries.country) AND NOT FindNoCase('united states minor',qGetCountries.country))> selected="selected"</cfif>>#qGetCountries.country#</option>
			</cfloop>
			</select>
			<p class="help-block">Select primary countries where you can present</p>
		  </div>
		</div>
		
		<!--- Select Multiple --->
		<div class="form-group">
		  <label class="col-md-4 control-label" for="states">If US, Select State(s)</label>
		  <div class="col-md-4">
			<select id="states" name="states" class="form-control" multiple="multiple">
			<cfloop query="qGetStates">
				<option value="#qGetStates.state#"<cfif ListFindNoCase(FORM.states,qGetStates.state)> selected="selected"</cfif>>#qGetStates.state#</option>
			</cfloop>
			</select>
			<p class="help-block">Select primary states where you can present</p>
		  </div>
		</div>
		
		<!--- Text input--->
		<div class="form-group">
		  <label class="col-md-4 control-label" for="otherLocations">Other Locations</label>  
		  <div class="col-md-4">
		  <input id="otherLocations" name="otherLocations" placeholder="Online, Toronto, Paris" class="form-control input-md" type="text" value="#FORM.otherLocations#">
		  <span class="help-block">Enter other location(s) seperated by commas</span>  
		  </div>
		</div>
		
		<!--- Textarea --->
		<div class="form-group">
		  <label class="col-md-4 control-label" for="specialties">Specialties/Speaking Topics</label>
		  <div class="col-md-4">                     
			<textarea class="form-control" id="specialties" name="specialties"><cfif Len(FORM.specialties)>#FORM.specialties#<cfelse>HTML5, CSS3, CFML, Web Design</cfif></textarea>
		  <span class="help-block">Enter your specialties seperated by commas</span>  
		  </div>
		</div>
		
		<!--- Multiple Checkboxes --->
		<div class="form-group">
		  <label class="col-md-4 control-label" for="programs">I am an</label>
		  <div class="col-md-4">
		  <div class="checkbox">
			<label for="programs-0">
			  <input name="programs" id="programs-0" value="ACP" type="checkbox"<cfif ListFindNoCase(FORM.programs,'acp')> checked="checked"</cfif>>
			  Adobe Community Professional (ACP)
			</label>
			</div>
		  <div class="checkbox">
			<label for="programs-1">
			  <input name="programs" id="programs-1" value="AEL" type="checkbox"<cfif ListFindNoCase(FORM.programs,'ael')> checked="checked"</cfif>>
			  Adobe E-Learning Professional (AEL)
			</label>
			</div>
		  <div class="checkbox">
			<label for="programs-2">
			  <input name="programs" id="programs-2" value="UGM" type="checkbox"<cfif ListFindNoCase(FORM.programs,'ugm')> checked="checked"</cfif>>
			  Adobe User Group Manager (UGM)
			</label>
			</div>
		  <div class="checkbox">
			<label for="programs-3">
			  <input name="programs" id="programs-3" value="Other" type="checkbox"<cfif ListFindNoCase(FORM.programs,'other')> checked="checked"</cfif>>
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
			<button id="submit" name="btn_Submit" type="submit" class="btn btn-success">Finish Sign Up</button>
			<button id="reset" name="btn_Reset" type="reset" class="btn btn-danger">Clear Form</button>
		  </div>
		</div>
		
		</fieldset>
		</form>
	  </cfoutput>
		</div>
	  </div>

      <hr>

      <cfinclude template="includes/footer.cfm" />
    </div> <!--- /container --->

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
	<script src="http://ajax.aspnetcdn.com/ajax/jquery.validate/1.11.1/jquery.validate.min.js"></script>
    <script src="js/bootstrap.min.js"></script>	
	<script type="text/javascript">
		$(function() {
			
			$('#signup').validate({
				errorClass: 'text-danger',
				rules: {
					fName: {
						required: true,
						minlength: 2,
						maxlength: 75
					},
					lName: {
						required: true,
						minlength: 2,
						maxlength: 75
					},
					password: {
						required: true,
						minlength: 8,
						maxlength: 20
					},
					vPassword: {
						equalTo: '#password'
					},
					email: {
						required: true,
						email: true	
					},
					otherLocations: {
						maxlength: 255
					},
					specialties: {
						required: true,
						minlength: 5,
						maxlength: 512
					},
					capcha: {
						required: true,
						digits: true,
						maxlength: 2
					}
				},
				messages: {
					fName: {
						required: 'Please specify your first name.',
						minlength: 'Your first name must be at least 2 characters.',
						maxlength: 'Your first name must not exceed 75 characters.'
					},
					lName: {
						required: 'Please specify your last name.',
						minlength: 'Your last name must be at least 2 characters.',
						maxlength: 'Your last name must not exceed 75 characters.'
					},
					password: {
						required: 'Please specify a password.',
						minlength: 'Your password must be at least 8 characters.',
						maxlength: 'Your password must not exceed 20 characters.'
					},
					vPassword: {
						equalTo: 'Your verification password does not match.'
					},
					email: {
						required: 'Please specify your email address',
						email: 'Your email address should be in the format: someone@someplace.tld.'	
					},
					otherLocations: {
						maxlength: 'Your other locations must not exceed 255 characters.'
					},
					specialties: {
						required: 'Please specity your specialties/speaking topics.',
						minlength: 'Your specialties must be at least 5 characters.',
						maxlength: 'Your specialties must not exceed 512 characters.'
					},
					capcha: {
						required: 'Please add the two numbers and enter the sum in this field.',
						digits: 'You must only enter the digits 0 through 9.',
						maxlength: 'The sum should not exceed two digits.'
					}
				}
				
			});
		});
	</script>
  </body>
</html>