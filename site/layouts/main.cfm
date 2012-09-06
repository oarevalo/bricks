<cfset rs = request.requestState>
<!DOCTYPE html>
<html>
	<head>
		<title>Bricks Website</title>
	</head>
	<body>
		<cfinclude template="#rs.messageTemplatePath#">
		<cfinclude template="#rs.viewTemplatePath#">
	</body>
</html>