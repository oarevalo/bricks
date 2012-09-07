<cfcomponent extends="core.eventHandler" output="false">

	<cffunction name="home" output="false">
		<cfset var route = getValue("page") />
		<cfset var hp = getService("homePortals") />
		<cfset var parser = getService("routeParser") />

		<cfset var context = "default" />
		<cfset var routeInfo = parser.parse(context, route) />
		
		<cfset var renderer = hp.loadPage(routeInfo.page) />
		
		<cfset setValue("renderer", renderer) />
	</cffunction>

</cfcomponent>