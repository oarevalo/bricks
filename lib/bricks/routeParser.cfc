<cfcomponent>
	<cfset variables.contexts = {}>
	<cfset variables.contextAliases = {}>
	<cfset variables.contextRoutes = {}>
	<cfset variables.configTimestamp = "1/1/1800">
	<cfset variables.configPath = "">
	<cfset variables.__ROOT_ROUTE__ = "__root__">
	<cfset variables.__NO_ROUTE__ = "__no_route__">
	<cfset variables.defaultContextName = "default">

	<cffunction name="init" access="public" returntype="routeParser">
		<cfargument name="configPath" type="string" required="false" default="" />
		<cfif arguments.configPath neq "">
			<cfset variables.configPath = arguments.configPath>
			<cfset loadConfig() />
		</cfif>
		<cfreturn this />
	</cffunction>

	<cffunction name="loadConfig" access="public" returntype="void">
		<cfset var xmlDoc = 0 />
		<cfset var contextNodes = [] />
		<cfset var context = "">
		<cfset var contextName = "">
		<cfset var routeNodes = []>
		<cfset var route = "">
		<cfset var params = {}>
		<cfset var item = "">
		<cfset var tmpURI = "">
		
		<cfset variables.contexts = {}>
		<cfset variables.contextAliases = {}>
		<cfset variables.contextRoutes = {}>
		
		<!--- check that config file exists, otherwise we get a not very intuitive error message --->
		<cfif variables.configPath eq "" or not fileExists(expandPath(variables.configPath))>
			<cfthrow message="Invalid or missing routes config file.">
		</cfif>
		
		<!--- load and parse config file --->
		<cfset var xmlDoc = xmlParse(expandPath(variables.configPath)) />

		<!--- parse contexts --->		
		<cfset var contextNodes = xmlSearch(xmlDoc,"//context") />
		<cfloop array="#contextNodes#" index="context">
			<!--- get context name --->
			<cfset contextName = variables.defaultContextName />
			<cfif structKeyExists(context.xmlAttributes,"name") and context.xmlAttributes.name neq "">
				<cfset contextName = context.xmlAttributes.name />
			</cfif>
						
			<!--- register context aliases --->
			<cfif structKeyexists(context.xmlAttributes,"aliases") and context.xmlAttributes.aliases neq "">
				<cfloop list="#context.xmlAttributes.aliases#" index="item">
					<cfset addAlias(contextName, item) />
				</cfloop>
			</cfif>
						
			<cfset routeNodes = context.xmlChildren />
			<cfloop array="#routeNodes#" index="route">
				<!--- build params --->
				<cfset params = {}>
				<cfloop collection="#route.xmlAttributes#" item="item">
					<cfif item neq "uri" and item neq "path">
						<cfset params[item] = route.xmlAttributes[item]>
					</cfif>
				</cfloop>

				<!--- register routes --->
				<cfswitch expression="#route.xmlName#">
					<cfcase value="route">
						<cfset addRoute(contextName, route.xmlAttributes.uri, route.xmlAttributes.path, params, "any") />
					</cfcase>
					<cfcase value="noroute">
						<cfset setNoRoute(contextName, route.xmlAttributes.path, params) />
					</cfcase>
					<cfdefaultcase>
						<cfset addRoute(contextName, route.xmlAttributes.uri, route.xmlAttributes.path, params, route.xmlName) />
					</cfdefaultcase>
				</cfswitch>
			</cfloop>
		</cfloop>

		<cfset variables.configTimestamp = now()>
	</cffunction>
	
	<cffunction name="parse" access="public" returntype="struct">
		<cfargument name="context" type="string" required="false" default="#variables.defaultContextName#" hint="a context name or an alias">
		<cfargument name="route" type="string" required="true" />
		<cfargument name="method" type="string" required="false" default="any">

		<!--- reload config if necessary --->
		<cfset checkConfigReload()>

		<!--- make sure context and route are always lowercase to avoid casing issues --->
		<cfset context = lcase(trim(context))>
		<cfset route = lcase(trim(route))>

		<!--- validate request --->
		<cfif not hasContext(context)>
			<cfif not hasContextAlias(context)>
				<cfthrow message="The requested route context [#context#] is not defined" type="contextNotDefined">
			<cfelse>
				<cfset context = getAliasOf(context)>
			</cfif>
		</cfif>
		<cfif route eq "" or route eq "/">
			<cfset route = __ROOT_ROUTE__>
		</cfif>
		<cfif not hasRoute(context, route)>
			<!--- see if we have noRoute defined for this context --->
			<cfif hasNoRoute(context)>
				<cfset var noroute = getNoRoute(context)>
				<cfset var rtn = {
						route = arguments.route,
						context = arguments.context,
						path = noroute.any.path,
						params = noroute.any.params,
						method = arguments.method		
					}>
				<cfreturn rtn>
			</cfif>
			<cfthrow message="The requested route [#route#] is not defined for the given context" type="routeNotDefined">
		</cfif>

		<!--- lookup context/route --->
		<cfreturn getRoute(context, route, method)>
	</cffunction>

	<cffunction name="hasContext" access="public" returntype="boolean">
		<cfargument name="context" type="string" required="true">
		<cfreturn structKeyExists(contexts, context)>
	</cffunction>

	<cffunction name="hasContextAlias" access="public" returntype="boolean">
		<cfargument name="context" type="string" required="true">
		<cfreturn structKeyExists(contextAliases, context)>
	</cffunction>

	<cffunction name="hasContextOrAlias" access="public" returntype="boolean">
		<cfargument name="contextOrAlias" type="string" required="true">
		<cfreturn hasContext(contextOrAlias) or hasContextAlias(contextOrAlias)>
	</cffunction>

	<cffunction name="hasRoute" access="public" returntype="boolean">
		<cfargument name="context" type="string" required="false" default="#variables.defaultContextName#">
		<cfargument name="route" type="string" required="true">
		<cfset var key = "">
		<cfset var thisContext = contexts[context]>
		<cfset var reCheck = {}>
		
		<!--- check for exact match --->
		<cfif structKeyExists(thisContext, route)>
			<cfreturn true>
		</cfif>
		
		<!--- check for regexp match --->
		<cfloop collection="#thisContext#" item="key">
			<cfset reCheck = refindNoCase("^" & key & "$",route,1,true)>
			<cfif reCheck.pos[1] gt 0>
				<cfreturn true>
			</cfif>
		</cfloop>
		
		<cfreturn false>
	</cffunction>

	<cffunction name="hasNoRoute" access="public" returntype="boolean">
		<cfargument name="context" type="string" required="false" default="#variables.defaultContextName#">
		<cfreturn structKeyExists(contexts[context], __NO_ROUTE__)>
	</cffunction>

	<cffunction name="addRoute" access="public" returntype="routeParser">
		<cfargument name="context" type="string" required="false" default="#variables.defaultContextName#">
		<cfargument name="route" type="string" required="true">
		<cfargument name="path" type="string" required="true">
		<cfargument name="params" type="struct" required="false" default="#structNew()#">
		<cfargument name="method" type="string" required="false" default="any">

		<!--- make sure context and path are always lowercase to avoid casing issues --->
		<cfset var theContext = lcase(trim(arguments.context))>
		<cfset var theRoute = lcase(trim(arguments.route))>
		<cfset var thePath = trim(arguments.path)>
		<cfset var theMethod = lcase(trim(arguments.method))>
		
		<!--- initialize context if needed --->
		<cfif not structKeyExists(variables.contexts, theContext)>
			<cfset variables.contexts[theContext] = {} />
			<cfset variables.contextRoutes[theContext] = [] />
		</cfif>

		<!--- make sure we don't have empty routes --->
		<cfif theRoute eq "">
			<cfset theRoute = __ROOT_ROUTE__>
		</cfif>
	
		<!--- check for tokens in route and replace with regexp --->
		<cfset var tokenRegex = "[a-z][0-9a-z_]+">
		<cfset var tokenRegexExpanded = "[0-9a-z-_+]+">
		<cfset var index = 1 />
		<cfset var reCheck = reFindNoCase("{(#tokenRegex#)}", theRoute, index, true)/>
		<cfset var tokenFound = (arrayLen(reCheck.pos) gt 1) />
		<cfset var subIndex = 1/>
		<cfloop condition="#tokenFound#">
			<cfloop from="2" to="#arrayLen(reCheck.pos)#" index="i">
				<cfset tokenName = mid(theRoute, reCheck.pos[i], reCheck.len[i])>
				<cfset arguments.params[tokenName] = "$#subIndex#">
				<cfset thePath = replaceNoCase(thePath, "{#tokenName#}", "$#subIndex#", "all")>
				<cfset theRoute = replaceNoCase(theRoute, "{#tokenName#}", "(#tokenRegexExpanded#)", "all")>
			</cfloop>
			<cfset index = reCheck.pos[1] + reCheck.len[1]>
			<cfset subIndex++>
			<cfset reCheck = reFindNoCase("{(#tokenRegex#)}", theRoute, index, true)/>
			<cfset tokenFound = (arrayLen(reCheck.pos) gt 1) />
		</cfloop>
		
		<!--- add route --->
		<cfif not structKeyExists(variables.contexts[theContext], theRoute)>
			<cfset variables.contexts[theContext][theRoute] = {}>
		</cfif>
		<cfset var tmp = "">
		<cfloop list="#theMethod#" index="tmp">
			<cfset variables.contexts[theContext][theRoute][tmp] = {path = thePath, 
																	params = arguments.params}>
		</cfloop>
		<cfset arrayAppend(variables.contextRoutes[theContext], theRoute)>														
													
		<cfreturn this>
	</cffunction>

	<cffunction name="setNoRoute" access="public" returntype="routeParser">
		<cfargument name="context" type="string" required="false" default="#variables.defaultContextName#">
		<cfargument name="path" type="string" required="true">
		<cfargument name="params" type="struct" required="false" default="#structNew()#">
		<cfset addRoute(context, __NO_ROUTE__,path, params)>
		<cfreturn this>
	</cffunction>

	<cffunction name="getRoute" access="public" returntype="struct">
		<cfargument name="context" type="string" required="false" default="#variables.defaultContextName#">
		<cfargument name="route" type="string" required="true">
		<cfargument name="method" type="string" required="false" default="any">
		<cfset var thisContext = variables.contexts[context]>
		<cfset var thisContextRoutes = variables.contextRoutes[context]>
		<cfset var reCheck = {}>
		<cfset var i = 0>
		<cfset var token = "">
		<cfset var key = "">
		<cfset var key2 = "">
		<cfset var tmp = {}>

		<!--- prepare return struct --->
		<cfset var rtn = {
						route = arguments.route,
						context = arguments.context,
						path = "",
						params = {},
						method = arguments.method
					}>
		
		<!--- check for exact match --->
		<cfif structKeyExists(thisContext, route)>
			<cfif structKeyExists(thisContext[route], method)>
				<cfset tmp = thisContext[route][method]>
			<cfelseif structKeyExists(thisContext[route], "any")>
				<cfset tmp = thisContext[route]["any"]>
				<cfset rtn.method = "any">
			<cfelse>
				<cfthrow message="The requested route [#route#] is not defined for the given context and method" type="routeNotDefined">
			</cfif>
			<cfset rtn.path = tmp.path>
			<cfset rtn.params = duplicate(tmp.params)>
			<cfreturn rtn>
		</cfif>
		
		<!--- check for regexp match --->
		<cfloop array="#thisContextRoutes#" index="key">
			<cfset reCheck = refindNoCase("^" & key & "$",route,1,true)>
			<cfif reCheck.pos[1] gt 0>
				<cfif structKeyExists(thisContext[key], method)>
					<cfset tmp = thisContext[key][method]>
				<cfelseif structKeyExists(thisContext[key], "any")>
					<cfset tmp = thisContext[key]["any"]>
				<cfelse>
					<cfthrow message="The requested route [#route#] is not defined for the given context and method" type="routeNotDefined">
				</cfif>
				<cfset rtn.path = tmp.path>
				<cfset rtn.params = duplicate(tmp.params)>
				<cfif arrayLen(reCheck.pos) gt 1>
					<!--- do token replacement on back references --->
					<cfloop from="2" to="#arrayLen(reCheck.pos)#" index="i">
						<cfset token = "$#i-1#">
						<cfset replaceWith = mid(route,reCheck.pos[i],reCheck.len[i])>
						<cfset rtn.path = replace(rtn.path,token,replaceWith,"all")> 
						<cfloop collection="#rtn.params#" item="key2">
							<cfset rtn.params[key2] = replace(rtn.params[key2],token,replaceWith,"all")>
						</cfloop>
					</cfloop>
				</cfif>
				<cfreturn rtn>
			</cfif>
		</cfloop>

		<cfthrow message="route not found" type="routeNotFound">
	</cffunction>

	<cffunction name="getNoRoute" access="public" returntype="struct">
		<cfargument name="context" type="string" required="false" default="#variables.defaultContextName#">
		<cfreturn variables.contexts[context][__NO_ROUTE__]>
	</cffunction>

	<cffunction name="addAlias" access="public" returntype="routeParser">
		<cfargument name="context" type="string" required="true">
		<cfargument name="alias" type="string" required="true">
		<cfset variables.contextAliases[arguments.alias] = arguments.context>
		<cfreturn this>
	</cffunction>

	<cffunction name="getAliasOf" access="public" returntype="string">
		<cfargument name="alias" type="string" required="true">
		<cfreturn variables.contextAliases[alias]>
	</cffunction>

	<cffunction name="checkConfigReload" access="private" returntype="void">
		<cfif variables.configPath neq "">
			<cfset var path = expandPath(variables.configPath)>
			<cfset var info = getFileInfo(path)>
			<cfif dateCompare(info.lastModified, variables.configTimestamp, "s") gt 0>
				<cfset loadConfig()>
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="getMemento" access="public" returntype="struct">
		<cfreturn variables.contexts>
	</cffunction>

</cfcomponent>