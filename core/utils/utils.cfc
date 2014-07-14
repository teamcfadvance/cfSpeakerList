<cfcomponent displayname="utils">

	<!--- DATA ENCRYPTION --->
	<cffunction name="dataEnc" access="public" returntype="string">
		<cfargument name="value" type="string" required="yes" hint="I am the value to encrypt for the database." />
		<cfargument name="mode" type="string" required="false" default="db" />
		
		<!--- var scope --->
		<cfset var onePass = '' />
		<cfset var twoPass = '' />
		<cfset var lastPass = '' />
		
		<!--- check if the passed value has length --->
		<cfif Len(ARGUMENTS.value)>
		
			<!--- it does, check if the mode of the encryption is 'db' --->
			<cfif FindNoCase('db',ARGUMENTS.mode)>
			
				<!--- using database encryption, encrypt with the first set of keys and algorithm --->
				<cfset onepass = Encrypt(ARGUMENTS.value,APPLICATION.dbkey1,APPLICATION.dbalg1,APPLICATION.dbenc1) />
				<!--- and again with the second set of keys and algorithm --->
				<cfset twopass = Encrypt(onepass,APPLICATION.dbkey2,APPLICATION.dbalg2,APPLICATION.dbenc2) />
				<!--- and again with the third set of keys and algorithm --->
				<cfset lastPass = Encrypt(twopass,APPLICATION.dbkey3,APPLICATION.dbalg3,APPLICATION.dbenc3) />
				<!--- NOTE: Add additional passes here for greater security --->
				
			<!--- otherwise, check if the mode of the encryption is 'repeatable' --->
			<cfelseif FindNoCase('repeatable',ARGUMENTS.mode)>
			
				<!--- using database encryption, encrypt with the first set of keys and algorithm --->
				<cfset onepass = Encrypt(ARGUMENTS.value,APPLICATION.dbkey1,'AES',APPLICATION.dbenc1) />
				<!--- and again with the second set of keys and algorithm --->
				<cfset twopass = Encrypt(onepass,APPLICATION.dbkey2,'BLOWFISH',APPLICATION.dbenc2) />
				<!--- and again with the third set of keys and algorithm --->
				<cfset lastPass = Encrypt(twopass,APPLICATION.dbkey3,'AES',APPLICATION.dbenc3) />
				<!--- NOTE: Add additional passes here for greater security --->
			
			<!--- otherwise, check if the mode of the encryption is 'url' --->
			<cfelseif FindNoCase('url',ARGUMENTS.mode)>
				
				<!--- using url encryption, check if useing BASE64 encoding on the URL key --->
				<cfif FindNoCase('BASE64',APPLICATION.dbenc1)>
				
					<!--- encrypt with the first set of keys and repeatable algorithm --->
					<cfset lastPass = Encrypt(ARGUMENTS.value,APPLICATION.dbkey1,'AES',APPLICATION.dbenc1) />
					<!--- using BASE64 encoding, URL decode the value --->
					<cfset lastPass = URLEncodedFormat(lastPass) />
				
				<!--- otherwise --->
				<cfelse>
				
					<!--- not BASE64 encoded, encrypt with the first set of keys and algorithm --->
					<cfset lastPass = Encrypt(ARGUMENTS.value,APPLICATION.dbkey1,APPLICATION.dbalg1,APPLICATION.dbenc1) />
				
				<!--- end checking if useing BASE64 encoding on the URL key --->	
				</cfif>	
				
			<!--- otherwise, check if the mode of the encryption is 'form' --->
			<cfelseif FindNoCase('form',ARGUMENTS.mode)>
			
				<!--- using form encryption, encrypt with the second set of keys and algorithm --->
				<cfset lastPass = Encrypt(ARGUMENTS.value,APPLICATION.dbkey2,APPLICATION.dbalg2,APPLICATION.dbenc2) />
				
			<!--- otherwise, check if the mode of the encryption is 'cookie' --->
			<cfelseif FindNoCase('cookie',ARGUMENTS.mode)>
			
				<!--- using cookie encryption, encrypt with the first set of keys and algorithm --->
				<cfset lastPass = Encrypt(ARGUMENTS.value,APPLICATION.dbkey3,APPLICATION.dbalg3,APPLICATION.dbenc3) />
			
			<!--- end checking if the mode of the encryption is 'db', 'url', 'form' or 'cookie' --->	
			</cfif>
		
		<!--- end checking if the passed value has length --->
		</cfif>
		
		<!--- return the encrypted value (or null if passed value has no length) --->
		<cfreturn lastPass>
	</cffunction>

	<!--- DATA DECRYPTION --->
	<cffunction name="dataDec" access="public" returntype="string">
		<cfargument name="value" type="string" required="yes" hint="I am the value to decrypt for the database.">
		<cfargument name="mode" type="string" required="false" default="db" />

		<!--- var scope --->
		<cfset var onePass = '' />
		<cfset var twoPass = '' />
		<cfset var lastPass = '' />
		
		<!--- check if the passed value has length --->
		<cfif Len(ARGUMENTS.value)>
		
			<!--- it does, check if the mode of the encryption is 'db' --->
			<cfif FindNoCase('db',ARGUMENTS.mode)>
	
				<!--- NOTE: Add additional passes here for greater security --->
				<!--- using database encryption, decrypt with the third set of keys and algorithm --->
				<cfset var onePass = Decrypt(ARGUMENTS.value,APPLICATION.dbkey3,APPLICATION.dbalg3,APPLICATION.dbenc3) />
				<!--- and again with the second set of keys and algorithm --->
				<cfset var twoPass = Decrypt(onepass,APPLICATION.dbkey2,APPLICATION.dbalg2,APPLICATION.dbenc2) />
				<!--- and again with the first set of keys and algorithm --->
				<cfset var lastPass = Decrypt(twopass,APPLICATION.dbkey1,APPLICATION.dbalg1,APPLICATION.dbenc1) />
		
			<!--- otherwise, check if the mode of the encryption is 'repeatable' --->
			<cfelseif FindNoCase('repeatable',ARGUMENTS.mode)>
	
				<!--- NOTE: Add additional passes here for greater security --->
				<!--- using database encryption, decrypt with the third set of keys and algorithm --->
				<cfset var onePass = Decrypt(ARGUMENTS.value,APPLICATION.dbkey3,'AES',APPLICATION.dbenc3) />
				<!--- and again with the second set of keys and algorithm --->
				<cfset var twoPass = Decrypt(onepass,APPLICATION.dbkey2,'BLOWFISH',APPLICATION.dbenc2) />
				<!--- and again with the first set of keys and algorithm --->
				<cfset var lastPass = Decrypt(twopass,APPLICATION.dbkey1,'AES',APPLICATION.dbenc1) />
			
			<!--- otherwise, check if the mode of the encryption is 'url' --->
			<cfelseif FindNoCase('url',ARGUMENTS.mode)>
				
				<!--- using url encryption, check if useing BASE64 encoding on the URL key --->
				<cfif FindNoCase('BASE64',APPLICATION.dbenc1)>
				
					<!--- using BASE64 encoding, URL decode the value --->
					<cfset ARGUMENTS.value = URLDecode(ARGUMENTS.value) />
					<!--- replace spaces with + --->
					<cfset ARGUMENTS.value = Replace(ARGUMENTS.value,chr(32),'+','ALL') />
					<!--- decrypt with the first set of keys and repeatable algorithm --->
					<cfset lastPass = Decrypt(ARGUMENTS.value,APPLICATION.dbkey1,'AES',APPLICATION.dbenc1) />
				
				<!--- otherwise --->
				<cfelse>
				
					<!--- not BASE64 encoded, decrypt with the first set of keys and algorithm --->
					<cfset lastPass = Decrypt(ARGUMENTS.value,APPLICATION.dbkey1,APPLICATION.dbalg1,APPLICATION.dbenc1) />
				
				<!--- end checking if useing BASE64 encoding on the URL key --->	
				</cfif>			
				
			<!--- otherwise, check if the mode of the encryption is 'form' --->
			<cfelseif FindNoCase('form',ARGUMENTS.mode)>
			
				<!--- using form encryption, decrypt with the second set of keys and algorithm --->
				<cfset lastPass = Decrypt(ARGUMENTS.value,APPLICATION.dbkey2,APPLICATION.dbalg2,APPLICATION.dbenc2) />
				
			<!--- otherwise, check if the mode of the encryption is 'cookie' --->
			<cfelseif FindNoCase('cookie',ARGUMENTS.mode)>
			
				<!--- using cookie encryption, decrypt with the first set of keys and algorithm --->
				<cfset lastPass = Decrypt(ARGUMENTS.value,APPLICATION.dbkey3,APPLICATION.dbalg3,APPLICATION.dbenc3) />
			
			<!--- end checking if the mode of the encryption is 'db', 'url', 'form' or 'cookie' --->	
			</cfif>
		
		<!--- end checking if the passed value has length --->
		</cfif>

		<!--- return the decrypted value (or null if passed value has no length) --->
		<cfreturn lastPass>
	</cffunction>
	
	<!--- GLOBAL ERROR HANDLER --->
	<cffunction name="errorHandler" access="public" returntype="void" output="true">
		<cfargument name="errorData" type="any" required="true" hint="I am the struct returned by cfcatch." />
		<cfargument name="debug" type="boolean" required="false" default="#APPLICATION.debugOn#" hint="I determine whether to fail gracefully or output debug." />
		
		<!--- var scope --->
		<cfset var errorDetail = '' />
		
		<!--- dump the error as text to a variable --->
		<cfsavecontent variable="errorDetail">
			<cfdump var="#errorData#" format="text" />
		</cfsavecontent>
		
		<!--- log the error --->
		<cflog text="ERROR: #errorDetail#" type="Information" file="#APPLICATION.applicationName#" thread="yes" date="yes" time="yes" application="yes">
		
		<!--- check if we're failing gracefully --->
		<cfif NOT ARGUMENTS.debug>
		
			<!--- we are, output an error message --->
			<script type="text/javascript">
				document.removeChild(document.documentElement);
			</script>
			<h1>We're sorry but an error has occurred. Please refresh your browser to try again.</h1>
			
		<!--- otherwise --->
		<cfelse>
		
			<!--- dump the error to the screen --->
			<cfdump var="#ARGUMENTS.errorData#" label="ERROR DATA (CFCATCH)" />
			<!--- and abort --->
			<cfabort>
		
		<!--- end checking if we're failing gracefully --->
		</cfif>	
		
	</cffunction>

	<!--- SANITIZE FORM VALUES --->
	<cffunction name="sanitize" access="public" returntype="struct" output="false" hint="I sanitize data passed in a FORM scope using either ESAPI or HTMLEditFormat().">
		<cfargument name="formData" type="struct" required="true" hint="I am the FORM struct." />
		
		<!--- var scope --->
		<cfset var formField = '' />
		<cfset var returnStruct = StructNew() />
		
		<!--- loop through the FORM fields provided --->
		<cfloop collection="#ARGUMENTS.formData#" item="formField">
			<!--- check if any script tags were provided in this form value --->
			<cfif ReFindNoCase('(\<invalidtag|\<script)',ARGUMENTS.formData[formfield])>
				<!--- invalid tags found, clear this field completely --->
				<cfset returnStruct[formfield] = '' />				
			<!--- check if this is a known value (boolean, numeric, date, email or password) --->
			<cfelseif IsBoolean(ARGUMENTS.formData[formfield]) OR IsNumeric(ARGUMENTS.formData[formfield]) OR IsDate(ARGUMENTS.formData[formfield]) OR ReFindNoCase('^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,12}$',ARGUMENTS.formData[formField]) OR FindNoCase('password',formField)>
				<!--- it is, so just add it to the return struct --->
				<cfset returnStruct[formfield] = ARGUMENTS.formData[formfield] />
			<!--- otherwise --->
			<cfelse>
				<!--- not boolean or numeric, check if we're using ESAPI --->
				<cfif APPLICATION.useESAPI>
					<!--- we are, process the form field through ESAPI --->
					<cfset returnStruct[formField] = APPLICATION.esapiEncoder.encodeForHTML(ARGUMENTS.formData[formfield]) />
				<!--- otherwise --->
				<cfelse>
					<!--- we're not using ESAPI, process the form field through HTMLEditFormat() --->
					<cfset returnStruct[formField] = HTMLEditFormat(ARGUMENTS.formdata[formfield]) />
				<!--- end checking if we're using ESAPI --->
				</cfif>
			<!--- end checking if this is a boolean or numeric value --->
			</cfif>
		<!--- end looping through the FORM fields provided --->
		</cfloop> 
		
		<!--- return the sanitzed form values --->
		<cfreturn returnStruct />
		
	</cffunction>
	
	<!--- DECODE STORED VALUES --->
	<cffunction name="decodeVal" access="public" returntype="string" output="false" hint="I decode HTML encoded with ESAPI.">
		<cfargument name="value" type="string" required="true" hint="I am the string to decode." />
		
			<!--- var scope --->
			<cfset var decodedValue = '' />
		
			<!--- check if we're using ESAPI --->
			<cfif APPLICATION.useESAPI>
				<!--- we are, decode the value through ESAPI --->
				<cfset decodedValue = APPLICATION.esapiEncoder.decodeForHTML(ARGUMENTS.value) />
			<!--- otherwise --->
			<cfelse>
				<!--- we're not using ESAPI, simply return the value --->
				<cfset decodedValue = ARGUMENTS.value />
			<!--- end checking if we're using ESAPI --->
			</cfif>
		
		<!--- return the sanitzed form values --->
		<cfreturn decodedValue />
		
	</cffunction>	
	
	<!--- CHECK REQUIRED FIELDS --->
	<cffunction name="checkRequired" access="public" returntype="struct" output="false" hint="I take a struct of fields and values and ensure they are not blank (null).">
		<cfargument name="fields" type="struct" required="true" hint="I am a struct of the fields to check." />
		
		<!--- var scope --->
		<cfset var formField = '' />
		<cfset var returnStruct = StructNew() />
		
		<!--- set the result of this check to true by default (all required fields provide values) --->
		<cfset returnStruct.result = true />
		<cfset returnStruct.fields = '' />
		
		<!--- loop through the passed in struct --->
		<cfloop collection="#ARGUMENTS.fields#" item="formField">
			<!--- check if this field has length --->
			<cfif NOT Len(ARGUMENTS.fields[formField])>
				<!--- it doesn't have a length, add it to the list of fields that did not provide value) --->
				<cfset returnStruct.fields = ListAppend(returnStruct.fields,formField) />
				<!--- and se the result of this check to false (not all required fields provide values) --->
				<cfset returnStruct.result = false />
			<!--- end checking if this field has length --->
			</cfif>
		<!--- end looping through the passed in struct --->
		</cfloop>
		
		<!--- return the results of the required check (true/false and any missing fields) --->
		<cfreturn returnStruct />
		
	</cffunction>
	
	<!--- EMAIL VERIFICATION --->
	<cffunction name="emailVerification" access="public" returntype="void" output="false" hint="I send an email to the user to validate their email address.">
		<cfargument name="email" type="string" required="true" hint="I am the email address of the user to send the verification email to." />
		<cfargument name="key" type="string" required="true" hint="I am the key assigned to this speaker - used to verify their email address." />
		
		<!--- var scope --->
		<cfset var ts = APPLICATION.utils.dataEnc(Now(), 'cookie') />
		<cfset var cR = Chr(10) & Chr(13) />
		
		<!--- send verification email to recipient --->
		<cfmail to="#ARGUMENTS.email#" from="#APPLICATION.fromEmail#" subject="#APPLICATION.siteName# Email Verification" bcc="#APPLICATION.bccEmail#" charset="utf-8">
		 <cfmailpart type="html">
		 	<h4>#APPLICATION.siteName# Email Verification</h4>
			<p>You, or someone you know, has entered your information into our database as a speaker. Before we can publish your information, we need to verify that you have made this request to be published in our database by clicking on the following link within the next #APPLICATION.verificationTimeout# hours:</p>
			<p><a href="http://#CGI.HTTP_HOST#/vid.cfm/#ARGUMENTS.key#/#ts#">http://#CGI.HTTP_HOST#/vid.cfm/#ARGUMENTS.key#/#ts#</a></p>
			<p>If you did not wish your information to be published, you do not need to take any action.</p>
			<p>&nbsp;</p>
			<p>Sincerely,<br />The #APPLICATION.siteName# Team</p>
		 </cfmailpart>
		 <cfmailpart type="plain">
			#APPLICATION.siteName# Email Verification#cR##cR#
			You, or someone you know, has entered your information into our database as a speaker.#cR#
			Before we can publish your information, we need to verify that you have made this request#cR#
			to be published in our database by clicking on the following link within the next #APPLICATION.verificationTimeout# hours:#cR##cR#
			http://#CGI.HTTP_HOST#/vid.cfm/#ARGUMENTS.key#/#ts##cR##cR#
			If you did not wish your information to be published, you do not need to take any action.#cR##cR#
			Sincerely,#cR#
			The #APPLICATION.siteName# Team#cR##cR#
		 </cfmailpart>
		</cfmail>	
	
	</cffunction>
	
	<!--- GENERATE SESSION ID --->
	<cffunction name="generateSessionId" access="public" returntype="string" output="false" hint="I generate a unique session id.">
	
		<!--- return a triple hash of CreateUUID() --->
		<cfreturn Hash(Hash(Hash(CreateUUID(),'SHA-512'),'SHA-384'),'SHA-256') />
		
	</cffunction>
	
	<!--- GENERATE PASSWORD --->
	<cffunction name="generatePassword" access="public" returntype="string" output="false" hint="I generate a random password.">
	
		<!--- var scope --->
		<cfset var alphaNum = 'a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,0,1,2,3,4,5,6,7,8,9' />
		<cfset var newPass = '' />
		<cfset var iX = 0 />
		
		<!--- loop from 8 to 12 times --->
		<cfloop from="1" to="#RandRange(8,12)#" index="iX">
			<!--- add a random character from the alphaNum list to build the new password --->
			<cfset newPass = newPass & ListGetAt(alphaNum,RandRange(1,ListLen(alphaNum))) />
		</cfloop>
		
		<!--- return the new password --->
		<cfreturn newPass />
		
	</cffunction>
	
	<!--- FORMAT PHONE --->
	<cffunction name="formatPhone" access="public" returntype="string" output="false" hint="I format a phone number for various country formats.">
		<cfargument name="phone" type="string" required="true" hint="I am the phone number as input by the user.">
		
		<!--- var scope --->
		<cfset var phoneDigits = ReReplace(ARGUMENTS.phone,'[^0-9]','','ALL') />
		<cfset var returnPhone = '' />
		
		<!--- switch on the length of the phone number digits (0-9) --->
		<cfswitch expression="#Len(phoneDigits)#">
		
			<!--- United States --->
			<cfcase value="10">
			
				<!--- format phone as (XXX) XXX-XXXX --->
				<cfset returnPhone = '(' & Left(phoneDigits,3) & ') ' & Mid(phoneDigits,4,3) & '-' & Right(phoneDigits,4) />
				
			</cfcase>
			
			<!--- DEFAULT (UNKNOWN) --->
			<cfdefaultcase>
			
				<!--- no formatting, return value sent to function --->
				<cfset returnPhone = ARGUMENTS.phone />
				
			</cfdefaultcase>
		
		</cfswitch>
		
		<!--- return the formatted phone number --->
		<cfreturn returnPhone />
		
	</cffunction>
		
</cfcomponent>