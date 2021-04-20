@ECHO OFF
@setlocal enabledelayedexpansion

@echo:
@echo:

::configure src,build and deployment name in openshift
set buildConfig-src-name=buildConfigSrcName
set buildConfig-runtime-name=buildConfigRuntimeName
set deployment-name=DeploymentName

echo OpenShift deployment for !deployment-name!

@echo:

echo for snapshot enter 1
echo for release enter 2

@echo:

set /p decision=Enter choice: 


if !decision! ==1 (
	set repositoryName=mvn-snapshot-local
	
	set snapshot=-SNAPSHOT
	
	set /p version=enter snapshot version: 
	set versionToDeploy=!version!!snapshot!
	
	echo trying to deploy snapshot version !versionToDeploy! from repositoryName !repositoryName!
	goto deployprocess
	
)else if !decision!==2 (
	set repositoryName=mvn-private-local
	
	set /p version=enter release version: 
	set versionToDeploy=!version!
	
	echo trying to deploy release version !versionToDeploy! from repositoryName !repositoryName!
	goto deployprocess
	
)else (
	echo no existing choice !decision! !
	goto wrongprocess
)
	


:deployprocess
	
	oc login https://console.int.de.paas.intranet.db.com -u=username -p=password

	:: 1.src build

	oc start-build !buildConfig-src-name! --env=VERSION=!versionToDeploy! --env=REPO_NAME=!repositoryName! --wait=true --follow

	:: 2.runtime build
	oc start-build !buildConfig-runtime-name! --wait=true --follow

	:: 3.scale down
	echo scale down to 0 pod
	oc scale deploy !deployment-name! --replicas=0

	:: 4.scale up
	
	echo scale up to 1 pod
	oc scale deploy !deployment-name! --replicas=1 


	::5. logs of the app 
	::oc logs deploy/!deployment-name!

	PAUSE

:wrongprocess 
	PAUSE