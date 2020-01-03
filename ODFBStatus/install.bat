set SCRIPTDIR=%~dp0
set ODSPATH=c:\programdata\OneDriveStatus
md %ODSPATH%
copy %SCRIPTDIR%\*.dll %ODSPATH% /y
