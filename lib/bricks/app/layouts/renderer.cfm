<cfsilent>
	<cfset rs = request.requestState />
	<cfset html = rs.renderer.renderPage(rs.pageParams) />
</cfsilent><cfoutput>#html#</cfoutput>
