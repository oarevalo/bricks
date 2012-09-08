<cfset mainMenu = [
				{label="Resources", event="admin.resources"}
			] />
<cfset setupMenu = [
				{label="Routes", event="admin.routes"},
				{label="Templates", event="admin.templates"},
				{label="Layouts", event="admin.layouts"},
				{label="Config", event="admin.config"}
			] />
			
<cfoutput>
	<div class="navbar navbar-inverse navbar-fixed-top">
		<div class="navbar-inner">
			<a class="brand" href="index.cfm?event=admin.home" style="margin-left:1px;">Bricks</a>
			<ul class="nav">
				<cfloop array="#mainMenu#" index="item">
					<li <cfif item.event eq rs.event>class="active"</cfif>><a href="index.cfm?event=#item.event#">#item.label#</a></li>
				</cfloop>
			</ul>
             <ul class="nav pull-right">
              <li><a href="/bricks" class="navbar-link">Go To Site</a></li>
              <li class="dropdown">
                <a href="##" class="dropdown-toggle" data-toggle="dropdown">Setup <b class="caret"></b></a>
                <ul class="dropdown-menu">
					<cfloop array="#setupMenu#" index="item">
						<li><a href="index.cfm?event=#item.event#">#item.label#</a></li>
					</cfloop>
                </ul>
              </li>
				<li><a href="##" class="navbar-link">Logout</a></li>
            </ul>
		</div>
	</div>
</cfoutput>
