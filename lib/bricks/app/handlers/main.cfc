<cfcomponent extends="eventHandler" output="false">

	<cffunction name="onRequestStart" output="false">
		<cfset var hostName = cgi.http_host />
		<cfset var route = getValue("page") />
		<cfset var defaultContext = getSetting("bricks.defaultContext") />
		<cfset var routeParser = getService("routeParser") />
		<cfset var routeInfo = {} />
		<cfset var event = getEvent()>
		<cfset var appRoot = getSetting("bricks.appRoot")>

		<!--- if we are not calling an explicit event, then use the routes.xml to decide what to do --->
		<cfif event eq "">
			<!--- parse the current route to obtain which page we need to load --->
			<cfif routeParser.hasContext(hostName) or routeParser.hasContextAlias(hostName)>
				<cfset routeInfo = routeParser.parse(hostName, route)>
			<cfelse>
				<cfset routeInfo = routeParser.parse(defaultContext, route)>
			</cfif>
			<cfset setValue("routeInfo", routeInfo)>
			
			<cfif listLen(routeInfo.page,":") eq 2>
				<!--- route has a modifier, so let's see what we need to do --->
				<cfset var type = listFirst(routeInfo.page,":")>
				<cfset var target = listLast(routeInfo.page,":")>
				<cfswitch expression="#type#">
					<cfcase value="url">
						<!--- Redirect to a URL --->
						<cflocation addtoken="false" url="#target#">
					</cfcase>
					<cfcase value="event">
						<!--- Execute an event---->
						<cfset setEvent(target)>
					</cfcase>
					<cfdefaultcase>
						<cfset setMessage("error","Uknown route modifier: #type#")>
						<cflocation addtoken="false" url="#appRoot#">
					</cfdefaultcase>
				</cfswitch>
			<cfelse>
				<!--- load a content page --->
				<cfset setContentView(routeInfo.page, routeInfo.params)>
			</cfif>
		</cfif>
	</cffunction>
	
</cfcomponent>