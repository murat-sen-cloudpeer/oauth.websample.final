#!/bin/bash

###################################################################################
# A script to run minimal components needed to run an SPA and token handler locally
# A simple web host runs locally, with the token handler running in Docker
#################################################################################

WEB_ORIGIN='https://web.mycompany.com'
TOKEN_HANDLER_BASE_URL='https://api.mycompany.com:444/token-handler'

#
# Get the platform
#
case "$(uname -s)" in

  Darwin)
    PLATFORM="MACOS"
 	;;

  MINGW64*)
    PLATFORM="WINDOWS"
	;;
esac

#
# Run the SPA, WebHost, and Back End for Front End in separate terminal windows
#
if [ "$PLATFORM" == 'MACOS' ]; then
    open -a Terminal ./spa/deploy.sh
    open -a Terminal ./webhost/deploy.sh
    open -a Terminal ./.tmp/oauth.tokenhandlerapi/deploy.sh
    
else
    GIT_BASH="C:\Program Files\Git\git-bash.exe"
    "$GIT_BASH" -c ./spa/deploy.sh &
    "$GIT_BASH" -c ./webhost/deploy.sh &
    "$GIT_BASH" -c ./.tmp/oauth.tokenhandlerapi/deploy.sh &
fi

#
# Wait for the Token Handler API to come up
#
echo "Waiting for Token Handler API to become available ..."
while [ "$(curl -k -s -X POST -H "origin:$WEB_ORIGIN" -o /dev/null -w ''%{http_code}'' "$TOKEN_HANDLER_BASE_URL/login/start")" != "200" ]; do
    sleep 1s
done

#
# Wait for the Web Host to come up
#
echo "Waiting for Web Host to become available ..."
while [ "$(curl -k -s -o /dev/null -w ''%{http_code}'' "$WEB_ORIGIN/spa/index.html")" != "200" ]; do
    sleep 1s
done

#
# Wait for the SPA's Javascript bundles to be built
#
echo "Waiting for SPA to become available ..."
SPA_BUNDLE='./spa/dist/app.bundle.js'
while [ ! -f "$SPA_BUNDLE" ]; do
    sleep 1s
done

#
# Run the SPA in the default browser, then sign in with these credentials:
#  guestuser@mycompany.com
#  GuestPassword1
#
if [ "$PLATFORM" == 'MACOS' ]; then
    open "$WEB_ORIGIN/spa"
fi
if [ "$PLATFORM" == 'WINDOWS' ]; then
    start "$WEB_ORIGIN/spa"
fi