<cfcomponent extends="eventHandler" output="false">

	<cffunction name="onRequestStart" output="false">
		<!--- if we are not calling an explicit event, then use the routes.xml to decide what to do --->
		<cfif getEvent() eq "">
			<cfset handleRoute()>
		</cfif>
	</cffunction>
	
	<cffunction name="handleRoute" access="private" returntype="void">
		<cfscript>
			var hostName = cgi.http_host;
			var route = "";
			var defaultContext = getSetting("bricks.routes.defaultContext");
			var routeParser = getService("routeParser");
			var routeInfo = {};
			var appRoot = getSetting("bricks.appRoot");
		
			// get the requested route
			if(getSetting("bricks.routes.useFakeSES", false)) {
				// routes are given in the format: http://localhost/index.cfm/this/is/a/route
				route = reReplaceNoCase(trim(cgi.path_info), '.+\.cfm/? *', '');
			} else {
				// routes are given by a url (or something) param
				route = getValue(getSetting("bricks.routes.param","path"));
			}
			
			// parse the current route to obtain which page we need to load
			if(routeParser.hasContext(hostName) or routeParser.hasContextAlias(hostName))
				routeInfo = routeParser.parse(hostName, route);
			else
				routeInfo = routeParser.parse(defaultContext, route);
			setValue("routeInfo", routeInfo);
			
			if(listLen(routeInfo.page,":") eq 2) {
				// route has a modifier, so let's see what we need to do
				var type = listFirst(routeInfo.page,":");
				var target = listLast(routeInfo.page,":");
				
				switch(type) {
					case "url":
						// Redirect to a URL
						for(key in routeInfo.params) {
							target = target & find("?",target)?"?":"&" & key & "=" & routeInfo.params[key];
						}
						location(url=target,addToken=false);
						break;
						
					case "event":
						// Execute an event
						setEvent(target);
						for(key in routeInfo.params) {
							setValue(key, routeInfo.params[key]);
						}
						break;

					default:
						setMessage("error","Uknown route modifier: #type#");
						location(url=appRoot,addToken=false);
				}
			} else {
				// load a content page
				setContentView(routeInfo.page, routeInfo.params);
			}
		</cfscript>

	</cffunction>
	
</cfcomponent>