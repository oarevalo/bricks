<cfoutput>
	<ul class="breadcrumb">
		<li><i class="icon-home"></i> <a href="index.cfm?event=admin.home">Home</a> <span class="divider">/</span></li>
		<li>Setup <span class="divider">/</span></li>
		<li><a href="index.cfm?event=admin.layouts&path=#rs.path#">Layouts</a> <span class="divider">/</span></li>
		<li class="active">Edit Layout</li>
	</ul>
	<h1>Edit Layout</h1>
	
	<div style="height:100%;">
		<script src="#request.libRoot#codeMirror/codemirror.js"></script>
		<link rel="stylesheet" href="#request.libRoot#codeMirror/codemirror.css">
		<script src="#request.libRoot#codeMirror/mode/xml.js"></script>
		<script src="#request.libRoot#codeMirror/util/formatting.js"></script>
	
		<form name="frm" method="post" action="index.cfm">
			<input type="hidden" name="event" value="admin.doSaveLayout">
			<input type="hidden" name="path" value="#rs.path#">
			<input type="hidden" name="name" value="#rs.name#">

			<textarea name="editor" id="editor" style="border:1px solid black;">#htmlEditFormat(trim(rs.fileContent))#</textarea><br />

			<span style="float:right;"><b>Path:</b> #rs.path##rs.name#</span>

			<input type="submit" class="btn" value="Apply Changes">
			&nbsp;
			<a href="index.cfm?event=admin.layouts&path=#rs.path#">Go Back</a>
		</form>
	
		<script type="text/javascript">
			var myCodeMirror = CodeMirror.fromTextArea(document.getElementById("editor"), {
		        lineNumbers: true,
			  mode:  "xml"
			});
			myCodeMirror.setSize("100%",450);
		</script> 
	</div>
</cfoutput>
