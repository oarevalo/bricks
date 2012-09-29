<cfcomponent extends="homePortals.components.contentTagRenderer" hint="Executes an event handler">
	<cfproperty name="handler" type="string" hint="Name of the event to run.">
	<cfproperty name="view" type="string" hint="Path to the view to display.">

	<cffunction name="renderContent" access="public" returntype="void" hint="sets the rendered output for the head and body into the corresponding content buffers">
		<cfargument name="headContentBuffer" type="homePortals.components.singleContentBuffer" required="true">	
		<cfargument name="bodyContentBuffer" type="homePortals.components.singleContentBuffer" required="true">
		<cfset arguments.bodyContentBuffer.set( renderEvent() ) />
	</cffunction>

	<cffunction name="renderEvent" access="private" returntype="string" >
		<cfset var html = "">
		<cfset var tag = getContentTag()>
		<cfset var handler = tag.getAttribute("handler")>
		<cfset var view = tag.getAttribute("view")>
		
		<!--- create a request state --->
		<cfset var reqState = tag.getModuleBean().toStruct()>

		<!--- run the event --->
		<cfset request.app.runEventHandler(reqState, handler)>
		
		<!--- render the view --->
		<cfset html = renderView(view, reqState)>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="renderView" access="private" returntype="string">
		<cfargument name="_href" type="any" required="true">
		<cfargument name="_reqState" type="struct" required="true">
		<cfset var _html = "">
		<cfset var _oldReqState = {}>
		<cfset var _hasReqState = false>

		<cfif _href neq "">
			<cfif left(_href,1) neq "/">
				<cfset _href = getHomePortals().getConfig().getAppRoot() & _href>
			</cfif>
			<cfif structKeyExists(request,"requestState")>
				<cfset _oldReqState = request.requestState>
				<cfset structDelete(request,"requestState")>
				<cfset _hasReqState = true>
			</cfif>
			<cfset request.requestState = _reqState>
			<cfsavecontent variable="_html">
				<cfinclude template="#_href#">	
			</cfsavecontent>
			<cfif _hasReqState>
				<cfset request.requestState = _oldReqState>
			<cfelse>
				<cfset structDelete(request,"requestState")>
			</cfif>
		</cfif>
		<cfreturn _html>
	</cffunction>	
	
	
</cfcomponent>