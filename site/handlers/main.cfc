<cfcomponent extends="eventHandler" output="false">

	<cffunction name="home" output="false">
		<cfset var hostName = cgi.http_host />
		<cfset var route = getValue("page") />
		<cfset var defaultContext = getSetting("bricks.defaultContext") />
		<cfset var routeParser = getService("routeParser") />
		<cfset var routeInfo = {} />

		<!--- parse the current route to obtain which page we need to load --->
		<cfif routeParser.hasContext(hostName) or routeParser.hasContextAlias(hostName)>
			<cfset routeInfo = routeParser.parse(hostName, route)>
		<cfelse>
			<cfset routeInfo = routeParser.parse(defaultContext, route)>
		</cfif>

		<!--- load the page --->
		<cfset var renderer = getService("homePortals").loadPage(routeInfo.page) />

		<!--- pass values for rendering --->
		<cfset setValue("pageParams", routeInfo.params)>
		<cfset setValue("renderer", renderer) />
		
		<!--- set the layout that knows how to render homePortals pages --->
		<cfset setLayout("renderer")>
	</cffunction>

</cfcomponent>