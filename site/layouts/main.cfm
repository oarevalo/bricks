<cfsilent>
	<cfset rs = request.requestState />
	<cfset html = rs.renderer.renderPage(rs) />
</cfsilent>
<cfoutput>#html#</cfoutput>