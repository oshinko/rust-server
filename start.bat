@REM Windows で Rust サーバーを起動するスクリプト

@echo off
setlocal

if "%steamcmd%" == "" (
  @REM SteamCMD のパスが設定されていない場合、デフォルト値を設定
  set steamcmd=%userprofile%\steamcmd\steamcmd.exe
)

if "%force_install_dir%" == "" (
  @REM Rust サーバーのインストールパスが設定されていない場合、デフォルト値を設定
  set force_install_dir=%~dp0\data\Windows
)

if "%rcon_password%" == "" (
  @REM Rust RCON のパスワードが設定されていない場合、デフォルト値を設定
  set rcon_password=my_password
)

if "%server_identity%" == "" (
  @REM Rust サーバーの ID が設定されていない場合、デフォルト値を設定
  set server_identity="my-rust-server"
)

if "%server_worldsize%" == "" (
  @REM Rust サーバーのワールドサイズが設定されていない場合、デフォルト値を設定
  set server_worldsize=6000
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
  +force_install_dir %force_install_dir% ^
  +login anonymous ^
  +app_update 258550 validate ^
  +quit

cd %force_install_dir%

@REM Rust サーバーを起動
.\RustDedicated.exe ^
  +rcon.password "%rcon_password%" ^
  +rcon.port 28016 ^
  +rcon.web 1 ^
  +server.identity "%server_identity%" ^
  +server.level "Procedural Map" ^
  +server.maxplayers 10 ^
  +server.port 28015 ^
  +server.saveinterval 10 ^
  +server.seed 1234 ^
  +server.tickrate 10 ^
  +server.worldsize %server_worldsize% ^
  -batchmode ^
  -logfile .\log.txt ^
  -nographics ^
  -silent-crashes

endlocal
pause
