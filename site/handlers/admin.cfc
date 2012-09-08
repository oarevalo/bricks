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
			var name = getValue("name");
			
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
			var hp = getService("homePortals");
			var path = getValue("path");
			if(path eq "") path="/";
			
			var qryDir = hp.getPageProvider().listFolder(path);
			
			setValue("path",path);
			setValue("qryDir",qryDir);
			setLayout("admin");
			setView("admin/layouts");
		</cfscript>
	</cffunction>

	<cffunction name="layout">
		<cfscript>
			var hp = getService("homePortals");
			var path = getValue("path");
			var name = getValue("name");

			var pp = hp.getPageProvider();
			var page = pp.load(path & name);
			var pageInfo = pp.getInfo(path & name);

			var fileContent = fileRead(pageInfo.path,"utf-8");
			setValue("fileContent",fileContent);
			
			setValue("page",page);
			setValue("pageInfo",pageInfo);
			setLayout("admin");
			setView("admin/layout");
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

	<cffunction name="doCreateLayoutFolder">
		<cfscript>
			try {
				var path = trim(getValue("path"));
				var name = trim(getValue("name","new_folder"));

				if(name eq "")
					throw(type="validation", message="Folder name cannot be empty");
					
				var hp = getService("homePortals");
				var pp = hp.getPageProvider();

				if(right(path,1) neq "/")
					path = path & "/";
					
				var tmpName = name;
				var index = 1;
				while(pp.folderExists(path & tmpName)) {
					tmpName = name & index;
					index++;
				}

				pp.createFolder(path,tmpName);
					
				setMessage("info", "Folder created");
				setNextEvent("admin.layouts","path=#path#");

			} catch(validation e) {
				setMessage("warning", e.message);
				setNextEvent("admin.layouts","path=#path#");

			} catch(any e) {
				setMessage("error", e.message);
				setNextEvent("admin.layouts","path=#path#");
			}
		</cfscript>
	</cffunction>

	<cffunction name="doDeleteLayoutFolder">
		<cfscript>
			try {
				var path = trim(getValue("path"));
				var name = trim(getValue("name"));
				var hp = getService("homePortals");
				var pp = hp.getPageProvider();

				pp.deleteFolder(path & name);
					
				setMessage("info", "Folder deleted");
				setNextEvent("admin.layouts","path=#path#");

			} catch(validation e) {
				setMessage("warning", e.message);
				setNextEvent("admin.layouts","path=#path#");

			} catch(any e) {
				setMessage("error", e.message);
				setNextEvent("admin.layouts","path=#path#");
			}
		</cfscript>
	</cffunction>

	<cffunction name="doRenameLayoutFolder">
		<cfscript>
			try {
				var path = trim(getValue("path"));
				var name = trim(getValue("name"));
				var newname = trim(getValue("newname"));
				var hp = getService("homePortals");
				var pp = hp.getPageProvider();

				pp.renameFolder(path & name,newName);
					
				setMessage("info", "Folder renamed");
				setNextEvent("admin.layouts","path=#path#");

			} catch(validation e) {
				setMessage("warning", e.message);
				setNextEvent("admin.layouts","path=#path#");

			} catch(any e) {
				setMessage("error", e.message);
				setNextEvent("admin.layouts","path=#path#");
			}
		</cfscript>
	</cffunction>

	<cffunction name="doCreateLayout">
		<cfscript>
			try {
				var path = trim(getValue("path"));
				var name = trim(getValue("name","new_page"));

				if(name eq "")
					throw(type="validation", message="Page name cannot be empty");
					
				var hp = getService("homePortals");
				var pp = hp.getPageProvider();

				if(right(path,1) neq "/")
					path = path & "/";
					
				var tmpName = name;
				var index = 1;
				while(pp.pageExists(path & tmpName)) {
					tmpName = name & index;
					index++;
				}

				pageBean = createObject("component","homePortals.components.pageBean").init();
				pageBean.setTitle(tmpName);

				pp.save(path & tmpName, pageBean);
					
				setMessage("info", "Folder created");
				setNextEvent("admin.layouts","path=#path#");

			} catch(validation e) {
				setMessage("warning", e.message);
				setNextEvent("admin.layouts","path=#path#");

			} catch(any e) {
				setMessage("error", e.message);
				setNextEvent("admin.layouts","path=#path#");
			}
		</cfscript>	
	</cffunction>

	<cffunction name="doDeleteLayout">
		<cfscript>
			try {
				var path = trim(getValue("path"));
				var name = trim(getValue("name"));
				var hp = getService("homePortals");
				var pp = hp.getPageProvider();

				pp.delete(path & name);
					
				setMessage("info", "Layout deleted");
				setNextEvent("admin.layouts","path=#path#");

			} catch(validation e) {
				setMessage("warning", e.message);
				setNextEvent("admin.layouts","path=#path#");

			} catch(any e) {
				setMessage("error", e.message);
				setNextEvent("admin.layouts","path=#path#");
			}
		</cfscript>
	</cffunction>

	<cffunction name="doSaveLayout">
		<cfscript>
			try {
				var path = getValue("path");
				var name = getValue("name");
				var content = trim(getValue("editor"));
				if(content eq "")
					throw(type="validation", message="Layout definition cannot be empty");
				if(!isXml(content))
					throw(type="validation",message="Layout definition has to be a valid XML file");

				var hp = getService("homePortals");
				var pp = hp.getPageProvider();
				var pageInfo = pp.getInfo(path & name);
					
				fileWrite(pageInfo.path,content,"utf-8");	
					
				setMessage("info", "Layout saved");
				setNextEvent("admin.layouts","path=#path#");

			} catch(validation e) {
				setMessage("warning", e.message);
				setNextEvent("admin.layout","path=#path#&name=#name#");

			} catch(any e) {
				setMessage("error", e.message);
				setNextEvent("admin.layout","path=#path#&name=#name#");
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="doRenameLayout">
		<cfscript>
			try {
				var path = trim(getValue("path"));
				var name = trim(getValue("name"));
				var newname = trim(getValue("newname"));
				var hp = getService("homePortals");
				var pp = hp.getPageProvider();

				pp.move(path & name,path & newName);
					
				setMessage("info", "Layout renamed");
				setNextEvent("admin.layouts","path=#path#");

			} catch(validation e) {
				setMessage("warning", e.message);
				setNextEvent("admin.layouts","path=#path#");

			} catch(any e) {
				setMessage("error", e.message);
				setNextEvent("admin.layouts","path=#path#");
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