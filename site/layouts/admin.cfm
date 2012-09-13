<!DOCTYPE html>
<cfoutput>
<cfset rs = request.requestState>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<title>Bricks 0.1 : Site Admin</title>
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<link href="lib/bootstrap/css/bootstrap.min.css" rel="stylesheet">
		<link href="site/views/admin/includes/style.css" rel="stylesheet">
	</head>
	<body>
		<!--- main menu --->
		<cfinclude template="../views/admin/includes/menu.cfm">

		<div class="container">
			<!--- alert messages --->
			<cfif rs.messageTemplatePath neq "">
				<cfinclude template="#rs.messageTemplatePath#">
			</cfif>
			
			<!--- view --->
			<cfif rs.viewTemplatePath neq "">
				<cfinclude template="#rs.viewTemplatePath#">
			</cfif>
		</div>
		
		<script src="http://code.jquery.com/jquery-latest.js"></script>
		<script src="lib/bootstrap/js/bootstrap.min.js"></script>
		<script src="site/views/admin/includes/main.js"></script>
	</body>
</html>
</cfoutput>	