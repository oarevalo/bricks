<cfoutput>
	<ul class="breadcrumb">
		<li><i class="icon-home"></i> <a href="index.cfm?event=admin.home">Home</a> <span class="divider">/</span></li>
		<li>Setup <span class="divider">/</span></li>
		<li class="active">Change Password</li>
	</ul>
	<h1>Change Password</h1>

	<div style="height:100%;">
		<form name="frm" method="post" action="index.cfm">
			<input type="hidden" name="event" value="admin.doChangePassword">
			<b>New Password:</b> <input type="password" name="newpassword" value="" /> <br />
			<b>Retype Password:</b> <input type="password" name="newpassword2" value="" /> <br /><br />
			<input type="submit" class="btn" value="Apply Changes">
		</form>
	</div>
</cfoutput>
