$(document).ready(function(){

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

