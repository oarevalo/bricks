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
	
	// enable tooltips
	$('[rel=tooltip]').tooltip();

	
	// dismiss alert messages automatically
	if (typeof __removeAlert === 'undefined') {
		// nothing here
	} else {
		setTimeout(function() {
			$("#alert").fadeOut().empty();
		},3000);
	}		
});