set -e

. /etc/os-release

if [ "$STEAMCMD" = "" ]; then
  STEAMCMD=$HOME/Steam/steamcmd.sh
fi

if [ "$FORCE_INSTALL_DIR" = "" ]; then
  here="$(cd -- "$(dirname "$0")" > /dev/null 2>&1; pwd -P)"
  FORCE_INSTALL_DIR=$here/data/Linux
fi

if [ "$SERVER_IDENTITY" = "" ]; then
  SERVER_IDENTITY=my-rust-server
fi

DISABLE_AUTO_UPDATE=`echo "$DISABLE_AUTO_UPDATE" | tr [A-Z] [a-z]`

if [ "$DISABLE_AUTO_UPDATE" = "" ] || [ "$DISABLE_AUTO_UPDATE" = "0" ] || \
    [ "$DISABLE_AUTO_UPDATE" = "false" ]; then
  enable_auto_update=true
fi

if [ "$enable_auto_update" = "true" ] || \
    ! ls "$FORCE_INSTALL_DIR/RustDedicated" > /dev/null 2>&1; then
  update_or_install=true
fi

if type apt > /dev/null 2>&1; then
  # On Debian, Ubuntu, and other apt based systems
  pm=apt
elif type yum > /dev/null 2>&1; then
  # On Fedora, Red Hat Enterprise Linux and other yum based systems
  pm=yum
else
  echo "Could not find package manager"
  exit 1
fi

# Update package manager
$pm update
$pm install -y curl

if ls $STEAMCMD > /dev/null 2>&1; then
  echo "SteamCMD was found in $STEAMCMD"
else
  echo "SteamCMD was not found in $STEAMCMD"

  if [ "$update_or_install" = "true" ]; then
    echo "Install SteamCMD to $STEAMCMD"
    steamcmd_home=`dirname $STEAMCMD`
    mkdir -p $steamcmd_home
    cd $steamcmd_home
    curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -
  fi
fi

if [ "$update_or_install" = "true" ]; then
  echo "Install or update Rust server"

  # Install dependencies
  if [ "$pm" = "apt" ]; then
    deps="lib32gcc-s1"
  elif [ "$pm" = "yum" ]; then
    deps="glibc.i686 libstdc++.i686"
  fi

  $pm install -y $deps

  # Install or update Rust server
  $STEAMCMD \
    +force_install_dir $FORCE_INSTALL_DIR \
    +login anonymous \
    +app_update 258550 validate \
    +quit
else
  echo "Rust seems to be installed, skipping automatic update"
fi

if [ "$ID" != "amzn" ]; then
  # Rust includes *.so we need to tell the OS where it exists
  LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$FORCE_INSTALL_DIR/RustDedicated_Data/Plugins/x86_64
  LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$FORCE_INSTALL_DIR/RustDedicated_Data/Plugins
  LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$FORCE_INSTALL_DIR
  export LD_LIBRARY_PATH
fi

# Apply patch for SqliteException
# ref: https://umod.org/index.php/community/rust/43361-sqliteexception-server-not-starting?page=4#post-49
curl -L https://www.dropbox.com/s/3mraw9li6oypw90/Facepunch.Sqlite.dll?dl=1 \
     -o $FORCE_INSTALL_DIR/RustDedicated_Data/Managed/Facepunch.Sqlite.dll

# Initial resources and start server
STARTUP_ARGS="-batchmode -nographics -silent-crashes +server.identity $SERVER_IDENTITY"

if [ "$RCON_IP" != "" ]; then
  STARTUP_ARGS="$STARTUP_ARGS +rcon.ip $RCON_IP"
fi

if [ "$RCON_PASSWORD" != "" ]; then
  STARTUP_ARGS="$STARTUP_ARGS +rcon.password \"$RCON_PASSWORD\""
fi

if [ "$RCON_PORT" != "" ]; then
  STARTUP_ARGS="$STARTUP_ARGS +rcon.port $RCON_PORT"
fi

if [ "$RCON_WEB" != "" ]; then
  STARTUP_ARGS="$STARTUP_ARGS +rcon.web $RCON_WEB"
fi

if [ "$SERVER_HOSTNAME" != "" ]; then
  STARTUP_ARGS="$STARTUP_ARGS +server.hostname \"$SERVER_HOSTNAME\""
fi

if [ "$SERVER_IP" != "" ]; then
  STARTUP_ARGS="$STARTUP_ARGS +server.ip $SERVER_IP"
fi

if [ "$SERVER_LEVEL" != "" ]; then
  STARTUP_ARGS="$STARTUP_ARGS +server.level \"$SERVER_LEVEL\""
fi

if [ "$SERVER_MAXPLAYERS" != "" ]; then
  STARTUP_ARGS="$STARTUP_ARGS +server.maxplayers $SERVER_MAXPLAYERS"
fi

if [ "$SERVER_PORT" != "" ]; then
  STARTUP_ARGS="$STARTUP_ARGS +server.port $SERVER_PORT"
fi

if [ "$SERVER_SAVEINTERVAL" != "" ]; then
  STARTUP_ARGS="$STARTUP_ARGS +server.saveinterval $SERVER_SAVEINTERVAL"
fi

if [ "$SERVER_SEED" != "" ]; then
  STARTUP_ARGS="$STARTUP_ARGS +server.seed $SERVER_SEED"
fi

if [ "$SERVER_TICKRATE" != "" ]; then
  STARTUP_ARGS="$STARTUP_ARGS +server.tickrate $SERVER_TICKRATE"
fi

if [ "$SERVER_WORLDSIZE" != "" ]; then
  STARTUP_ARGS="$STARTUP_ARGS +server.worldsize $SERVER_WORLDSIZE"
fi

cd $FORCE_INSTALL_DIR
eval ./RustDedicated $STARTUP_ARGS
