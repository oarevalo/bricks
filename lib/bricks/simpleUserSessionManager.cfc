<cfcomponent>
	<cfset variables.sessionKey = "_user">
	<cfset variables.dataFile = "">

	<cffunction name="init" access="public" returntype="simpleUserSessionManager">
		<cfargument name="configPath" type="string" required="true">
		<cfset variables.dataFile = arguments.configPath>
		<cfreturn this/>
	</cffunction>

	<cffunction name="isLoggedIn" access="public" returntype="boolean" hint="Returns True if the user is logged in for the current session">
		<cfreturn structKeyExists(session,sessionKey) and len(session[sessionKey].userID)>
	</cffunction>

	<cffunction name="login" access="public" returntype="void" hint="logs in a user for this session"
				throws="invalidLoginException">
		<cfargument name="username" type="string" required="true">
		<cfargument name="password" type="string" required="true">
		<cfif fileExists(expandPath(dataFile))>
			<cfset var xmlDoc = xmlParse(expandPath(dataFile))>
			<cfset var xmlNodes = xmlSearch(xmlDoc,"//user[@username='#username#']")>
			<cfif arrayLen(xmlNodes) gt 0>
				<cfset var hashedPassword = xmlNodes[1].xmlText>
				<cfif hashedPassword eq hashPassword(arguments.password)>
					<cfset session[sessionKey] = {userid = xmlNodes[1].xmlAttributes.id, 
												username = xmlNodes[1].xmlAttributes.username}>
					<cfreturn>
				</cfif>
			</cfif>
		</cfif>
		<cfthrow type="invalidLoginException" message="Invalid username/password">
	</cffunction>

	<cffunction name="logout" access="public" returntype="void" hint="logs in a user for this session">
		<cfset structDelete(session,sessionKey,false)>
	</cffunction>

	<cffunction name="getUser" access="public" returntype="struct" hint="returns a struct with information about the current user. at least contain the elements userid and username">
		<cfif isLoggedIn()>
			<cfreturn session[sessionKey]>
		<cfelse>
			<cfreturn {userid="",username=""}>
		</cfif>		
	</cffunction>
	
	<cffunction name="changePassword" access="public" returntype="boolean" hint="changes the password for the current user. Returns true if password changed.">
		<cfargument name="newPassword" type="string" required="true">
		<cfif isLoggedIn() and fileExists(expandPath(dataFile))>
			<cfset var user = getUser()>
			<cfset var xmlDoc = xmlParse(expandPath(dataFile))>
			<cfset var xmlNodes = xmlSearch(xmlDoc,"//user[@username='#user.username#']")>
			<cfif arrayLen(xmlNodes) gt 0>
				<cfset xmlNodes[1].xmlText = hashPassword(arguments.newPassword) />
				<cfset fileWrite(expandPath(dataFile),toString(xmlDoc),"utf-8")>
				<cfreturn true>
			</cfif>
		</cfif>
		<cfreturn false>
	</cffunction>	

	<cffunction name="hashPassword" access="private" returntype="string">
		<cfargument name="password" type="string" required="true">
		<cfreturn hash(arguments.password,"SHA-256")>
	</cffunction>

</cfcomponent>