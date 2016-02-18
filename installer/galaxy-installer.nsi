!include "FileFunc.nsh"
!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "winmessages.nsh"
!include "EnvVarUpdate.nsh"
!include "nsDialogs.nsh"
!include StrRep.nsh
!include ReplaceInFile.nsh
!include ZipDLL.nsh
!include "x64.nsh"

!define env_hklm 'HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"'
!define env_hkcu 'HKCU "Environment"'
   
!define APPNAME "Series booking tool"
!define JDK_INSTALLER32 "jdk-8-win-32.exe"
!define JDK_INSTALLER64 "jdk-8-win-64.exe"
!define JDK_VERSION "1.8"
!define TOMCAT32 "apache-tomcat-8.0.30-win-x32"
!define TOMCAT64 "apache-tomcat-8.0.30-win-x64"
!define TOMCAT_FOLDER "apache-tomcat-8.0.30"
!define DEFAULT_PROGRAM_PATH "C:\Program Files\SBT"
!define DEFAULT_DATA_PATH "C:\ProgramData\SBT"
!define TOMCAT_SERVICE "Tomcat8"
!define MUI_ICON "icon.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "icon.bmp"
!define MUI_HEADERIMAGE_RIGHT

Name "${APPNAME}"
OutFile "galaxy-installer.exe"

InstallDir "$PROGRAMFILES\SBT"

XPStyle on

Var Dialog
Var User
Var Pass
Var Port
Var Label
Var Label2
Var Label3
Var TOMCAT
Var JDK

RequestExecutionLevel admin

;Interface Settings
!define MUI_ABORTWARNING
 ;--------------------------------
;Pages 
Page custom nsDialogsPage nsDialogsPageLeave
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES  
;--------------------------------
;Languages 
!insertmacro MUI_LANGUAGE "English"
!insertmacro GetTime
;--------------------------------


;Installer Sections
Section "Install" Install	
	;CreateDirectory "$INSTDIR\${TOMCAT}"	
	File "galaxy.properties"
	File "run.bat"
	
	File "${TOMCAT32}.zip"
	File "${TOMCAT64}.zip"
	
	
		
	;File /nonfatal /a /r "tomcat08\"	

	${GetTime} "" "L" $0 $1 $2 $3 $4 $5 $6
	Rename "${DEFAULT_DATA_PATH}\galaxy.properties" "${DEFAULT_DATA_PATH}\galaxy.properties.$2$1$0 $4$5"
	CopyFiles galaxy.properties "${DEFAULT_DATA_PATH}"
	;CopyFiles tomcat8 "$INSTDIR"
	CopyFiles run.bat "$INSTDIR"
	
	${If} ${RunningX64}
		;MessageBox MB_OK "64"	
		StrCpy $TOMCAT "${TOMCAT64}"
		StrCpy $JDK "JDK_INSTALLER64"
	${Else}
		;MessageBox MB_OK "32"
		StrCpy $TOMCAT "${TOMCAT32}"
		StrCpy $JDK "JDK_INSTALLER32"
	${EndIf}.
	
	;MessageBox MB_OK "$TOMCAT"
	CopyFiles "$TOMCAT.zip" "$INSTDIR"
	
	;extract tomcat 
	ZipDLL::extractall "$INSTDIR\$TOMCAT.zip" "$INSTDIR\"
	;delete tomcat default server.xml and tomcat-users.xml files
	Delete "$INSTDIR\${TOMCAT_FOLDER}\conf\server.xml"
	Delete "$INSTDIR\${TOMCAT_FOLDER}\conf\tomcat-users.xml"
	Delete "$INSTDIR\${TOMCAT_FOLDER}\bin\service.bat"
	;Copy modified files to tomcat
	CopyFiles "$INSTDIR\server.xml" "$INSTDIR\${TOMCAT_FOLDER}\conf\"
	CopyFiles "$INSTDIR\tomcat-users.xml" "$INSTDIR\${TOMCAT_FOLDER}\conf\"
	CopyFiles "$INSTDIR\service.bat" "$INSTDIR\${TOMCAT_FOLDER}\bin\"
	CopyFiles "$INSTDIR\run.bat" "$INSTDIR\${TOMCAT_FOLDER}\bin\"
	
	Call WriteRegistry		
	Call RemoveTomcatService
	;Call InstallTomcatService
	Call CreateShortcuts
SectionEnd


Function EnvVariableSET
   ; set variable
   ReadRegStr $1 HKLM "SOFTWARE\JavaSoft\Java Development Kit" "CurrentVersion"
   ReadRegStr $2 HKLM "SOFTWARE\JavaSoft\Java Development Kit\$1" "JavaHome"
   WriteRegExpandStr ${env_hklm} JAVA_HOME "$2"
   ${EnvVarUpdate} $0 "PATH" "A" "HKLM" "$2\bin"
   SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=1000
   WriteRegExpandStr ${env_hklm} CATALINA_HOME "$INSTDIR\${TOMCAT_FOLDER}"
   ; make sure windows knows about the change	
    ${EnvVarUpdate} $0 "PATH" "A" "HKLM" "$INSTDIR\${TOMCAT_FOLDER}\bin"  
   SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=1000  
   
   !insertmacro _ReplaceInFile "$INSTDIR\service.bat" "%JAVA_HOME%" $2
FunctionEnd


;Create custom page where username, password and port can be input
Function nsDialogsPage
	SetOutPath "$INSTDIR"
	;ReadRegStr $1 HKLM "SOFTWARE\JavaSoft\Java Runtime Environment" "CurrentVersion"
	;MessageBox MB_OK "Java version $1"
	ReadRegStr $1 HKLM "SOFTWARE\JavaSoft\Java Development Kit" "CurrentVersion"
	File "${JDK_INSTALLER32}"
	File "${JDK_INSTALLER64}"	
		
	${If} $1 != ${JDK_VERSION}
		MessageBox MB_OK "Java 1.8 installing..."	
		ExecWait "$INSTDIR\$JDK"
	${Else}
		; Else somethigs...
	${EndIf}
	
	
	CreateDirectory "$INSTDIR"
	CreateDirectory "${DEFAULT_DATA_PATH}"	
	AccessControl::GrantOnFile "$INSTDIR\" "(BU)" "GenericRead + GenericWrite"
	AccessControl::GrantOnFile "${DEFAULT_DATA_PATH}\" "(BU)" "GenericRead + GenericWrite"
	File "server.xml" 
	File "tomcat-users.xml" 
	File "service.bat"
	CopyFiles "server.xml" "$INSTDIR\"
	CopyFiles "tomcat-users.xml" "$INSTDIR\"
	CopyFiles "service.bat" "$INSTDIR\"
	Call EnvVariableSET
	nsDialogs::Create 1018
	Pop $Dialog

	${If} $Dialog == error
		Abort
	${EndIf}

	${NSD_CreateLabel} 10u 10u 30% 12u "Administrator User Name"
	Pop $Label

	${NSD_CreateText} 100u 10u 50% 12u "sbtadmin"
	Pop $User	
	
	${NSD_CreateLabel} 10u 25u 25% 12u "Administrator Password"
	Pop $Label2

	${NSD_CreateText} 100u 25u 50% 12u "sbtadmin123"
	Pop $Pass
	
	${NSD_CreateLabel} 10u 40u 25% 12u "Tomcat Port"
	Pop $Label3

	${NSD_CreateText} 100u 40u 50% 12u "8080"
	Pop $Port
	
	nsDialogs::Show

FunctionEnd

Function nsDialogsPageLeave

	${NSD_GetText} $User $0
	${NSD_GetText} $Pass $1
	${NSD_GetText} $Port $2
	;MessageBox MB_OK "User : $0 $\n Pass: $1 $\n Port: $2"
	
	${If} $0 == ""
        MessageBox MB_OK "Please enter user name"
        Abort
	${EndIf}
 	${If} $1 == ""
        MessageBox MB_OK "Please enter password"
        Abort 
	${EndIf}
	${If} $2 == ""
        MessageBox MB_OK "Please enter port (e.g. Default port is 8080)"
        Abort
    ${EndIf}
	; create tomcate user	
	!insertmacro _ReplaceInFile "$INSTDIR\tomcat-users.xml" "#USER#" $0
	!insertmacro _ReplaceInFile "$INSTDIR\tomcat-users.xml" "#PASS#" $1
	!insertmacro _ReplaceInFile "$INSTDIR\server.xml" "#PORT#" $2
FunctionEnd

;Install TOMCAT32 as a service
Function InstallTomcatService
	;SimpleSC::InstallService "${TOMCAT_SERVICE}" "Apache TOMCAT32 8" "16" "2" "$INSTDIR\${TOMCAT32}\bin\tomcat8.exe" "" "" ""
	;SimpleSC::SetServiceDescription "${TOMCAT_SERVICE}" "Apache TOMCAT32 8"
	;ExecWait "$INSTDIR\${TOMCAT32}\bin\service.bat install Tomcat8"	
	;ExecWait "sc config ${TOMCAT_SERVICE} start= auto"
	;SimpleSC::SetServiceStartType "Tomcat8" "2"
	;SimpleSC::StartService "Tomcat8" "" 10
	;ExecWait "$INSTDIR\${TOMCAT32}\bin\run.bat"
	;Pop $0
	;MessageBox MB_OK "Tomcat8 service $0"
	;${If} $0 == 0 
	;	MessageBox MB_OK "TOMCAT32 service starting OK"
	;${EndIf}	
FunctionEnd

Function RemoveTomcatService
  ; Check if the service exists
	SimpleSC::ExistsService "Tomcat8"
	Pop $0 ; returns an errorcode if the service doesn´t exists (<>0)/service exists (0)	
	${If} $0 == 0 
		;MessageBox MB_OK "Tomcat8 Service is exists!!"
		SimpleSC::StopService "Tomcat8" 1 5
		SimpleSC::RemoveService "Tomcat8"		
	${EndIf}	
FunctionEnd

;Create StartMenu shortcut
Function CreateShortcuts
	;CreateShortCut "$SMPROGRAMS\SBT start.lnk" "$INSTDIR\run.bat"
	CreateShortCut "$SMPROGRAMS\SBT admin.lnk" "$INSTDIR\${TOMCAT_FOLDER}\bin\run.bat"
	CreateShortCut "$SMPROGRAMS\SBT uninstall.lnk" "$INSTDIR\Uninstall ${APPNAME}.exe"
FunctionEnd

Function WriteRegistry
	WriteUninstaller "$INSTDIR\Uninstall ${APPNAME}.exe"

	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" \
                 "DisplayName" "${APPNAME}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" \
                 "UninstallString" "$INSTDIR\Uninstall ${APPNAME}.exe"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" \
                 "Publisher" "Metafour"
FunctionEnd

;Uninstaller Section

Section "Uninstall"
  ;ADD YOUR OWN FILES HERE...
  Delete "$INSTDIR\galaxy.properties"
  Delete "$INSTDIR\run.bat"
  Delete "$INSTDIR\service.bat"
  Delete "$INSTDIR\Uninstall ${APPNAME}.exe"
  RMDir /r "$INSTDIR\${TOMCAT_FOLDER}"  
  RMDir /r "$INSTDIR"
  
  ReadRegStr $1 HKLM "SOFTWARE\JavaSoft\Java Development Kit" "CurrentVersion"
  ;ReadRegStr $2 HKLM "SOFTWARE\JavaSoft\Java Development Kit\$1" "JavaHome"
  ${un.EnvVarUpdate} $0 "PATH" "R" "HKLM" "$2\bin" 
  ${un.EnvVarUpdate} $0 "PATH" "R" "HKLM" "$INSTDIR\$TOMCAT\bin" 
  ;${un.EnvVarUpdate} $0 "JAVA_HOME" "R" "HKLM" "$2" 
  ${un.EnvVarUpdate} $0 "CATALINA_HOME" "R" "HKLM" "$INSTDIR\$TOMCAT" 
	;DeleteRegValue ${env_hklm} "JAVA_HOME"
	DeleteRegValue ${env_hklm} "CATALINA_HOME"
   ; make sure windows knows about the change
   SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

  
   
	SimpleSC::ExistsService "${TOMCAT_SERVICE}"
	Pop $0
	${If} $0 == 0 
		;SimpleSC::GetServiceStatus "${TOMCAT_SERVICE}"
		;Pop $1
		;${If} $1 == 0
		;SimpleSC::StopService "${TOMCAT_SERVICE}"
		;${EndIf}
		SimpleSC::RemoveService "${TOMCAT_SERVICE}"
		SimpleSC::StopService "Tomcat8" 1 5		
	${EndIf}	
	
	;ExecWait "net stop Tomcat8"
	
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}"
SectionEnd
