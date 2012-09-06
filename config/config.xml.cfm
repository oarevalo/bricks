<?xml version="1.0" encoding="ISO-8859-1"?>
<config>
	<settings>
		<!-- Bug reporting -->
		<setting name="bugLog.emailRecipient" value="" />
		<setting name="bugLog.emailSender" value="" />
		<setting name="bugLog.listener" value="" />
	</settings>

		
	<!-- This section describes all services that will be loaded into the application -->
	<services>
		<!-- Application service (service layer) -->
		<service name="homePortals" class="homePortals.components.homePortals">
			<init-param name="appRoot">$APP_PATH</init-param>
		</service>
	
		<!-- error reporting service 
		<service name="bugTracker" class="bricks.components.bugLogService">
			<init-param name="bugLogListener" settingName="bugLog.emailRecipient" />
			<init-param name="bugEmailSender" settingName="bugLog.emailSender" />
			<init-param name="bugEmailRecipients" settingName="bugLog.listener" />
		</service>-->

	</services>
</config>

