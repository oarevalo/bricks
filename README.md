bricks
======

Bricks is an skeleton-ish/scaffold-ish/framework-ish web app for building content-driven websites that can also be easily extended with custom logic and actions. 

It has an included password-protected admin console that is used to manage content, configuration and site navigation, but can be easily extended for other uses.


Features
-----------
* 0 external dependencies (download, unpack and go)
* No restriction on directory naming (can be deployed to webroot too)
* Built-in password protected admin console
* Baked-in Twitter Bootstrap and JQuery
* Admin console is extensible with custom event handlers and views
* Content is independent of page layout
* Page layout (what types of things go in which regions) is independent from page markup (the actual html) 
* Custom content types (html, images, rss feeds, can also define your own)
* Regular expression based routing


Getting Started
----------
    cd /path/to/webroot
    git clone https://github.com/oarevalo/bricks.git {your_site_dir}

On your browser go to
	http://your_server/your_site_dir
	
For the admin app
	http://your_server/your_site_dir/admin

Default admin user and password is "admin" / "password"


Requirements
-----------
* Railo 3 or higher
* Adobe ColdFusion 9 o higher


