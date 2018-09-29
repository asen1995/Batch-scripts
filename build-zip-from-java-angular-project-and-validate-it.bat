@ECHO OFF

set /p newVersionOfProject=Enter the new version: 

cd gko3-angular-client/

:: 1
ECHO create angular build folder............
CALL grunt
ECHO create angular build folder succesfull.....


:: 2 
cd ..

ECHO create zip folders and sources
CALL mvn clean source:jar-no-fork javadoc:jar install
ECHO create zip folders and sources succesfull

:: 3 
ECHO create zip from the files
CALL mvn assembly:single -DdeliveryEnvironment=INT -Dassembly.runOnlyAtExecutionRoot=true
ECHO create zip from the files succesfull


ECHO go now and validate the zip

:: 4 open folder that contains the created zip

cd ./target
start .

:: 5  validate package - for this we have to update JAVA_HOME to 7 which can't happend in one cmd session . There is a tool called 'chocolatey'
:: which refresh enviroment variables in current session. To install it use the command below.

::  @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
:: https://chocolatey.org/install

:: "RefreshEnv.cmd" - refresh enviroment variables in current cmd session 
:: in current proccess, we will set java_home to 7 -> validate -> then return it to previous java version

ECHO start validate zip process

set JAVA_7_PATH=C:\Program Files\Java\jdk1.7.0_55\jdk1.7.0_55
set PREVIOUS_JAVA_PATH=C:\Program Files\Java\jre1.8.0_144
set VALIDATOR_PATH=C:\VendorDeliveryValidator-4.3.0_pw_squares\VendorDeliveryValidator-4.3.0_pw_squares\bin

ECHO change java to 7
setx JAVA_HOME "%JAVA_7_PATH%"
call RefreshEnv.cmd
java -version
ECHO change java to 7 succesfull

ECHO copy zip file to the validator folder
xcopy .\*.zip %VALIDATOR_PATH% /e /i /h /y
ECHO copy zip file to the validator folder succesfull

cd %VALIDATOR_PATH%
ECHO validate zip file
CALL validate -deliveryFile gk_online_fe.esop.delivery-%newVersionOfProject%-delivery.zip
ECHO validate zip file finished
ECHO is this response OK? IF Not -> try again.
PAUSE;

ECHO remove zip file from validator
RMDIR archive-tmp /S /Q
del gk_online_fe.esop.delivery-%newVersionOfProject%-delivery.zip
ECHO remove zip file from validator finished
PAUSE;

ECHO change java to previous
setx JAVA_HOME "%PREVIOUS_JAVA_PATH%"
call RefreshEnv.cmd
ECHO change java to previous succesfull
java -version
ECHO changed back to previous java version

ECHO validate zip process finished

PAUSE;
