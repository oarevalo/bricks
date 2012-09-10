<cfcomponent>

	<!--- Define application settings --->
	<cfset this.applicationName = "bricksApp">
	<cfset this.sessionManagement = true>

	<!--- Create an application-specific mapping so that
		we can install this app in any directory --->
	<cfset this.mappings[ "/bricksApp" ] = getDirectoryFromPath(getcurrentTemplatePath()) />
	<cfset this.mappings[ "/homePortals" ] = expandPath("/bricksApp/lib/homePortals") />

</cfcomponent>