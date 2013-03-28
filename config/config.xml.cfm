<?xml version="1.0" encoding="ISO-8859-1"?>
<config>
	<settings>
		<!-- Web-relative Location of this App -->
		<setting name="bricks.appRoot" value="./" />

		<!-- Bricks settings -->
		<setting name="bricks.usersConfig" value="/bricksApp/config/users.xml.cfm" />
		<setting name="bricks.resourceLibraryPath" value="/bricksApp/content/resources/" />
		<setting name="bricks.routes.config" value="/bricksApp/config/routes.xml" />
		<setting name="bricks.routes.defaultContext" value="default" />
		<setting name="bricks.routes.useFakeSES" value="false" />
		<setting name="bricks.routes.param" value="page" />
			
		<!-- Bug reporting 
		<setting name="bugLog.emailRecipient" value="" />
		<setting name="bugLog.emailSender" value="" />
		<setting name="bugLog.listener" value="" />
		-->
	</settings>

		
	<!-- This section describes all services that will be loaded into the application -->
	<services>
		<service name="homePortals" class="homePortals.components.homePortals">
			<init-param name="appRoot" settingName="bricks.appRoot" />
		</service>

		<service name="routeParser" class="bricksLib.bricks.routeParser">
			<init-param name="configPath" settingName="bricks.routes.config" />
		</service>
		
		<service name="userSessionManager" class="bricksLib.bricks.simpleUserSessionManager">
			<init-param name="configPath" settingName="bricks.usersConfig" />
		</service>
	
		<!-- error reporting service 
		<service name="bugTracker" class="bricksLib.bugLogService">
			<init-param name="bugLogListener" settingName="bugLog.emailRecipient" />
			<init-param name="bugEmailSender" settingName="bugLog.emailSender" />
			<init-param name="bugEmailRecipients" settingName="bugLog.listener" />
		</service>-->

	</services>
</config>

