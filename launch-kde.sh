#!/data/data/com.termux/files/usr/bin/bash
echo ""
echo "[*] Starting KDE Plasma..."
echo ""
source ~/.config/linux-gpu.sh 2>/dev/null

echo "[*] Cleaning up old sessions..."
pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 startplasma-x11; pkill -9 kwin_x11 2>/dev/null
pkill -9 -f "dbus" 2>/dev/null

unset PULSE_SERVER
pulseaudio --kill 2>/dev/null
sleep 0.5
echo "[*] Starting audio server..."
pulseaudio --start --exit-idle-time=-1
sleep 1
pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1 2>/dev/null
export PULSE_SERVER=127.0.0.1

# ==================== ADDED FIXES FOR WINDOW DRAGGING ====================
echo "[*] Initializing D-Bus and KWin Parameters..."
mkdir -p $TMPDIR/runtime-dir
export XDG_RUNTIME_DIR=$TMPDIR/runtime-dir

# Start the required background bus cleanly
dbus-daemon --session --fork --address=unix:path=$XDG_RUNTIME_DIR/bus
export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"

# Force stable rendering parameters to bypass the Mali/Mesa context crash
export KWIN_COMPOSE=N
export KWIN_OPENGL_INTERFACE=egl
export QT_XCB_GL_INTEGRATION=xcb_egl
# =========================================================================

echo "[*] Starting X11 server..."
termux-x11 :1 -ac &
sleep 3
export DISPLAY=:1
export GALLIUM_DRIVER=llvmpipe
export ZINK_DESCRIPTORS=none

echo "-----------------------------------------------"
echo "  [*] Open Termux-X11 app to view desktop!"
echo "-----------------------------------------------"
echo ""
(sleep 5 && pkill -9 plasmashell && plasmashell) > /dev/null 2>&1 &\
exec startplasma-x11

# 1. Force the missing directories and system variables
mkdir -p $TMPDIR/runtime-dir
export XDG_RUNTIME_DIR=$TMPDIR/runtime-dir

# 2. Fire up the communication engine quietly
dbus-daemon --session --fork --address=unix:path=$XDG_RUNTIME_DIR/bus
export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"

# 3. Force KWin to use stable parameters for your Mali GPU
export KWIN_COMPOSE=N
export KWIN_OPENGL_INTERFACE=egl
export QT_XCB_GL_INTEGRATION=xcb_egl

# --- YOUR EXISTING STARTUP COMMANDS HERE ---
# (e.g., termux-x11 :1 or startplasma-x11)
startplasma-x11
