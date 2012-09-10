<cfcomponent extends="bricksApp.lib.core.eventHandler" output="false">

	<cffunction name="checkLoggedInUser" access="private" returnType="void">
		<cfargument name="noLoggedInEvent" type="string" required="false" default="admin.login">
		<cfset var usm = getService("userSessionManager")>
		<cfif !usm.isLoggedIn()>
			<cfset setNextEvent(noLoggedInEvent)>
		</cfif>
		<cfset setValue("currentUser", usm.getUser())>
	</cffunction>
	
	<cffunction name="setAdminView" access="private" returntype="void">
		<cfargument name="viewName" type="string" required="true" />
		<cfset var hp = getService("homePortals") />
		<cfset var resourceTypes = hp.getResourceLibraryManager().getResourceTypes() />
		<cfset setValue("resourceTypes", resourceTypes) />		
		<cfset setValue("appRoot", getSetting("bricks.appRoot")) />
		<cfset setView("admin/" & viewName) />
		<cfset setLayout("admin") />
	</cffunction>

	<cffunction name="setCustomView" access="private" returntype="void">
		<cfargument name="viewName" type="string" required="true" />
		<cfargument name="pageTitle" type="string" required="false" default="" />
		<cfset setValue("pageTitle", arguments.pageTitle) />		
		<cfset setView(viewName) />
		<cfset setLayout("custom") />
	</cffunction>
	
</cfcomponent>