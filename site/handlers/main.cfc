<cfcomponent extends="core.eventHandler" output="false">

	<cffunction name="home" output="false">
		<cfset var route = getValue("page") />

		<!--- parse the current route to obtain which page we need to load --->
		<cfset var routeInfo = getService("routeParser").parse("default", route) />

		<!--- load the page --->
		<cfset var renderer = getService("homePortals").loadPage(routeInfo.page) />

		<!--- pass values for rendering --->
		<cfset setValue("pageParams", routeInfo.params)>
		<cfset setValue("renderer", renderer) />
	</cffunction>

</cfcomponent>