<cfset items = [
				{label="Routes", event="admin.routes"},
				{label="Templates", event="admin.templates"},
				{label="Layouts", event="admin.layouts"},
				{label="Resources", event="admin.resources"},
			]>
			
<cfoutput>
	<div class="navbar navbar-inverse navbar-fixed-top">
		<div class="navbar-inner">
			<a class="brand" href="index.cfm?event=admin.home" style="margin-left:1px;">Bricks</a>
            <p class="navbar-text pull-right" style="margin-right:10px;">
				<a href="/bricks" class="navbar-link">Go To Site</a>
				&nbsp;|&nbsp;
				<a href="index.cfm?event=admin.config" class="navbar-link">Config</a>
				&nbsp;|&nbsp;
				<a href="##" class="navbar-link">Logout</a>
            </p>
			<ul class="nav">
				<cfloop array="#items#" index="item">
					<li <cfif item.event eq rs.event>class="active"</cfif>><a href="index.cfm?event=#item.event#">#item.label#</a></li>
				</cfloop>
			</ul>
		</div>
	</div>
</cfoutput>
