<!DOCTYPE html>
<cfoutput>
<cfset rs = request.requestState>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<title>#rs.pageTitle#</title>
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<link href="#request.libRoot#/bootstrap/css/bootstrap.min.css" rel="stylesheet">
		<link href="style.css" rel="stylesheet">
	</head>
	<body>
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
		<script src="#request.libRoot#/bootstrap/js/bootstrap.min.js"></script>
		<script src="main.js"></script>
	</body>
</html>
</cfoutput>	