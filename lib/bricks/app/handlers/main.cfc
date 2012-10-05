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
			var requestMethod = cgi.request_method;
			var defaultContext = getSetting("bricks.routes.defaultContext");
			var routeParser = getService("routeParser");
			var appRoot = getSetting("bricks.appRoot");
		
			// parse the current route to obtain which page we need to load
			var route = getCurrentRoute();
			var context = routeParser.hasContextOrAlias(hostName) ? hostName : defaultContext;
			var routeInfo = routeParser.parse(context, route, requestMethod);

			// Paths in Bricks by default point to content pages, but we allow for modifiers to indicate
			// alternate actions such as redirect to another URL or an Event Handler to execute.
			// Modifiers are indicated by prepending them to the path and separating by a colon (":"). 
			// Examples: "event:some.action" or "url:http://somwhere.else.com"
			if(listLen(routeInfo.path,":") eq 2) {
				var type = listFirst(routeInfo.path,":");
				var target = listLast(routeInfo.path,":");
				
				switch(type) {
					case "url":
						// Redirect to a URL
						for(key in routeInfo.params) {
							target = target & find("?",target)?"?":"&" & key & "=" & routeInfo.params[key];
						}
						location(url=target, addToken=false);
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
						location(url=appRoot, addToken=false);
				}
			} else {
				// load a content page
				setContentView(routeInfo.path, routeInfo.params);
			}

			setValue("routeInfo", routeInfo);
		</cfscript>
	</cffunction>
	
	<cffunction name="getCurrentRoute" access="private" returntype="string">
		<cfscript>
			var route = "";
			var defaultRouteParam = "path";
			var useFakeSES = getSetting("bricks.routes.useFakeSES", false);
			var routeParam = getSetting("bricks.routes.param", defaultRouteParam);
			
			if(useFakeSES) {
				// routes are given in the format: http://localhost/index.cfm/this/is/a/route
				route = reReplaceNoCase(trim(cgi.path_info), '.+\.cfm/? *', '');
			} else {
				// routes are given by a url (or something) param
				route = getValue(routeParam);
			}

			return route;
		</cfscript>
	</cffunction>
	
</cfcomponent>