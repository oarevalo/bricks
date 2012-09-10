<!--- Define the options for the main menu --->
<cfset mainMenu = [
				{label="Home", event="admin.home"},
				{label="Content", event="admin.resources", paramName="type", paramValue="content"},
				{label="Images", event="admin.resources", paramName="type", paramValue="image"},
				{label="News Feeds", event="admin.resources", paramName="type", paramValue="feed"}
			] />
			 
<!--- Define the options for the setup menu --->
<cfset setupMenu = [
				{label="Routes", event="admin.routes"},
				{label="Templates", event="admin.templates"},
				{label="Layouts", event="admin.layouts"},
				{label="Config", event="admin.config"}
			] />
