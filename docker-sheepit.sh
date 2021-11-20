#!/bin/bash
echo
echo "*========================*"
echo "* Preparing environment! *"
echo "*========================*"
echo

echo "Checking/Creating folders"
mkdir -p "$CACHE_DIR" "$SHARED_ZIP" .
cd sheepit || exit

echo
echo "*========================*"
echo "*  Initializing Client!  *"
echo "*========================*"
echo

# Download/update client
CLIENT=sheepit.jar
VERSION_REGEX='([0-9]1,)\.([0-9]1,)\.([0-9]1,)'
CLIENT_URL="https://www.sheepit-renderfarm.com/media/applet/client-latest.php"
AVOID_COLLISION=$RANDOM

if [ -f "$CLIENT" ]; then
    VERSION_INSTALLED=$(java -jar $CLIENT --version | grep -Eo "$VERSION_REGEX")
	  VERSION_REMOTE=$(curl --head --silent $CLIENT_URL | grep filename | grep -Eo "$VERSION_REGEX")

    if [ "$VERSION_INSTALLED" = "$VERSION_REMOTE" ]; then
        echo "SheepIt-client is up-to-date."
    else
        echo "Updating SheepIt-client."
        curl $CLIENT_URL > $AVOID_COLLISION
        mv $AVOID_COLLISION $CLIENT
    fi
else
    echo "No SheepIt-client found. Downloading latest."
    curl $CLIENT_URL > $AVOID_COLLISION
    mv $AVOID_COLLISION $CLIENT
fi

# Concatenate run command
COMMAND="java -jar $CLIENT"
if [ "$SHOW_GPU" = "TRUE" ];    then java -jar $CLIENT --show-gpu; exit 0;               fi
if [ "$VERBOSE" = "TRUE" ];     then COMMAND+=" --verbose";                              fi
if [ -n "$CACHE_DIR" ];         then COMMAND+=" -cache-dir $CACHE_DIR";                  fi
if [ -n "$COMPUTE_METHOD" ];    then COMMAND+=" -compute-method $COMPUTE_METHOD";        else echo "Using CPU only."; COMMAND+=" -compute-method CPU --no-gpu"; fi
if [ -n "$CORES" ];             then COMMAND+=" -cores $CORES";                          fi
if [ -n "$EXTRAS" ];            then COMMAND+=" -extras $EXTRAS";                        fi
if [ -n "$GPU" ];               then COMMAND+=" -gpu $GPU";                              fi
if [ -n "$HOSTNAME" ];          then COMMAND+=" -hostname $HOSTNAME";                    else echo "Using hostname: freezingDaniel_$(date +%Y-%m-%d_%H-%M-%S)"; COMMAND+=" -hostname freezingDaniel_$(date +%Y-%m-%d_%H-%M-%S)"; fi
if [ -n "$LOGIN" ];             then COMMAND+=" -login $LOGIN";                          else echo "No login provided!"; exit 1; fi
if [ -n "$MEMORY" ];            then COMMAND+=" -memory $MEMORY";                        fi
if [ -n "$PASSWORD" ];          then COMMAND+=" -password $PASSWORD";                    else echo "No password provided!"; exit 2; fi
if [ -n "$PRIORITY" ];          then COMMAND+=" -priority $PRIORITY";                    fi
if [ -n "$PROXY" ];             then COMMAND+=" -proxy $PROXY";                          fi
if [ -n "$RENDERBUCKET_SIZE" ]; then COMMAND+=" -renderbucket-size $RENDERBUCKET_SIZE";  fi
if [ -n "$RENDERTIME" ];        then COMMAND+=" -rendertime $RENDERTIME";                fi
if [ -n "$REQUEST_TIME" ];      then COMMAND+=" -request-time $REQUEST_TIME";            fi
if [ -n "$SERVER" ];            then COMMAND+=" -server $SERVER";                        fi
if [ -n "$SHARED_ZIP" ];        then COMMAND+=" -shared-zip $SHARED_ZIP";                fi
if [ -n "$SHUTDOWN" ];          then COMMAND+=" -shutdown $SHUTDOWN";                    fi
if [ -n "$SHUTDOWN_MODE" ];     then COMMAND+=" -shutdown-mode $SHUTDOWN_MODE";          fi
if [ -n "$UI" ];                then COMMAND+=" -ui $UI";                                else echo "Using text-ui for logging."; COMMAND+=" -ui text"; fi

# Run Client
echo
echo "*========================*"
echo "*    Starting Client!    *"
echo "*========================*"
echo "Thx for rendering! <3"
echo

#echo "$COMMAND" # uncomment and comment below for debugging
$COMMAND
