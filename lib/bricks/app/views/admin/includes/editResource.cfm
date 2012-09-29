	<cfoutput>
		<table width="100%">
			<cfif isNew>
				<tr>
					<td nowrap="nowrap" style="width:80px;"><b>Name:</b></td>
					<td><input type="text" name="_id" value="" class="cms-formField"></td>
				</tr>
			</cfif>
			<cfif resourceTypeConfig.getFileTypes() neq "">
				<input type="hidden" name="_filename" value="#fileName#">
				<tr>
					<td colspan="2">
						<cfif isText>
							<cfif isRichText>
								<script src="#request.libRoot#codeMirror/codemirror.js"></script>
								<link rel="stylesheet" href="#request.libRoot#codeMirror/codemirror.css">
								<script src="#request.libRoot#codeMirror/mode/xml.js"></script>
								<script src="#request.libRoot#codeMirror/mode/javascript.js"></script>
								<script src="#request.libRoot#codeMirror/mode/css.js"></script>
								<script src="#request.libRoot#codeMirror/mode/htmlmixed.js"></script>
								<input type="hidden" name="_filecontenttype" value="text/html">
								<textarea name="_filebody" rows="15" cols="50" id="_filebody" class="cms-formField" style="width:100%;background-color:##fff;">#fileContent#</textarea><br />
								<script type="text/javascript">
									var myCodeMirror = CodeMirror.fromTextArea(document.getElementById("_filebody"), {
								        lineNumbers: true,
									  mode:  "text/html"
									});
									myCodeMirror.setSize("100%",400)
								</script> 
							<cfelse>
								<input type="hidden" name="_filecontenttype" value="text/plain">
								<textarea name="_filebody" rows="15" cols="50" id="_filebody" class="cms-formField" style="width:100%;background-color:##fff;">#fileContent#</textarea><br />
							</cfif>
						<cfelseif isImage>
							<cfimage action="resize"
									    width="100" height="" 
									    source="#tmpFullPath#"
									    name="resImage">
							<a href="#tmpFullHREF#"><cfimage action="writeToBrowser" source="#resImage#"></a>
						</cfif>
					</td>
				</tr>
				<tr>
					<td nowrap="nowrap" style="width:80px;"><b>Upload:</b></td>
					<td><input type="file" name="_file" value="" class="cms-formField" style="width:auto;"></td>
				</tr>
			</cfif>
	
			<cfif lstPropsConfig neq "">
				<cfloop list="#lstPropsConfig#" index="key">
					<cfset tmpValue = "">
					<cfset tmpLabel = key>
					<cfset lstValues = "">
					<cfset tmpType = propsConfig[key].type>
					
					<cfif structKeyExists(props,key)>
						<cfset tmpValue = trim(props[key])>
					<cfelseif propsConfig[key].default neq "">
						<cfset tmpValue = propsConfig[key].default>
					</cfif>
					<cfif propsConfig[key].label neq "">
						<cfset tmpLabel = propsConfig[key].label>
					</cfif>
					<cfif listLen(propsConfig[key].type,":") eq 2 and listfirst(propsConfig[key].type,":") eq "resource">
						<cfset tmpType = listfirst(propsConfig[key].type,":")>
						<cfset resourceType = listlast(propsConfig[key].type,":")>
					</cfif>
		
					<tr>
						<td nowrap="nowrap" style="width:80px;"><b>#tmpLabel#:</b></td>
						<td>
							<cfswitch expression="#tmpType#">
								<cfcase value="list">
									<cfset lstValues = propsConfig[key].values>
									<select name="props_#key#" class="cms-formField" style="width:150px;">
										<cfif not propsConfig[key].required><option value="_NOVALUE_"></option></cfif>
										<cfloop list="#lstValues#" index="item">
											<option value="#item#" <cfif tmpValue eq item>selected</cfif>>#item#</option>
										</cfloop>
									</select>
									<cfif propsConfig[key].required><span style="color:red;">&nbsp; * required</span></cfif>
								</cfcase>
								
								<cfcase value="resource">
									<cfset qryResources = oCatalog.getIndex(resourceType)>
									<cfquery name="qryResources" dbtype="query">
										SELECT *, upper(package) as upackage, upper(id) as uid
											FROM qryResources
											ORDER BY upackage, uid, id
									</cfquery>
									<select name="props_#key#" class="cms-formField">
										<cfif not propsConfig[key].required><option value="_NOVALUE_"></option></cfif>
										<cfloop query="qryResources">
											<option value="#qryResources.id#"
													<cfif tmpValue eq qryResources.id>selected</cfif>	
														><cfif qryResources.package neq qryResources.id
															>[#qryResources.package#] </cfif>#qryResources.id#</option>
										</cfloop>
									</select>
									<cfif propsConfig[key].required><span style="color:red;">&nbsp; * required</span></cfif>
								</cfcase>
								
								<cfcase value="boolean">
									<cfif propsConfig[key].required>
										<cfset isTrueChecked = (isBoolean(tmpValue) and tmpValue)>
										<cfset isFalseChecked = (isBoolean(tmpValue) and not tmpValue) or (tmpValue eq "")>
									<cfelse>
										<cfset isTrueChecked = (isBoolean(tmpValue) and tmpValue)>
										<cfset isFalseChecked = (isBoolean(tmpValue) and not tmpValue)>
									</cfif>
									
									<input type="radio" name="props_#key#" 
											style="border:0px;width:15px;"
											value="true" 
											<cfif isTrueChecked>checked</cfif>> True 
									<input type="radio" name="props_#key#" 
											style="border:0px;width:15px;"
											value="false" 
											<cfif isFalseChecked>checked</cfif>> False 
									<cfif propsConfig[key].required><span style="color:red;">&nbsp; * required</span></cfif>
								</cfcase>
								
								<cfdefaultcase>
									<input type="text" 
											name="props_#key#" 
											value="#tmpValue#" 
											class="cms-formField">
									<cfif propsConfig[key].required><span style="color:red;">&nbsp; * required</span></cfif>
								</cfdefaultcase>
							</cfswitch>
							<input type="hidden" name="props_#key#_default" value="#propsConfig[key].default#">
						</td>
					</tr>
				</cfloop>
			</cfif>
		</table>

	</cfoutput>

	