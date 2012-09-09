<cfinterface>

	<cffunction name="isLoggedIn" access="public" returntype="boolean" hint="Returns True if the user is logged in for the current session">
	</cffunction>

	<cffunction name="login" access="public" returntype="void" hint="logs in a user for this session"
				throws="invalidLoginException">
		<cfargument name="username" type="string" required="true">
		<cfargument name="password" type="string" required="true">
	</cffunction>

	<cffunction name="logout" access="public" returntype="void" hint="logs in a user for this session">
	</cffunction>

	<cffunction name="changePassword" access="public" returntype="boolean" hint="changes the password for the current user. Returns true if password changed.">
		<cfargument name="newPassword" type="string" required="true">
	</cffunction>

	<cffunction name="getUser" access="public" returntype="struct" hint="returns a struct with information about the current user. at least contain the elements userid and username">
	</cffunction>

</cfinterface>