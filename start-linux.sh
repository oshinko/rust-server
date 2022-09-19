RUST_HOME=$HOME/rust

# Install SteamCMD
sudo yum install glibc.i686 libstdc++.i686 -y
mkdir ~/Steam && cd ~/Steam
curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

# Install Rust
./steamcmd.sh \
  +force_install_dir $RUST_HOME \
  +login anonymous \
  +app_update 258550 validate \
  +quit

# Apply patch for SqliteException
# ref: https://umod.org/index.php/community/rust/43361-sqliteexception-server-not-starting?page=4#post-49
curl -L https://www.dropbox.com/s/3mraw9li6oypw90/Facepunch.Sqlite.dll?dl=1 \
     -o $RUST_HOME/RustDedicated_Data/Managed/Facepunch.Sqlite.dll

# Initial resources and start server
cd $RUST_HOME
./RustDedicated \
  +rcon.ip 0.0.0.0 \
  +rcon.password my_password \
  +rcon.port 28016 \
  +rcon.web 1 \
  +server.hostname "My Rust Server" \
  +server.identity my-rust-server \
  +server.ip 0.0.0.0 \
  +server.level "Procedural Map" \
  +server.maxplayers 10 \
  +server.port 28015 \
  +server.saveinterval 10 \
  +server.seed 1234 \
  +server.tickrate 10 \
  +server.worldsize 3000 \
  -batchmode \
  -nographics \
  -silent-crashes
