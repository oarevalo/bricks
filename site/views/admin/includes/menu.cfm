<cfset isLoggedIn = structKeyExists(rs,"currentUser")>

<cfset mainMenu = [
				{label="Home", event="admin.home"}
			] />
<cfset setupMenu = [
				{label="Routes", event="admin.routes"},
				{label="Templates", event="admin.templates"},
				{label="Layouts", event="admin.layouts"},
				{label="Config", event="admin.config"}
			] />

<cfif isLoggedIn>
	<cfloop array="#rs.resourceTypes#" index="item">
		<cfset arrayAppend(mainMenu, {label=item, event="admin.resources", extra="type=#item#"}) />	
	</cfloop>			
</cfif>			

<cfoutput>
	<div class="navbar navbar-inverse navbar-fixed-top">
		<div class="navbar-inner">
			<a class="brand" href="index.cfm?event=admin.home" style="margin-left:1px;">Bricks</a>
			<cfif isLoggedIn>
			<ul class="nav">
				<cfloop array="#mainMenu#" index="item">
					<cfif rs.event eq "admin.resources">
						<cfset selected = (item.event eq rs.event and rs.type eq item.label)>
					<cfelse>
						<cfset selected = (item.event eq rs.event)>
					</cfif>
					<cfif structKeyExists(item,"extra")>
						<cfset href = "index.cfm?event=#item.event#&#item.extra#">
					<cfelse>
						<cfset href = "index.cfm?event=#item.event#">
					</cfif>
					<li <cfif selected>class="active"</cfif>><a href="#href#">#item.label#</a></li>
				</cfloop>
			</ul>
			</cfif>
			<ul class="nav pull-right">
				<li><a href="#rs.appRoot#" class="navbar-link" target="_blank">Go To Site</a></li>
				<cfif isLoggedIn>
	          		<li class="dropdown">
		                <a href="##" class="dropdown-toggle" data-toggle="dropdown">Setup <b class="caret"></b></a>
		                <ul class="dropdown-menu">
							<cfloop array="#setupMenu#" index="item">
								<li><a href="index.cfm?event=#item.event#">#item.label#</a></li>
							</cfloop>
							<li class="divider"></li>
							<li><a href="index.cfm?event=admin.changePassword">Change Password</a></li>
		                </ul>
	            	</li>
					<li><a href="index.cfm?event=admin.doLogout" class="navbar-link">Logout</a></li>
				</cfif>
			</ul>
		</div>
	</div>
</cfoutput>
