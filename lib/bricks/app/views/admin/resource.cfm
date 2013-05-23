<cfscript>
	oCatalog = rs.catalog;
	oResourceBean = rs.resBean;
	resourceTypeConfig = rs.typeInfo;
	
	tmpFullPath = oResourceBean.getFullPath();
	tmpFullHREF = oResourceBean.getFullHref();
	
	propsConfig = resourceTypeConfig.getProperties();
	lstPropsConfig = structKeyList(propsConfig);
	lstPropsConfig = listSort(lstPropsConfig,"textnocase");	
	
	props = oResourceBean.getProperties();
	lstProps = structKeyList(props);
	lstProps = listSort(lstProps,"textnocase");		

	extensions = listToArray(resourceTypeConfig.getFileTypes());
	fileContent = "";
	fileName = "";
	isText = false;
	isPlainText = false;
	isRichText = false;
	isImage = false;
	isEditable = (lstPropsConfig neq "" or resourceTypeConfig.getFileTypes() neq "");
	isNew = (rs.id eq "");

	knownPlainTextExtensions = ["txt","xml"];
	knownRichTextExtensions = ["htm","html","xhtml"];
	for(i=1;i lte arrayLen(extensions);i++) {
		for(j=1;j lte arrayLen(knownPlainTextExtensions);j++) {
			if(extensions[i] eq knownPlainTextExtensions[j]) isPlainText = true;
		}
		for(j=1;j lte arrayLen(knownRichTextExtensions);j++) {
			if(extensions[i] eq knownRichTextExtensions[j]) isRichText = true;
		}
	}
	isText = (isPlainText or isRichText);

	isImage = (tmpFullPath neq "" and fileExists(tmpFullPath) and isImageFile(tmpFullPath));

	// read file
	if(isText and oResourceBean.targetFileExists()) {
		fileContent = oResourceBean.readFile();
		fileName = getFileFromPath( tmpFullHREF );
	}
	
	// build label
	titleLabel = "";
	if(!isNew) {
		if(rs.id neq rs.package and rs.package neq "" and rs.package neq "/")
			titleLabel = rs.package;
		if( right(rs.package,1) neq "/")
			titleLabel = titleLabel & " / ";
		titleLabel = titleLabel & rs.id;
	} else {
		titleLabel = "New #rs.type#";
	}

</cfscript>

<cfoutput>
	<ul class="breadcrumb">
		<li><i class="icon-home"></i> <a href="index.cfm?event=admin.home">Home</a> <span class="divider">/</span></li>
		<li><a href="index.cfm?event=admin.resources&package=#rs.package#&type=#rs.type#">#rs.typeLabel#</a> <span class="divider">/</span></li>
		<li class="active">Add/Edit Resource</li>
	</ul>
	<h1>Add/Edit '#titleLabel#'</h1>
	
	<cfif not isEditable>
		<div class="alert">
			<i class="icon-warning-sign"></i>
			<cfif isNew>
				<em>This resource type has no editable properties and cannot be created manually.</em>
			<cfelse>
				<em>This resource has no editable properties.</em>
			</cfif>
			<br /><br />
			<a href="index.cfm?event=admin.resources&package=#rs.package#&type=#rs.type#">Go Back</a>
		</div>
	<cfelse>
		<form name="frm" method="post" action="index.cfm" enctype="multipart/form-data">
			<input type="hidden" name="event" value="admin.doSaveResource">
			<input type="hidden" name="type" value="#rs.type#" />
			<input type="hidden" name="package" value="#rs.package#">
			<input type="hidden" name="id" value="#rs.id#">
			<input type="hidden" name="_isnew" value="#isNew#">
			
			<cfinclude template="includes/editResource.cfm">
			
			<br />
			<input type="submit" class="btn" value="Apply Changes">
			&nbsp;&nbsp;
			<a href="index.cfm?event=admin.resources&package=#rs.package#&type=#rs.type#">Go Back</a>
		</form>
	</cfif>
</cfoutput>
