<cfcomponent extends="bricksLib.core.eventHandler" output="false">

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

	<cffunction name="setContentView" access="private" returntype="void">
		<cfargument name="page" type="any" required="true" />
		<cfargument name="params" type="struct" required="false" default="#structNew()#" />

		<!--- load the page --->
		<cfset var renderer = getService("homePortals").load(page) />

		<!--- add some useful properties --->
		<cfset renderer.getPage().setProperty("appRoot", getSetting("bricks.appRoot"))>
		<cfset renderer.getPage().setProperty("libRoot", request.libRoot)>

		<!--- pass values for rendering --->
		<cfset setValue("pageParams", params)>
		<cfset setValue("renderer", renderer) />
		
		<!--- set the layout that knows how to render homePortals pages --->
		<cfset setLayout("renderer")>
	</cffunction>
	
</cfcomponent>