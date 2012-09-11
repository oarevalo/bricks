<cfcomponent>
	<cfset variables.contexts = {}>
	<cfset variables.contextAliases = {}>
	<cfset variables.configTimestamp = "1/1/1800">
	<cfset variables.configPath = "">
	<cfset variables.__NO_ROUTE__ = "__no_route__">
	<cfset variables.defailtContextName = "default">

	<cffunction name="init" access="public" returntype="routeParser">
		<cfargument name="configPath" type="string" required="true" />
		<cfset variables.configPath = arguments.configPath>
		<cfset loadConfig() />
		<cfreturn this />
	</cffunction>

	<cffunction name="loadConfig" access="public" returntype="void">
		<cfset var xmlDoc = xmlParse(variables.configPath) />
		<cfset var contextNodes = xmlSearch(xmlDoc,"//context") />
		<cfset var context = "">
		<cfset var contextName = "">
		<cfset var routeNodes = []>
		<cfset var route = "">
		<cfset var params = {}>
		<cfset var item = "">
		
		<cfset variables.contexts = {}>
		<cfset variables.contextAliases = {}>
		
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
					<cfset addRoute(contextName, route.xmlAttributes.path, route.xmlAttributes.page, params) />
				</cfif>

				<!--- register no-route --->
				<cfif route.xmlName eq "noroute">
					<cfset params = {}>
					<cfloop collection="#routeNodes[1].xmlAttributes#" item="item">
						<cfset params[item] = routeNodes[1].xmlAttributes[item]>
					</cfloop>
					<cfset setNoRoute(contextName, routeNodes[1].xmlAttributes.page, params) />
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
		<cfreturn variables.contexts[context][route]>
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
		<cfreturn structKeyExists(contexts[context], route)>
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

	<cffunction name="getNoRoute" access="public" returntype="struct">
		<cfargument name="context" type="string" required="true">
		<cfreturn variables.contexts[context][__NO_ROUTE__]>
	</cffunction>

	<cffunction name="getAliasOf" access="public" returntype="string">
		<cfargument name="alias" type="string" required="true">
		<cfreturn variables.contextAliases[alias]>
	</cffunction>

	<cffunction name="checkConfigReload" access="private" returntype="void">
		<cfset var info = getFileInfo(variables.configPath)>
		<cfif dateCompare(info.lastModified, variables.configTimestamp, "s") gt 0>
			<cfset loadConfig()>
		</cfif>
	</cffunction>

</cfcomponent>