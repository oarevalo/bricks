<cfset packageDepth = listLen(rs.package,"/")>
<cfif packageDepth gt 1>
	<cfset parentPackage = listDeleteAt(rs.package,packageDepth,"/")>
<cfelse>
	<cfset parentPackage = "">
</cfif>


<cfoutput>
	<ul class="breadcrumb">
		<li><i class="icon-home"></i> <a href="index.cfm?event=admin.home">Home</a> <span class="divider">/</span></li>
		<li class="active">#rs.typeLabel#</li>
	</ul>

	<div style="float:right;" class="clearfix">
		<a class="btn" href="index.cfm?event=admin.doCreateResourcePackage&package=#rs.package#&type=#rs.type#"><i class="icon-plus"></i> New Folder</a>
		<a class="btn" href="index.cfm?event=admin.resource&package=#rs.package#&type=#rs.type#&id="><i class="icon-plus"></i> New Resource</a>
	</div>
		
	<h1>#rs.typeLabel#</h1>

	<div class="well">
		<p>#rs.typeInfo.getDescription()#</p>
	</div>

	<div style="margin-bottom:5px;">
		<b>Path:</b> #rs.package#
	</div>
	
	<table class="table table-striped table-bordered table-condensed table-hover" style="width:100%;">
		<thead>
			<tr>
				<th style="width:30px;text-align:center;">##</th>
				<th>Name</th>
				<th style="width:75px;text-align:center;">Type</th>
				<th style="width:100px;text-align:center;">Actions</th>
			</tr>
		</thead>
		<tbody>
			<cfif rs.package neq "/">
				<tr>
					<td></td>
					<td><a href="index.cfm?event=admin.resources&package=#parentPackage#&type=#rs.type#">.. (parent)</a></td>
					<td style="text-align:center;">Folder</td>
					<td></td>
				</tr>
			</cfif>
			<cfset index = 1>
			<cfloop query="rs.packages">
				<cfif listLen(rs.packages.name,"/") eq packageDepth+1 and (rs.package eq "/" or left(rs.packages.name,len(rs.package)) eq rs.package)>
				<cfset thisFolder = listLast(rs.packages.name,"/")>
				<tr>
					<td style="text-align:center;font-weight:bold;">#index#.</td>
					<td><a href="index.cfm?event=admin.resources&type=#rs.type#&package=#rs.packages.name#/">#thisFolder#</a></td>
					<td style="text-align:center;">Folder</td>
					<td style="text-align:center;">
						<div class="btn-group">
						  <a class="btn dropdown-toggle btn-mini" data-toggle="dropdown" href="##">
						    Action <span class="caret"></span>
						  </a>
						  <ul class="dropdown-menu" style="text-align:left;">
						  	<li><a href="##" rel="index.cfm?event=admin.doDeleteResourcePackage&name=#rs.packages.name#&type=#rs.type#&package=#rs.package#" class="deleteLink">Delete</a></li>
						  	<li><a href="##" rel="index.cfm?event=admin.doRenameResourcePackage&name=#rs.packages.name#&type=#rs.type#&package=#rs.package#" class="renameLink">Rename</a></li>
						  </ul>
						</div>					
					</td>
				</tr>
				<cfset index++>
				</cfif>
			</cfloop>
			<cfloop array="#rs.resources#" index="resource">
				<tr>
					<td style="text-align:center;font-weight:bold;">#index#.</td>
					<td>#resource.getID()#</td>
					<td style="text-align:center;">Resource</td>
					<td style="text-align:center;">
						<div class="btn-group">
						  <a class="btn dropdown-toggle btn-mini" data-toggle="dropdown" href="##">
						    Action <span class="caret"></span>
						  </a>
						  <ul class="dropdown-menu" style="text-align:left;">
						  	<li><a href="index.cfm?event=admin.resource&id=#resource.getID()#&type=#rs.type#&package=#rs.package#">Edit</a></li>
						  	<li><a href="##" rel="index.cfm?event=admin.doDeleteResource&id=#resource.getID()#&type=#rs.type#&package=#rs.package#" class="deleteLink">Delete</a></li>
						  </ul>
						</div>					
					</td>
				</tr>
				<cfset index++>
			</cfloop>
			<cfif rs.packages.recordCount eq 0 and arrayLen(rs.resources) eq 0>
				<tr><td colspan="4"><em>No resources found</em></td></tr>
			</cfif>
		</tbody>
	</table>
</cfoutput>
