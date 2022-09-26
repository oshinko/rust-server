@REM Windows で Rust サーバーを起動するスクリプト

@echo off
setlocal

if "%steamcmd%" == "" (
  @REM SteamCMD のパスが設定されていない場合、デフォルト値を設定
  set steamcmd=%userprofile%\steamcmd\steamcmd.exe
)

if "%rust_home%" == "" (
  @REM Rust サーバーのインストールパスが設定されていない場合、デフォルト値を設定
  set rust_home=%~dp0\data
)

if "%rust_server_identity%" == "" (
  @REM Rust サーバーの ID が設定されていない場合、デフォルト値を設定
  set rust_server_identity="my-rust-server"
)

if "%rust_server_worldsize%" == "" (
  @REM Rust サーバーのワールドサイズが設定されていない場合、デフォルト値を設定
  set rust_server_worldsize=6000
)

if exist "%steamcmd%" (
  echo SteamCMD was found in %steamcmd%
) else (
  echo SteamCMD was not found in %steamcmd%
  mkdir .\tmp > NUL 2>&1
  @REM ref: https://developer.valvesoftware.com/wiki/SteamCMD#Windows
  curl ^
    -sSL https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip ^
    -o .\tmp\steamcmd.zip
  powershell Expand-Archive -Path .\tmp\steamcmd.zip -DestinationPath %steamcmd%\..
)

@REM Rust サーバーファイルを更新
%steamcmd% ^
  +force_install_dir %rust_home% ^
  +login anonymous ^
  +app_update 258550 validate ^
  +quit

cd %rust_home%

@REM Rust サーバーを起動
.\RustDedicated.exe ^
  +rcon.password my_password ^
  +rcon.port 28016 ^
  +rcon.web 1 ^
  +server.identity "%rust_server_identity%" ^
  +server.level "Procedural Map" ^
  +server.maxplayers 10 ^
  +server.port 28015 ^
  +server.saveinterval 10 ^
  +server.seed 1234 ^
  +server.tickrate 10 ^
  +server.worldsize %rust_server_worldsize% ^
  -batchmode ^
  -logfile .\log.txt ^
  -nographics ^
  -silent-crashes

endlocal
pause
