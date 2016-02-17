



sc query Tomcat8 | find /i "RUNNING"
if "%ERRORLEVEL%"=="1" (

	call service.bat install Tomcat8
	net stop Tomcat8
	net start Tomcat8
	sc config Tomcat8 start= auto
    
) else (    
	echo Program is running
)

::start iexplore.exe http://localhost:8080/galaxy-tools/admin

::start "Chrome" chrome --new-window http://localhost:8080/galaxy-tools/admin
::--fullscreen

start "Chrome" chrome --fullscreen  http://localhost:8080/galaxy-tools/admin