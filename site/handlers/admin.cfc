<cfcomponent extends="eventHandler">

	<!---- Default View --->

	<cffunction name="home">
		<cfset checkLoggedInUser()>
		<cfset setAdminView("home")>
	</cffunction>


	<!---- Views --->

	<cffunction name="login">
		<cfset setAdminView("login")>
	</cffunction>

	<cffunction name="changePassword">
		<cfset checkLoggedInUser()>
		<cfset setAdminView("changePassword")>
	</cffunction>
		
	<cffunction name="routes">
		<cfscript>
			checkLoggedInUser();
			var routesFile = getSetting("bricks.routesConfig");
			var fileContent = fileRead(expandPath(routesFile),"utf-8");
			setValue("fileContent",fileContent);
			setAdminView("routes");
		</cfscript>
	</cffunction>
	
	<cffunction name="templates">
		<cfscript>
			checkLoggedInUser();
			
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
			setAdminView("templates");
		</cfscript>
	</cffunction>

	<cffunction name="layouts">
		<cfscript>
			checkLoggedInUser();
			
			var hp = getService("homePortals");
			var path = getValue("path");
			if(path eq "") path="/";
			
			var qryDir = hp.getPageProvider().listFolder(path);
			
			setValue("path",path);
			setValue("qryDir",qryDir);
			setAdminView("layouts");
		</cfscript>
	</cffunction>

	<cffunction name="layout">
		<cfscript>
			checkLoggedInUser();
			
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
			setAdminView("layout");
		</cfscript>
	</cffunction>

	<cffunction name="resources">
		<cfscript>
			checkLoggedInUser();
			
			var hp = getService("homePortals");
			var rlm = hp.getResourceLibraryManager();
			var resourceTypes = rlm.getResourceTypes();
			if(!arrayLen(resourceTypes)) {
				setMessage("warning","No resource types have been configured");
				setNextEvent("admin.home");
			}
			var type = getValue("type", resourceTypes[1]);
			var package = getValue("package");
			if(package eq "") package="/";
			
			var packages = rlm.getResourcePackagesList(type);
			var resources = rlm.getResourcesInPackage(type,package);
			var typeInfo = rlm.getResourceTypeInfo(type);
			
			setValue("type",type);
			setValue("package",package);
			setValue("packages",packages);
			setValue("resources",resources);
			setValue("typeInfo",typeInfo);
			setAdminView("resources");
		</cfscript>
	</cffunction>
	
	<cffunction name="resource">
		<cfscript>
			checkLoggedInUser();
			
			var hp = getService("homePortals");
			var type = getValue("type");
			var package = getValue("package");
			var id = getValue("id");

			var rlm = hp.getResourceLibraryManager();
			var resLib = rlm.getResourceLibrary("content/resources");
			var typeInfo = rlm.getResourceTypeInfo(type);
			
			if(id neq "")
				resBean = resLib.getResource(type, package, id);
			else
				resBean = resLib.getNewResource(type);
			
			setValue("resBean",resBean);
			setValue("catalog",hp.getCatalog());
			setValue("typeInfo",typeInfo);
			setAdminView("resource");
		</cfscript>
	</cffunction>	

	<cffunction name="config">
		<cfscript>
			checkLoggedInUser();
			
			var configFilePath = getHomePortalsConfigFilePath();
			var fileContent = fileRead(expandPath(configFilePath),"utf-8");
			setValue("fileContent",fileContent);
			setAdminView("config");
		</cfscript>
	</cffunction>	
	
	
	<!--- Actions --->

	<cffunction name="doLogin">
		<cfscript>
			try {
				var usm = getService("userSessionManager");
				usm.login(getValue("username"), getValue("password"));
				setNextEvent("admin.home");

			} catch(invalidLoginException e) {
				setMessage("warning", e.message);
				setNextEvent("admin.login");

			} catch(any e) {
				setMessage("error", e.message);
				setNextEvent("admin.login");
			}
		</cfscript>
	</cffunction>

	<cffunction name="doLogout">
		<cfscript>
			try {
				var usm = getService("userSessionManager");
				usm.logout();
				setNextEvent("admin.home");

			} catch(invalidLoginException e) {
				setMessage("warning", e.message);
				setNextEvent("admin.home");

			} catch(any e) {
				setMessage("error", e.message);
				setNextEvent("admin.home");
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="doChangePassword">
		<cfscript>
			checkLoggedInUser();
			
			try {
				var usm = getService("userSessionManager");
				if(getValue("newPassword") eq "")
					throw(type="validation",message="Password cannot be empty");
				if(getValue("newPassword") neq getValue("newPassword2"))
					throw(type="validation",message="Passwords do not match");
				usm.changePassword(getValue("newPassword"));
				setMessage("info", "Password changed");
				setNextEvent("admin.home");

			} catch(validation e) {
				setMessage("warning", e.message);
				setNextEvent("admin.changePassword");

			} catch(lock e) {
				setMessage("error", e.message);
				setNextEvent("admin.changePassword");
			}
		</cfscript>
	</cffunction>	
	
	<cffunction name="doSaveRoutes">
		<cfscript>
			checkLoggedInUser();
			
			try {
				var routesFile = getSetting("bricks.routesConfig");
				var content = trim(getValue("editor"));
				if(content eq "")
					throw(type="validation", message="Routes definition cannot be empty");
				if(!isXml(content))
					throw(type="validation",message="Routes definition has to be a valid XML file");
					
				fileWrite(expandPath(routesFile),content,"utf-8");	
					
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
			checkLoggedInUser();
			
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
			checkLoggedInUser();
			
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
			checkLoggedInUser();
			
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
				
	<cffunction name="doCreateLayoutFolder">
		<cfscript>
			checkLoggedInUser();
			
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
			checkLoggedInUser();
			
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
			checkLoggedInUser();
			
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
			checkLoggedInUser();
			
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
					
				setMessage("info", "Layout page created");
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
			checkLoggedInUser();
			
			try {
				var path = trim(getValue("path"));
				var name = trim(getValue("name"));
				var hp = getService("homePortals");
				var pp = hp.getPageProvider();

				pp.delete(path & name);
					
				setMessage("info", "Layout page deleted");
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
			checkLoggedInUser();
			
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
			checkLoggedInUser();
			
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

	<cffunction name="doCreateResourcePackage">
		<cfscript>
			checkLoggedInUser();
			
			try {
				var resourceLibrarypath = getSetting("bricks.resourceLibrarypath");
				var path = trim(getValue("package"));
				var name = trim(getValue("name","new_folder"));

				if(name eq "")
					throw(type="validation", message="Folder name cannot be empty");

				if(right(path,1) neq "/")
					path = path & "/";
					
				var tmpName = name;
				var index = 1;
				while(directoryExists(resourceLibrarypath & path & tmpName)) {
					tmpName = name & index;
					index++;
				}

				directoryCreate(expandPath(resourceLibrarypath & path & tmpName));
					
				setMessage("info", "Folder created");
				setNextEvent("admin.resources","package=#path#&type=#type#");

			} catch(validation e) {
				setMessage("warning", e.message);
				setNextEvent("admin.resources","package=#path#&type=#type#");

			} catch(any e) {
				setMessage("error", e.message);
				setNextEvent("admin.resources","package=#path#&type=#type#");
			}
		</cfscript>
	</cffunction>

	<cffunction name="doDeleteResourcePackage">
		<cfscript>
			checkLoggedInUser();
			
			try {
				var resourceLibrarypath = getSetting("bricks.resourceLibrarypath");
				var path = trim(getValue("package"));
				var name = trim(getValue("name"));

				directoryDelete(resourceLibrarypath & path & name, true);
					
				setMessage("info", "Folder deleted");
				setNextEvent("admin.resources","package=#path#&type=#type#");

			} catch(validation e) {
				setMessage("warning", e.message);
				setNextEvent("admin.resources","package=#path#&type=#type#");

			} catch(any e) {
				setMessage("error", e.message);
				setNextEvent("admin.resources","package=#path#&type=#type#");
			}
		</cfscript>
	</cffunction>

	<cffunction name="doRenameResourcePackage">
		<cfscript>
			checkLoggedInUser();
			
			try {
				var resourceLibrarypath = getSetting("bricks.resourceLibrarypath");
				var path = trim(getValue("package"));
				var name = trim(getValue("name"));
				var newname = trim(getValue("newname"));

				directoryRename(resourceLibrarypath & path & name, resourceLibrarypath & path & newName);
					
				setMessage("info", "Folder renamed");
				setNextEvent("admin.resources","package=#path#&type=#type#");

			} catch(validation e) {
				setMessage("warning", e.message);
				setNextEvent("admin.resources","package=#path#&type=#type#");

			} catch(any e) {
				setMessage("error", e.message);
				setNextEvent("admin.resources","package=#path#&type=#type#");
			}
		</cfscript>
	</cffunction>

	<cffunction name="doSaveResource">
		<cfscript>
			checkLoggedInUser();
			
			var hp = getService("homePortals");
			
			try {
				resType = getValue("type");
				package = getValue("package");
				resourceID = getValue("id");
				isNew = getValue("_isnew",false);
				resPrefix = "props";
				
				// get resource ID
				if(isNew)
					resourceID = getValue("_id"); 
				
				if(resourceID eq "") {
					throw(type="validation",message="Resource name/id cannot be empty");
				}
				
				if(isNew) {
					var rlm = hp.getResourceLibraryManager();
					var resLib = rlm.getResourceLibrary("content/resources");
					oResourceBean = resLib.getNewResource(resType);
					oResourceBean.setID(resourceID);
					oResourceBean.setPackage(package); 
				} else {
					oResourceBean = hp
									.getCatalog()
									.getResource(resType, resourceID, true);
				}

				for(arg in form) {
					// update resource properties
					if(left(arg,len(resPrefix)) eq resPrefix
						and listLast(arg,"_") neq "default") {
						if(form[arg] eq "_NOVALUE_")
	   						oResourceBean.setProperty(replaceNoCase(arg,resPrefix & "_",""),"");
						else
	   						oResourceBean.setProperty(replaceNoCase(arg,resPrefix & "_",""),form[arg]);
					}
				}
				oResourceBean.getResourceLibrary().saveResource(oResourceBean);

				// update body
				if(structKeyExists(form, "_filebody")) {
					oResourceBean.getResourceLibrary().saveResourceFile(oResourceBean, 
																		form["_filebody"], 
																		form["_filename"], 
																		form["_filecontenttype"]);
				}
				
				// upload file
				if(structKeyExists(form, "_file") and form["_file"] neq "") {
					pathSeparator =  createObject("java","java.lang.System").getProperty("file.separator");
					path = getTempFile(getTempDirectory(),"bricksFileUpload");
					stFileInfo = fileUploadInternal("_file", path);
					if(not stFileInfo.fileWasSaved)	throw(message="File upload failed",type="failedUpload");
					path = stFileInfo.serverDirectory & pathSeparator & stFileInfo.serverFile;
	
					oResourceBean.getResourceLibrary().addResourceFile(oResourceBean, 
																		path, 
																		stFileInfo.clientFile, 
																		stFileInfo.contentType & "/" & stFileInfo.contentSubType);
				}

				// reinit homeportals
				getService("homePortals").reinit();

				setMessage("info", "Resource saved");
				setNextEvent("admin.resources","type=#restype#&package=#package#");

			} catch(validation e) {
				setMessage("warning", e.message);
				setNextEvent("admin.resource","type=#restype#&package=#package#&id=#id#");

			} catch(any e) {
				setMessage("error", e.message);
				setNextEvent("admin.resource","type=#restype#&package=#package#&id=#id#");
			}
		</cfscript>
	</cffunction>		
	
	<cffunction name="doDeleteResource">
		<cfscript>
			checkLoggedInUser();
			
			try {
				var path = trim(getValue("package"));
				var type = trim(getValue("type"));
				var id = trim(getValue("id"));

				var hp = getService("homePortals");
				var rlm = hp.getResourceLibraryManager();
				
				var resLib = rlm.getResourceLibrary("content/resources");
				resLib.deleteResource(id, type, path);

				// reinit homeportals
				getService("homePortals").reinit();
				
				setMessage("info", "Resource deleted");
				setNextEvent("admin.resources","package=#path#&type=#type#");

			} catch(validation e) {
				setMessage("warning", e.message);
				setNextEvent("admin.resources","package=#path#&type=#type#");

			} catch(any e) {
				setMessage("error", e.message);
				setNextEvent("admin.resources","package=#path#&type=#type#");
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

	<cffunction name="fileUploadInternal" access="private" returntype="struct">
		<cfargument name="fieldName" type="string" required="true">
		<cfargument name="destPath" type="string" required="true">
		
		<cfset var stFile = structNew()>
		
		<cffile action="upload" 
				filefield="#arguments.fieldName#" 
				nameconflict="makeunique"  
				result="stFile"
				destination="#arguments.destPath#">
		
		<cfreturn stFile>
	</cffunction>		
</cfcomponent>