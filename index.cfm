<cfsilent>
<!---
	Bricks 
--->

<!--- create main application controller --->
<cfset app = createObject("component","bricksApp.lib.core.coreApp") />


<!--- Framework Settings --->
<cfset app.paths.core = "/bricksApp/lib/core">
<cfset app.paths.coreImages = "lib/core/images">
<cfset app.paths.modules = "/bricksApp/modules">

<cfset app.dirs.handlers = "site/handlers">
<cfset app.dirs.layouts = "site/layouts">
<cfset app.dirs.views = "site/views">

<cfset app.mainHandler = "main">
<cfset app.defaultEvent = "home">
<cfset app.configDoc = "config/config.xml.cfm">


<!--- Invoke controller --->
<cfset app.onRequestStart()>


<!--- Render view --->
</cfsilent><cfinclude template="lib/core/core.cfm">

