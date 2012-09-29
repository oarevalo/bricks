<cfsilent>
<!---
	Bricks App Loader
--->

<!--- create main application controller --->
<cfset request.app = createObject("component","bricksLib.core.coreApp") />


<!--- Framework Settings --->
<cfset request.app.paths.app = "/bricksLib/bricks/app/">
<cfset request.app.paths.core = "/bricksLib/core">
<cfset request.app.paths.modules = "/bricksApp/modules">
<cfset request.app.paths.message = "/bricksLib/bricks/message.cfm">
<cfset request.app.paths.config = "/bricksApp/config/config.xml.cfm">
<cfset request.app.paths.coreImages = request.libRoot & "core/images">

<cfset request.app.dirs.handlers = "handlers">
<cfset request.app.dirs.layouts = "layouts">
<cfset request.app.dirs.views = "views">

<cfset request.app.mainHandler = "main">
<cfset request.app.defaultEvent = "">


<!--- Invoke controller --->
<cfset request.app.onRequestStart()>


<!--- Render view --->
</cfsilent><cfinclude template="/bricksLib/core/core.cfm">
