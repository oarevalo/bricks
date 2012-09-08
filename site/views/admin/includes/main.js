$(document).ready(function(){
	$('.renameLink').click(function(){
		var rel = $(this).attr("rel");
		var newName = prompt("Enter new name");
		if(newName) {
			document.location = rel + "&newName=" + escape(newName);
		}
	});
	
	$('.deleteLink').click(function(){
		var rel = $(this).attr("rel");
		if(confirm("Delete?")) {
			document.location = rel;
		}
	});	
});