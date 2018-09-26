@ECHO OFF
cd gko3-angular-client/

ECHO create angular build folder............
CALL grunt
ECHO create angular build folder succesfull.....

cd ../gko3-web/src/main/resources/static/
ECHO remove static folder

RMDIR static /S /Q
mkdir static
ECHO remove static folder succesfull.....
cd ../../../../..

ECHO moving build folder to static........
xcopy gko3-angular-client\build gko3-web\src\main\resources\static /e /i /h /y
ECHO moving build folder to static succesfull..........

ECHO building war file..........
CALL mvn clean install
PAUSE;
