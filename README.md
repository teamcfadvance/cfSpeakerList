[![Build Status](https://travis-ci.org/teamcfadvance/cfSpeakerList.png?branch=master)](https://travis-ci.org/teamcfadvance/cfSpeakerList)
cfSpeakerList (BETA2)
=====================

A simple CFML application for managing a list of available speakers (e.g. for user groups, conferences, etc.). This application allows speakers to enter their information into a database, requires them to verify their email address and upon verification activates their listing in the database. The speaker can self-maintain their information to change details as needed, update their password, etc. Administrators can delete speakers and edit their information as needed. Any visitor to your site can then use the search or browse functions to search for speakers to contact about speaking at events.

*NEW*
Speaker requests are now logged in three ways - the number of requests a speaker has received, the number of requests a speaker has accepted and the number of requests the speaker has completed. When a speaker request email is sent, a link to accept the speaker request is included. This is currently only for tracking purposes, but may gain further purpose later.

X number of days (configurable) after an accepted request's event date has passed, the requestor can be sent a feedback request to give feedback about the speaker and the speaker can be sent a feedback request to give feedback about the event/venue.

Speaker request statistics and feedback can be displayed for the speaker on the speaker information page (or not, configurable).

--------

**COMPATABILITY**

Currently tested with:

* Adobe CF 9.0.2 and MySQL 5.x

--------

**SETUP**

* Import database SQL into MySQL 5.x database server
* Edit Application.cfc   ([generate encryption keys](http://www.dvdmenubacks.com/key.cfm)):

```ColdFusion
	<!--- set application variables --->
	<!--- NOTE: You must set up the datasource and three encryption keys  --->
	<!--- (create keys: http://www.dvdmenubacks.com/key.cfm), algorithms  --->
	<!--- (e.g. AES/CBC/PKCS5Padding) and encodings (e.g. BASE64, HEX)    --->
	<!--- before you run this application.                                --->
	<!---                                                                 --->
	<!--- NOTE: This application uses mappings to ensure access to core   --->
	<!--- components. You will need to check the Enable Per App Settings  --->
	<!--- option on the Settings page of the ColdFusion Administrator for --->
	<!--- this to work properly. Some (shared) hosting providers do not   --->
	<!--- allow per-application settings. In this case, you will need to  --->
	<!--- run this application in a root domain or sub-domain for access  --->
	<!--- to the private area to work.                                    --->
	<cfscript>
	    // datasource name set-up in your administrator
        APPLICATION.ds = "<datasource>";
    
        // encryption keys, algorithms and encodings
		APPLICATION.dbkey1 = '<key1>';
		APPLICATION.dbalg1 = '<alg1>';
		APPLICATION.dbenc1 = '<enc1>';
		APPLICATION.dbkey2 = '<key2>';
		APPLICATION.dbalg2 = '<alg2>';
		APPLICATION.dbenc2 = '<enc2>';
		APPLICATION.dbkey3 = '<key3>';
		APPLICATION.dbalg3 = '<alg3>';
		APPLICATION.dbenc3 = '<enc3>';
		
		// short site name, shown in page title
		APPLICATION.siteName = 'UGS List';
		
		// long site name, shown in header and on homepage
		APPLICATION.siteLongName = 'User Group Speaker List';
		
		// flag to turn debug on or off (true/false - useful for debugging, turn off for production)
		APPLICATION.debugOn = true;
		
		// name of the table where speakers are stored (DO NOT MODIFY)
		APPLICATION.iusTable = 'speakers';
		
		// name of column in table where speaker keys are stored (DO NOT MODIFY)
		APPLICATION.iusColumn = 'speakerKey';
		
		// email address shown as 'from' email when system sends out emails
		APPLICATION.fromEmail = 'nospam@ugslist.tld';
		
		// blind carbon copy - enter an email address to be copied on all email sent by the system
		APPLICATION.bccEmail = '';
		
		// email address where reports of abuse are sent
		APPLICATION.abuseEmail = 'abuse@ugslist.tld';
		
		// number of hours before verification emails become invalid
		APPLICATION.verificationTimeout = 12;
		
		// name of the session id cookie maintained by cfSpeakerList
		APPLICATION.cookieName = 'cfslid';
		
		// number of minutes before a session becomes inactive
		APPLICATION.sessionTimeout = 30; 

		// flag (true/false) to send feedback request emails and display feedback for speakers (to requestor)
		APPLICATION.sendSpeakerFeedbackRequests = true;

		// flag (true/false) to send feedback request emails for events (to speaker)
		APPLICATION.sendEventFeedbackRequests = true;

		// number of days after an event to send the feedback request(s)
		APPLICATION.daysToFeedbackRequest = 2;

		// flag (true/false) to display request statistics for speakers
		APPLICATION.showRequestStats = true;
```

* Add an admin account (see [this gist](https://gist.github.com/ddspringle/9335942) for an example)
* Start notifying speakers they can sign up!

--------

**DEMO**

You can view a live demo of this code at [cfSpeakerList Demo](http://ugslist.dvdmenubacks.com)

--------

**BUG REPORTING**

If you find any problems with this code, please add a new issue to this GitHub repository and we will address them as best we can.


