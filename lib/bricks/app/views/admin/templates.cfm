<cfoutput>
	<ul class="breadcrumb">
		<li><i class="icon-home"></i> <a href="index.cfm?event=admin.home">Home</a> <span class="divider">/</span></li>
		<li>Setup <span class="divider">/</span></li>
		<cfif structKeyExists(rs,"template")>
			<li><a href="index.cfm?event=admin.templates">Templates</a> <span class="divider">/</span></li>
			<li class="active">Edit Template</li>
		<cfelse>
			<li class="active">Templates</li>
		</cfif>
	</ul>
	<h1>Templates</h1>
	
	<div class="row">
		<div class="span3">
			<div class="well sidebar-nav">
				<ul class="nav nav-list">
					<li class="nav-header">Page Templates</li>
					<cfif structKeyExists(rs.templates,"page")>
						<cfloop collection="#rs.templates.page#" item="name">
							<cfset item = rs.templates.page[name]>
							<cfset selected = structKeyExists(rs,"type") and rs.type eq "page" and rs.name eq item.name>
							<li <cfif selected>class="active"</cfif>><a href="index.cfm?event=admin.templates&type=page&name=#item.name#">#item.name#<cfif item.isDefault> (default)</cfif></a></li>
						</cfloop>
					<cfelse>
						<em>None</em>
					</cfif>
					<li class="nav-header">Module Templates</li>
					<cfif structKeyExists(rs.templates,"module")>
						<cfloop collection="#rs.templates.module#" item="name">
							<cfset item = rs.templates.module[name]>
							<cfset selected = structKeyExists(rs,"type") and rs.type eq "module" and rs.name eq item.name>
							<li <cfif selected>class="active"</cfif>><a href="index.cfm?event=admin.templates&type=module&name=#item.name#">#item.name#<cfif item.isDefault> (default)</cfif></a></li>
						</cfloop>
					<cfelse>
						<em>None</em>
					</cfif>
				</ul>
			</div>
			<a href="index.cfm?event=admin.templates&name=_new_"><button class="btn"><i class="icon-plus"></i> New Template</button></a>
		</div>
		<div class="span9" style="height:100%;">
			<cfif structKeyExists(rs,"name") and rs.name neq "">
				<script src="#request.libRoot#codeMirror/codemirror.js"></script>
				<link rel="stylesheet" href="#request.libRoot#codeMirror/codemirror.css">
				<script src="#request.libRoot#codeMirror/mode/xml.js"></script>
				<script src="#request.libRoot#codeMirror/mode/javascript.js"></script>
				<script src="#request.libRoot#codeMirror/mode/css.js"></script>
				<script src="#request.libRoot#codeMirror/mode/htmlmixed.js"></script>
			
				<form name="frm" method="post" action="index.cfm">
					<input type="hidden" name="event" value="admin.doSaveTemplate">
					<input type="hidden" name="name" value="#rs.name#">

					<cfif rs.name eq "_new_">
						<div class="form-inline">
							<label><b>Template Name:</b> <input type="text" name="templateName" value=""></label>
							&nbsp;&nbsp;&nbsp;&nbsp;
							<b>Template Type:</b> 
							<label class="radio"><input type="radio" name="type" value="page"> Page</label>
							&nbsp;
							<label class="radio"><input type="radio" name="type" value="module"> Module</label>
						</div>
						<textarea name="editor" id="editor"></textarea><br />
					<cfelse>
						<div class="form-inline">
							<label><b>Template Name:</b> <input type="text" name="templateName" value="#rs.name#" disabled="true"></label>
							&nbsp;&nbsp;&nbsp;&nbsp;
							<b>Template Type:</b> 
							<label class="radio"><input type="radio" name="type" value="page" disabled="true" <cfif rs.type eq "page">checked</cfif>> Page</label>
							&nbsp;
							<label class="radio"><input type="radio" name="type" value="module" disabled="true" <cfif rs.type eq "module">checked</cfif>> Module</label>
						</div>
						<input type="hidden" name="type" value="#rs.type#">
						<textarea name="editor" id="editor">#htmlEditFormat(rs.templateContent)#</textarea><br />
					</cfif>

					<cfif rs.name neq "_new_">
						<span style="float:right;">#rs.template.href# (#rs.template.type#)</span>
						<input type="submit" class="btn" value="Apply Changes"> 
						<input type="button" class="btn" value="Delete" onclick="if(confirm('Delete template?')) {this.form.event.value='admin.doDeleteTemplate';this.form.submit();}"> 
					<cfelse>
						<input type="submit" class="btn" value="Apply Changes"> 
					</cfif>

				</form>
			
				<script type="text/javascript">
					var myCodeMirror = CodeMirror.fromTextArea(document.getElementById("editor"), {
				        lineNumbers: true,
					  mode:  "text/html"
					});
					myCodeMirror.setSize("100%",450);
				</script> 		
			<cfelse>
				<p><em>No template selected</em></p>
			</cfif>
		</div>
	</div>
</cfoutput>
