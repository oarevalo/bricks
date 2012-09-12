<cfcomponent>
	<cfset variables.contexts = {}>
	<cfset variables.contextAliases = {}>
	<cfset variables.configTimestamp = "1/1/1800">
	<cfset variables.configPath = "">
	<cfset variables.__ROOT_ROUTE__ = "__root__">
	<cfset variables.__NO_ROUTE__ = "__no_route__">
	<cfset variables.defailtContextName = "default">

	<cffunction name="init" access="public" returntype="routeParser">
		<cfargument name="configPath" type="string" required="true" />
		<cfset variables.configPath = arguments.configPath>
		<cfset loadConfig() />
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
		<cfset var tmpPath = "">
		
		<cfset variables.contexts = {}>
		<cfset variables.contextAliases = {}>
		
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
			<cfset contextName = variables.defailtContextName />
			<cfif structKeyExists(context.xmlAttributes,"name") and context.xmlAttributes.name neq "">
				<cfset contextName = context.xmlAttributes.name />
			</cfif>
						
			<!--- register context aliases --->
			<cfif structKeyexists(context.xmlAttributes,"aliases") and context.xmlAttributes.aliases neq "">
				<cfloop list="#context.xmlAttributes.aliases#" index="item">
					<cfset variables.contextAliases[item] = contextName>
				</cfloop>
			</cfif>
						
			<cfset routeNodes = context.xmlChildren />
			<cfloop array="#routeNodes#" index="route">
				<!--- register routes --->
				<cfif route.xmlName eq "route">
					<cfset params = {}>
					<cfloop collection="#route.xmlAttributes#" item="item">
						<cfset params[item] = route.xmlAttributes[item]>
					</cfloop>
					<cfif route.xmlAttributes.path eq "">
						<cfset tmpPath = __ROOT_ROUTE__>
					<cfelse>
						<cfset tmpPath = route.xmlAttributes.path>
					</cfif>
					<cfset addRoute(contextName, tmpPath, route.xmlAttributes.page, params) />
				</cfif>

				<!--- register no-route --->
				<cfif route.xmlName eq "noroute">
					<cfset params = {}>
					<cfloop collection="#route.xmlAttributes#" item="item">
						<cfset params[item] = route.xmlAttributes[item]>
					</cfloop>
					<cfset setNoRoute(contextName, route.xmlAttributes.page, params) />
				</cfif>
			</cfloop>
		</cfloop>

		<cfset variables.configTimestamp = now()>
	</cffunction>
	
	<cffunction name="parse" access="public" returntype="struct">
		<cfargument name="context" type="string" required="true" hint="a context name or an alias" />
		<cfargument name="route" type="string" required="true" />

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
				<cfset var noroute = duplicate(getNoRoute(context))>
				<cfset noroute.params.requestedpath = route>
				<cfreturn noroute>
			</cfif>
			<cfthrow message="The requested route [#route#] is not defined for the given context" type="routeNotDefined">
		</cfif>

		<!--- lookup context/route --->
		<cfreturn getRoute(context, route)>
	</cffunction>

	<cffunction name="hasContext" access="public" returntype="boolean">
		<cfargument name="context" type="string" required="true">
		<cfreturn structKeyExists(contexts, context)>
	</cffunction>

	<cffunction name="hasContextAlias" access="public" returntype="boolean">
		<cfargument name="alias" type="string" required="true">
		<cfreturn structKeyExists(contextAliases, alias)>
	</cffunction>

	<cffunction name="hasRoute" access="public" returntype="boolean">
		<cfargument name="context" type="string" required="true">
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
		<cfargument name="context" type="string" required="true">
		<cfreturn structKeyExists(contexts[context], __NO_ROUTE__)>
	</cffunction>

	<cffunction name="addRoute" access="public" returntype="void">
		<cfargument name="context" type="string" required="true">
		<cfargument name="path" type="string" required="true">
		<cfargument name="page" type="string" required="true">
		<cfargument name="params" type="struct" required="false" default="#structNew()#">

		<!--- make sure context and path are always lowercase to avoid casing issues --->
		<cfset context = lcase(trim(context))>
		<cfset path = lcase(trim(path))>
		<cfset page = trim(page)>
		
		<cfif not structKeyExists(variables.contexts, context)>
			<cfset variables.contexts[context] = {} />
		</cfif>
		<cfset variables.contexts[context][path] = {page = page, 
																		params = params}>
	</cffunction>

	<cffunction name="setNoRoute" access="public" returntype="void">
		<cfargument name="context" type="string" required="true">
		<cfargument name="page" type="string" required="true">
		<cfargument name="params" type="struct" required="false" default="#structNew()#">
		<cfset addRoute(context, __NO_ROUTE__,page, params)>
	</cffunction>

	<cffunction name="getRoute" access="public" returntype="struct">
		<cfargument name="context" type="string" required="true">
		<cfargument name="route" type="string" required="true">
		<cfset var thisContext = contexts[context]>
		<cfset var reCheck = {}>
		<cfset var rtn = {}>
		<cfset var i = 0>
		<cfset var token = "">
		<cfset var key = "">
		<cfset var key2 = "">
		
		<!--- check for exact match --->
		<cfif structKeyExists(thisContext, route)>
			<cfreturn variables.contexts[context][route]>
		</cfif>
		
		<!--- check for regexp match --->
		<cfloop collection="#thisContext#" item="key">
			<cfset reCheck = refindNoCase("^" & key & "$",route,1,true)>
			<cfif reCheck.pos[1] gt 0>
				<cfset rtn = duplicate(variables.contexts[context][key])>
				<cfset rtn.params.path = arguments.route>
				<cfif arrayLen(reCheck.pos) gt 1>
					<!--- do token replacement on back references --->
					<cfloop from="2" to="#arrayLen(reCheck.pos)#" index="i">
						<cfset token = "$#i-1#">
						<cfset replaceWith = mid(route,reCheck.pos[i],reCheck.len[i])>
						<cfset rtn.page = replace(rtn.page,token,replaceWith,"all")>
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
		<cfargument name="context" type="string" required="true">
		<cfreturn variables.contexts[context][__NO_ROUTE__]>
	</cffunction>

	<cffunction name="getAliasOf" access="public" returntype="string">
		<cfargument name="alias" type="string" required="true">
		<cfreturn variables.contextAliases[alias]>
	</cffunction>

	<cffunction name="checkConfigReload" access="private" returntype="void">
		<cfset var path = expandPath(variables.configPath)>
		<cfset var info = getFileInfo(path)>
		<cfif dateCompare(info.lastModified, variables.configTimestamp, "s") gt 0>
			<cfset loadConfig()>
		</cfif>
	</cffunction>

</cfcomponent>