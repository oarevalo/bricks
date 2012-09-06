<cfcomponent extends="core.eventHandler" output="false">

	<cffunction name="home" output="false">
		<cfset var page = getValue("page") />
		<cfset var hp = getService("homePortals") />
		<cfset var renderer = hp.loadPage(page) />
		<cfset setValue("renderer", renderer) />
	</cffunction>

</cfcomponent>