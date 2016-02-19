 Galaxy-installer
 
 Steps to run :
 
1. Download  nsis.
-Download link  : https://sourceforge.net/projects/nsis/files/latest/download
-or visit here:
-https://sourceforge.net/projects/nsis/


2. Download JDK  and Rename:
-http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html
-download 32 and 64 bit both. and rename it as "jdk-8-win-32.exe" and "jdk-8-win-64.exe"


3. tomcat Download:
http://www.us.apache.org/dist/tomcat/tomcat-8/v8.0.32/bin/apache-tomcat-8.0.32-windows-x86.zip
http://www.us.apache.org/dist/tomcat/tomcat-8/v8.0.32/bin/apache-tomcat-8.0.32-windows-x64.zip
or visit here:
https://tomcat.apache.org/

4. keep both JDK and Tomcat to the installer folder.

5. plugin copy paste:
-open the installed NSIS directory.
-open the plugIN folder.
-copy the .nsh from plugIN folder and paste it to the NSIS-->Include directory
-copy the .dll from plugIN folder and paste it to the NSIS-->Plugins directory

6. right click on galaxy-installer.nsi file and select "Compile NSIS Script" (it will create "galaxy-installer.exe" in the same folder ) 

7. run "galaxy-installer.exe"
