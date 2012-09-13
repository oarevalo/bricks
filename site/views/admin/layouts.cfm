<cfif listLen(rs.path,"/") gt 0>
	<cfset parentPath = listDeleteAt(rs.path,listLen(rs.path,"/"),"/")>
<cfelse>
	<cfset parentPath = "">
</cfif>

<cfoutput>
	<ul class="breadcrumb">
		<li><i class="icon-home"></i> <a href="index.cfm?event=admin.home">Home</a> <span class="divider">/</span></li>
		<li>Setup <span class="divider">/</span></li>
		<li class="active">Layouts</li>
	</ul>
	
	<div style="float:right;" class="clearfix">
		<a class="btn" href="index.cfm?event=admin.doCreateLayoutFolder&path=#rs.path#" id="btnNewFolder"><i class="icon-plus"></i> New Folder</a>
		<a class="btn" href="index.cfm?event=admin.doCreateLayout&path=#rs.path#" id="btnNewPage"><i class="icon-plus"></i> New Page</a>
	</div>
	<h1>Layouts</h1>
	
	<div style="margin-bottom:5px;">
		<b>Path:</b> #rs.path#
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
			<cfif rs.path neq "/">
				<tr>
					<td></td>
					<td><a href="index.cfm?event=admin.layouts&path=#parentPath#">.. (parent)</a></td>
					<td style="text-align:center;">folder</td>
					<td></td>
				</tr>
			</cfif>
			<cfloop query="rs.qryDir">
				<tr>
					<td style="text-align:center;font-weight:bold;">#rs.qryDir.currentRow#.</td>
					<td>
						<cfif rs.qryDir.type eq "folder">
							<a href="index.cfm?event=admin.layouts&path=#rs.path##rs.qryDir.name#/">#rs.qryDir.name#</a>
						<cfelse>
							#rs.qryDir.name#
						</cfif>
					</td>
					<td style="text-align:center;">#rs.qryDir.type#</td>
					<td style="text-align:center;">
						<div class="btn-group">
						  	<cfif rs.qryDir.type eq "page">
							  	<a class="btn btn-small" href="index.cfm?event=admin.layout&name=#rs.qryDir.name#&path=#rs.path#">Edit</a>
							<cfelse>
								<a class="btn btn-small" href="index.cfm?event=admin.layouts&path=#rs.path##rs.qryDir.name#/">Open</a>
							</cfif>
						  <button class="btn dropdown-toggle btn-small" data-toggle="dropdown">
							<span class="caret"></span>
						  </button>
						  <ul class="dropdown-menu" style="text-align:left;">
						  	<cfif rs.qryDir.type eq "page">
							  	<li><a href="index.cfm?event=admin.layout&name=#rs.qryDir.name#&path=#rs.path#">Edit</a></li>
							  	<li><a href="##" rel="index.cfm?event=admin.doRenameLayout&name=#rs.qryDir.name#&path=#rs.path#" class="renameLink">Rename</a></li>
							  	<li><a href="##" rel="index.cfm?event=admin.doDeleteLayout&name=#rs.qryDir.name#&path=#rs.path#" class="deleteLink">Delete</a></li>
							<cfelse>
								<li><a href="index.cfm?event=admin.layouts&path=#rs.path##rs.qryDir.name#/">Open</a></li>
							  	<li><a href="##" rel="index.cfm?event=admin.doRenameLayoutFolder&name=#rs.qryDir.name#&path=#rs.path#" class="renameLink">Rename</a></li>
							  	<li><a href="##" rel="index.cfm?event=admin.doDeleteLayoutFolder&name=#rs.qryDir.name#&path=#rs.path#" class="deleteLink">Delete</a></li>
							</cfif>
						  </ul>
						</div>					
					</td>
				</tr>
			</cfloop>
		</tbody>
	</table>
</cfoutput>

