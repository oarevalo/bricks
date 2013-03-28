<cfcomponent extends="homePortals.components.contentTagRenderer" hint="Renders the Bootstrap Navbar.">
	<cfproperty name="pages" default="" type="string" hint="List of pages to display on the menu. If empty, includes all pages in the current folder. You can use the format: page|title to provide a custom nav title for each page.">
	<cfproperty name="folder" default="" type="string" hint="Use this attribute to list all pages on the given folder. This is only used if the 'pages' argument is empty.">
	<cfproperty name="exclude" default="" type="string" hint="List of pages to exclude from the menu. This only takes effect when the 'pages' argument is empty.">
	<cfproperty name="pageHREF" type="string" hint="Use this field to provide the format for the page URLs on the menu. To indicate the page name of the selected item, use the token %pageName. By default is '?page=%pageName'" />
	<cfproperty name="currentPage" type="string" hint="The path of the page to use as currently selected. Optional. By default uses the path of the current homeportals page" />

	<cfset variables.DEFAULT_PAGE_HREF = "?page=%pageName">
	<cfset variables.DEFAULT_SHOW_SEARCH = true>
	<cfset variables.DEFAULT_SEARCH_TARGET = "">
	<cfset variables.DEFAULT_SEARCH_PARAM = "q">

	<cffunction name="renderContent" access="public" returntype="void" hint="sets the rendered output for the head and body into the corresponding content buffers">
		<cfargument name="headContentBuffer" type="homePortals.components.singleContentBuffer" required="true">	
		<cfargument name="bodyContentBuffer" type="homePortals.components.singleContentBuffer" required="true">
		<cfset arguments.bodyContentBuffer.set( renderMenu() ) />
	</cffunction>

	<cffunction name="renderMenu" access="private" returntype="string" >
		<cfset var tmpHTML = "">
		<cfset var pages = getContentTag().getAttribute("pages")>
		<cfset var folder = getContentTag().getAttribute("folder")>
		<cfset var exclude = getContentTag().getAttribute("exclude")>
		<cfset var itemHREFMask = getContentTag().getAttribute("pageHREF",variables.DEFAULT_PAGE_HREF)>
		<cfset var thisPageHREF = getContentTag().getAttribute("currentPage",trim(getPageRenderer().getPageHREF()))>
		<cfset var showSearch = getContentTag().getAttribute("showSearch",variables.DEFAULT_SHOW_SEARCH)>
		<cfset var searchTarget = getContentTag().getAttribute("searchTarget",variables.DEFAULT_SEARCH_TARGET)>
		<cfset var searchParam = getContentTag().getAttribute("searchParam",variables.DEFAULT_SEARCH_PARAM)>
		<cfset var thisFolder = "/">
		<cfset var qryPages = 0>
		<cfset var pp = getPageRenderer().getHomePortals().getPageProvider()>

		<!--- get custom css class and apply to navbar element --->
		<cfset var navbarClass = getContentTag().getModuleBean().getCSSClass()>
		<cfset getContentTag().getModuleBean().setCSSClass("")>
		
		<!--- get the module title and use it inline with the navbar --->
		<cfset var navTitle = getContentTag().getModuleBean().getTitle()>
		<cfset getContentTag().getModuleBean().setTitle("")>

		<!--- get the nav title href from the current app root --->
		<cfset var navTitleHREF = getHomePortals().getConfig().getAppRoot()>

		<cfif listLen(thisPageHREF,"/") gt 1>
			<cfset thisFolder = listDeleteAt(thisPageHREF,listLen(thisPageHREF,"/"),"/") & "/">
		</cfif>
		
		<cfif pages eq "" and folder neq "">
			<cfset thisFolder = folder>
			<cfif left(thisFolder,1) neq "/">
				<cfset thisFolder = thisFolder & "/">
			</cfif>
		</cfif>
		
		<cfif pages eq "">
			<cfset qryPages = pp.listFolder(thisFolder)>
			
			<cfquery name="qryPages" dbtype="query">
				SELECT name, UPPER(name) as name_u
					FROM qryPages
					WHERE type NOT LIKE 'folder'
					<cfif exclude neq "">
						AND name not in (<cfqueryparam cfsqltype="cf_sql_varchar" value="#exclude#" list="true">)
					</cfif>
					ORDER BY name_u
			</cfquery>
			
			<cfloop query="qryPages">
				<cfset pages = listAppend(pages,thisFolder & qryPages.name)>
			</cfloop>
		</cfif>

		<cfset var items = []>
		<cfloop list="#pages#" index="page">
			<cfif page eq "|">
				<cfset arrayAppend(items,{type="divider"})>
			<cfelse>
				<cfif listLen(page,"|") gt 1>
					<cfset href = listFirst(page,"|")>
					<cfset label = listLast(page,"|")>
				<cfelse>
					<cfset href = page>
					<cfset label = listLast(page,"/")>
				</cfif>
				<cfif left(href,1) eq "/">
					<cfset href = right(href,len(href)-1)>
				</cfif>
				<cfset itemHREF = replaceNoCase(itemHREFMask,"%pageName",urlEncodedFormat(href),"ALL")>
				<cfset arrayAppend(items,{type="link",label=label,href=itemHref,active=(href eq thisPageHREF or "/" & href eq thisPageHREF)})>
			</cfif>
		</cfloop>


		<cfsavecontent variable="tmpHTML">
			<cfoutput>
				<div class="navbar #navbarClass#">
					<div class="navbar-inner">
						<cfif navTitle neq "">
							<a class="brand" href="#navTitleHREF#">#navTitle#</a>
						</cfif>
						<ul class="nav">
							<cfloop array="#items#" index="page">
								<cfif page.type eq "divider">
									<li class="divider-vertical"></li>
								<cfelse>
									<li <cfif page.active>class="active"</cfif>><a href="#page.href#">#page.label#</a></li>
								</cfif>
							</cfloop>
						</ul>
						<cfif showSearch>
					        <form class="navbar-form form-search pull-right" method="GET" action="#searchTarget#" accept-charset="UTF-8">
					          <div class="input-append">
					            <input type="text" name="#searchParam#" class="span2 search-query" placeholder="Search...">
					            <button type="submit" class="btn">Search</button>
					          </div>
					        </form>
						</cfif>
					</div>
				</div>
			</cfoutput>
		</cfsavecontent>
		<cfreturn tmpHTML>
	</cffunction>	
	
</cfcomponent>