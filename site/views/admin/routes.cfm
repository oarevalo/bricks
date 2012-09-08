<cfoutput>
	<ul class="breadcrumb">
		<li><i class="icon-home"></i> <a href="index.cfm?event=admin.home">Home</a> <span class="divider">/</span></li>
		<li>Setup <span class="divider">/</span></li>
		<li class="active">Routes</li>
	</ul>
	<h1>Routes</h1>
	
	<div style="height:100%;">
		<script src="lib/codeMirror/codemirror.js"></script>
		<link rel="stylesheet" href="lib/codeMirror/codemirror.css">
		<script src="lib/codeMirror/mode/xml.js"></script>
	
		<form name="frm" method="post" action="index.cfm">
			<input type="hidden" name="event" value="admin.doSaveRoutes">
			<textarea name="editor" id="editor" style="border:1px solid black;">#htmlEditFormat(rs.fileContent)#</textarea><br />
			<input type="submit" class="btn" value="Apply Changes">
		</form>
	
		<script type="text/javascript">
			var myCodeMirror = CodeMirror.fromTextArea(document.getElementById("editor"), {
		        lineNumbers: true,
			  mode:  "xml"
			});
			myCodeMirror.setSize("100%",450)
		</script> 
	</div>
</cfoutput>
