<cfcomponent>
	<cfset variables.contexts = {}>

	<cffunction name="init" access="public" returntype="routeParser">
		<cfargument name="configPath" type="string" required="false" default="" />
		<cfif arguments.configPath neq "">
			<cfset loadConfig(configPath) />
		</cfif>
		<cfreturn this />
	</cffunction>

	<cffunction name="loadConfig" access="public" returntype="void">
		<cfargument name="configPath" type="string" required="true" />
		<cfset var xmlDoc = xmlParse(configPath) />
		<cfset var contexts = xmlSearch(xmlDoc,"//context") />
		
		<cfloop array="#contexts#" index="context">
			<cfset contextName = "default" />
			<cfif structKeyExists(context.xmlAttributes,"name") and context.xmlAttributes.name neq "">
				<cfset contextName = context.xmlAttributes.name />
			</cfif>
			
			<cfset routes = xmlSearch(context,"//route") />
			<cfloop array="#routes#" index="route">
				<cfset st = {page="",resourceType="",resourcePath=""} />
				<cfif structKeyExists(route.xmlAttributes,"page")>
					<cfset st.page = route.xmlAttributes.page />
				</cfif>
				<cfif structKeyExists(route.xmlAttributes,"resourcePath")>
					<cfset st.resourcePath = route.xmlAttributes.resourcePath />
				</cfif>
				<cfif structKeyExists(route.xmlAttributes,"resourceType")>
					<cfset st.resourceType = route.xmlAttributes.resourceType />
				</cfif>
				<cfset addRoute(contextName, route.xmlAttributes.path, st.page, st.resourcePath, st.resourceType) />
			</cfloop>
		</cfloop>
	</cffunction>
	
	<cffunction name="parse" access="public" returntype="struct">
		<cfargument name="context" type="string" required="true" />
		<cfargument name="route" type="string" required="true" />
		<cfset var rtn = {page="",resourceType="",resourcePath=""}>
		<cfreturn rtn>
	</cffunction>

	<cffunction name="addRoute" access="public" returntype="void">
		<cfargument name="context" type="string" required="true">
		<cfargument name="path" type="string" required="true">
		<cfargument name="page" type="string" required="true">
		<cfargument name="resourcePath" type="string" required="true">
		<cfargument name="resourceType" type="string" required="true">
		<cfif not structKeyExists(variables.contexts, context)>
			<cfset variables.contexts[context] = {} />
		</cfif>
		<cfset variables.contexts[context][path] = {page = page, 
													resourceType = resourceType, 
													resourcePath = resourcePath}>
	</cffunction>

</cfcomponent>