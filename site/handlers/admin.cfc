<cfcomponent extends="core.eventHandler" output="false">

	<cfset variables.routesFile = "/bricks/config/routes.xml">

	<!---- Default View --->

	<cffunction name="home">
		<cfset setNextEvent("admin.routes")>
	</cffunction>


	<!---- Views --->
		
	<cffunction name="routes">
		<cfscript>
			var fileContent = fileRead(expandPath(variables.routesFile),"utf-8");
			setValue("fileContent",fileContent);
			setLayout("admin");
			setView("admin/routes");
		</cfscript>
	</cffunction>
	
	<cffunction name="templates">
		<cfscript>
			var config = getHomePortalsConfigBean();
			var templates = config.getRenderTemplates();
			
			var type = getValue("type");
			var name = getValue("name")
			
			if(type neq "" and name neq "") {
				template = config.getRenderTemplate(name, type);
				templateContent = "";
				
				if(type neq "_new_" and fileExists(expandPath(template.href)))
					templateContent = fileRead(expandPath(template.href),"utf-8");

				setValue("template",template);
				setValue("templateContent",templateContent);
			}
			
			setValue("templates",templates);
			setLayout("admin");
			setView("admin/templates");
		</cfscript>
	</cffunction>

	<cffunction name="layouts">
		<cfscript>
			setLayout("admin");
			setView("admin/layouts");
		</cfscript>
	</cffunction>

	<cffunction name="resources">
		<cfscript>
			setLayout("admin");
			setView("admin/resources");
		</cfscript>
	</cffunction>

	<cffunction name="config">
		<cfscript>
			var configFilePath = getHomePortalsConfigFilePath();
			var fileContent = fileRead(expandPath(configFilePath),"utf-8");
			setValue("fileContent",fileContent);
			setLayout("admin");
			setView("admin/config");
		</cfscript>
	</cffunction>	
	
	
	<!--- Actions --->
	
	<cffunction name="doSaveRoutes">
		<cfscript>
			try {
				var content = trim(getValue("editor"));
				if(content eq "")
					throw(type="validation", message="Routes definition cannot be empty");
				if(!isXml(content))
					throw(type="validation",message="Routes definition has to be a valid XML file");
					
				fileWrite(expandPath(variables.routesFile),content,"utf-8");	
					
				setMessage("info", "Routes saved");
				setNextEvent("admin.routes");

			} catch(validation e) {
				setMessage("warning", e.message);
				setNextEvent("admin.routes");

			} catch(any e) {
				setMessage("error", e.message);
				setNextEvent("admin.routes");
			}
		</cfscript>
	</cffunction>

	<cffunction name="doSaveConfig">
		<cfscript>
			try {
				var configFilePath = getHomePortalsConfigFilePath();
				var content = trim(getValue("editor"));
				if(content eq "")
					throw(type="validation", message="Config definition cannot be empty");
				if(!isXml(content))
					throw(type="validation",message="Config definition has to be a valid XML file");
				
				// save config
				fileWrite(expandPath(configFilePath),content,"utf-8");	
				
				// reload homeportals
				getService("homePortals").reinit();
					
				setMessage("info", "Config saved");
				setNextEvent("admin.config");

			} catch(validation e) {
				setMessage("warning", e.message);
				setNextEvent("admin.config");

			} catch(any e) {
				setMessage("error", e.message);
				setNextEvent("admin.config");
			}			
		</cfscript>
	</cffunction>	
	
	<cffunction name="doSaveTemplate">
		<cfscript>
			try {
				var type = getValue("type");
				var name = getValue("name");
				var content = trim(getValue("editor"));

				if(content eq "")
					throw(type="validation", message="Template body cannot be empty");
				
				var config = getHomePortalsConfigBean();
				
				if(name neq "_new_") {
					var template = config.getRenderTemplate(name, type);
					fileWrite(expandPath(template.href),content,"utf-8");	
				} else {
					var templateName = getValue("templateName");
					if(templateName eq "")
						throw(type="validation", message="Template name cannot be empty");
					if(type eq "")
						throw(type="validation", message="Template type cannot be empty");
						
					// save template file
					var templatePath = getService("homePortals").getConfig().getAppRoot() & "content/templates/" & lcase(templateName) & ".htm";
					fileWrite(expandPath(templatePath),content,"utf-8");	
					
					// add template to config
					var configPath = getHomePortalsConfigFilePath();
					var xmlDoc = xmlParse(configPath);
					var xmlNode = xmlelemnew(xmlDoc,"renderTemplate");
					xmlNode.xmlAttributes["name"] = templateName;
					xmlNode.xmlAttributes["type"] = type;
					xmlNode.xmlAttributes["href"] = templatePath;
					arrayAppend(xmlDoc.xmlRoot.renderTemplates.xmlChildren, xmlNode);
					fileWrite(expandPath(configPath),toString(xmlDoc),"utf-8");	
				}

				// reinit homeportals
				getService("homePortals").reinit();
				
				setMessage("info", "Template saved");
				setNextEvent("admin.templates");

			} catch(validation e) {
				setMessage("warning", e.message);
				setNextEvent("admin.templates","type=#type#&name=#name#");

			} catch(any e) {
				setMessage("error", e.message);
				setNextEvent("admin.templates","type=#type#&name=#name#");
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="doDeleteTemplate">
		<cfscript>
			try {
				var type = getValue("type");
				var name = getValue("name");

				var config = getHomePortalsConfigBean();
				var template = config.getRenderTemplate(name, type);

				// delete file
				if(fileExists(expandPath(template.href)))
					fileDelete(expandPath(template.href));
				
				// delete from config
				var configPath = getHomePortalsConfigFilePath();
				var xmlDoc = xmlParse(configPath);
				var xmlParentNode = xmlDoc.xmlRoot.renderTemplates;
				for(var i=1;i lte arrayLen(xmlParentNode.xmlChildren);i++) {
					if(xmlParentNode.xmlChildren[i].xmlName eq "renderTemplate"
						and xmlParentNode.xmlChildren[i].xmlAttributes.name eq name
						and xmlParentNode.xmlChildren[i].xmlAttributes.type eq type) {
						arrayDeleteAt(xmlParentNode.xmlChildren, i);
					}
				}
				fileWrite(expandPath(configPath),toString(xmlDoc),"utf-8");	
				
				// reinit homeportals
				getService("homePortals").reinit();

				setMessage("info", "Template deleted");
				setNextEvent("admin.templates");

			} catch(validation e) {
				setMessage("warning", e.message);
				setNextEvent("admin.templates");

			} catch(any e) {
				setMessage("error", e.message);
				setNextEvent("admin.templates");
			}
		</cfscript>
	</cffunction>	

	<cffunction name="doSavePage">
		<cfscript>
			try {
				throw(message="not implemented");
				
				setMessage("info", "Page saved");
				setNextEvent("admin.pages");

			} catch(validation e) {
				setMessage("warning", e.message);
				setNextEvent("admin.pages");

			} catch(any e) {
				setMessage("error", e.message);
				setNextEvent("admin.pages");
			}
		</cfscript>
	</cffunction>		
	
	<cffunction name="doDeletePage">
		<cfscript>
			try {
				throw(message="not implemented");
				
				setMessage("info", "Page deleted");
				setNextEvent("admin.pages");

			} catch(validation e) {
				setMessage("warning", e.message);
				setNextEvent("admin.pages");

			} catch(any e) {
				setMessage("error", e.message);
				setNextEvent("admin.pages");
			}
		</cfscript>
	</cffunction>	
	
	<cffunction name="doSaveResource">
		<cfscript>
			try {
				throw(message="not implemented");
				
				setMessage("info", "Resource saved");
				setNextEvent("admin.resources");

			} catch(validation e) {
				setMessage("warning", e.message);
				setNextEvent("admin.resources");

			} catch(any e) {
				setMessage("error", e.message);
				setNextEvent("admin.resources");
			}
		</cfscript>
	</cffunction>		
	
	<cffunction name="doDeleteResource">
		<cfscript>
			try {
				throw(message="not implemented");
				
				setMessage("info", "Resource deleted");
				setNextEvent("admin.resources");

			} catch(validation e) {
				setMessage("warning", e.message);
				setNextEvent("admin.resources");

			} catch(any e) {
				setMessage("error", e.message);
				setNextEvent("admin.resources");
			}
		</cfscript>
	</cffunction>		


	<!--- Utility Methods --->
	
	<cffunction name="getHomePortalsConfigBean" access="private" returntype="any">
		<cfset var configPath = getHomePortalsConfigFilePath()>
		<cfset var bean = createObject("component","homePortals.components.homePortalsConfigBean").init( expandPath(configPath) )>
		<cfreturn bean>
	</cffunction>
	
	<cffunction name="getHomePortalsConfigFilePath" access="private" returntype="string">
		<cfset var hp = getService("homePortals")>
		<cfset var appRoot = hp.getConfig().getAppRoot()>
		<cfset var configPath = hp.getConfigFilePath()>
		<cfreturn appRoot & configPath>
	</cffunction>
	
</cfcomponent>