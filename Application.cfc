<cfcomponent output="false">

	<!--- Define application settings --->
	<cfset this.applicationName = "bricksApp">
	<cfset this.sessionManagement = true>

	<!--- Define location of the "lib" folder. This folder contains both 
		CF and HTML/JS code so it must be web accessible --->
	<cfset request.libRoot = "./lib/">

	<!--- Create an application-specific mapping so that
		we can install this app in any directory --->
	<cfset this.mappings[ "/bricksApp" ] = getDirectoryFromPath(getcurrentTemplatePath()) />
	<cfset this.mappings[ "/bricksLib" ] = expandPath(request.libRoot) />
	<cfset this.mappings[ "/homePortals" ] = expandPath(request.libRoot & "homePortals") />

</cfcomponent>