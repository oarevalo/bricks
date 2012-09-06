<cfcomponent extends="core.coreApp">

	<cfset this.applicationName = "Bricks Website">

	<cfset this.paths.core = "/core">
	<cfset this.dirs.handlers = "site/handlers">
	<cfset this.dirs.layouts = "site/layouts">
	<cfset this.dirs.views = "site/views">
	<cfset this.mainHandler = "main">
	<cfset this.defaultEvent = "home">
	<cfset this.defaultLayout = "main">
	<cfset this.configDoc = "config/config.xml.cfm">

</cfcomponent>