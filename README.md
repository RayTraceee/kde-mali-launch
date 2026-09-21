# kde-mali-launch

# KDE Plasma on Mali Devices

A launch script for running KDE Plasma through Termux:X11 on Android devices with Mali graphics.

This project started because I wanted to run KDE Plasma on a Mali based device without accepting that Snapdragon hardware was required for a usable KDE desktop.

The script sets up the required session environment, starts the required services, forces a Mesa software rendering path, applies KWin and Qt workarounds, and launches KDE Plasma through Termux:X11.

## What the script does

The script handles the setup automatically:

* Cleans up old Termux:X11, Plasma, KWin, and D-Bus sessions
* Restarts PulseAudio and configures its local protocol
* Creates and exports the required `XDG_RUNTIME_DIR`
* Starts a D-Bus session bus
* Configures KWin and Qt to use EGL through XCB
* Forces Mesa's `llvmpipe` software renderer
* Disables Zink descriptors
* Starts Termux:X11
* Restarts Plasma Shell after startup
* Launches KDE Plasma through `startplasma-x11`

The main Mali workaround is the combination of the Mesa renderer configuration and the KWin and Qt environment variables.

## Requirements

This script is intended for Android Linux environments using Termux and Termux:X11.

You will need:

* Termux
* Termux:X11
* KDE Plasma
* Mesa
* A Mali based Android device
* A working Linux userspace inside Termux

The script also attempts to source `~/.config/linux-gpu.sh` if it exists. This allows additional GPU related environment configuration to be loaded before KDE starts.

## KDE Plasma installation

For a KDE Plasma installation guide, refer to [this tutorial](https://www.youtube.com/watch?v=PyDQmfeRXQc&t=394s). 

## Termux:API

For battery status and brightness controls, install and configure [Termux:API](https://github.com/termux/termux-api) and make sure the Termux:API app is installed alongside Termux.

This allows the desktop environment to access Android features such as battery information and screen brightness control.

## Usage

Make the script executable:

```bash
chmod +x launch-kde.sh
```

Then run it:

```bash
./launch-kde.sh
```

Once the X11 server starts, open the Termux:X11 application to view the KDE Plasma desktop.

## Important advisory

### Mali devices

This script is primarily intended as a workaround for Mali based devices where the normal graphics path causes KDE Plasma or KWin to fail during startup or behave incorrectly.

It forces Mesa to use `llvmpipe` software rendering. This is intentional and is used for compatibility and stability on the target setup.

Because `llvmpipe` is software rendering, performance can be significantly lower than proper hardware accelerated rendering.

### Snapdragon and Adreno devices

If you are using a Snapdragon device with working native hardware acceleration for KDE, you should not need this workaround.

Snapdragon devices with a properly supported Adreno graphics stack can use hardware acceleration directly, so forcing `llvmpipe` would generally be unnecessary and could reduce performance.

This project is primarily aimed at Mali based setups where the normal accelerated path is problematic.

### Android background process management

Android can aggressively terminate applications and child processes when their parent application is placed in the background.

This can cause KDE Plasma or parts of the desktop session to suddenly terminate when the application hosting the Linux environment is no longer in the foreground.

If KDE starts correctly but dies when you switch applications, check your device's battery optimization, background process, and child process management settings.

Make sure the relevant Termux and Termux:X11 processes are allowed to continue running in the background.

The exact setting depends on your Android version and device manufacturer.

## Mesa software rendering

The script explicitly sets:

```bash
export GALLIUM_DRIVER=llvmpipe
```

This forces Mesa to use LLVMpipe for software rendering.

The reason for doing this is that the target Mali setup experienced instability with the normal graphics path when running KDE Plasma.

This is a compatibility workaround rather than a performance optimization.

## KWin and Qt configuration

The script sets the following environment variables:

```bash
export KWIN_COMPOSE=N
export KWIN_OPENGL_INTERFACE=egl
export QT_XCB_GL_INTEGRATION=xcb_egl
```

These settings are part of the workaround for the rendering and window management problems encountered on the target setup.

## Zink descriptors

The script also sets:

```bash
export ZINK_DESCRIPTORS=none
```

This is included as part of the Mesa and Zink workaround used by the script.

## D-Bus

KDE requires a working session D-Bus environment.

The script creates a runtime directory and starts a session bus before launching Plasma:

```bash
mkdir -p $TMPDIR/runtime-dir
export XDG_RUNTIME_DIR=$TMPDIR/runtime-dir

dbus-daemon --session --fork --address=unix:path=$XDG_RUNTIME_DIR/bus
export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
```

This is handled automatically when the script runs.

## Plasma Shell workaround

The script restarts `plasmashell` a few seconds after KDE starts:

```bash
(sleep 5 && pkill -9 plasmashell && plasmashell)
```

This is included because of the Plasma window management behavior encountered on the target setup.

## Tested hardware

The original development and testing environment was:

* Device: Samsung Galaxy Tab S9 FE+
* GPU: Mali-G68
* Environment: Termux + Termux:X11
* Desktop: KDE Plasma
* Display server: X11

Other Mali devices may behave differently.

## Limitations

This is a workaround, not a universal Mali graphics solution.

Different Mali GPUs, Mesa versions, Android versions, Termux environments, and KDE Plasma versions may require different configurations.

Software rendering also means that graphical performance will depend heavily on the CPU and the workload.

If this works on your device, great. If it does not, please include the following when reporting an issue:

* Device
* GPU
* Android version
* Mesa version
* KDE Plasma version
* Termux version
* Termux:X11 version
* Relevant terminal output

## Why I made this

The original goal was pretty simple.

I wanted KDE Plasma on my Mali device, and I did not want the answer to be "buy a Snapdragon device."

So instead of giving up, I started experimenting with the graphics stack until I found a configuration that worked well enough to turn the device into a usable KDE desktop.

This repository is the result of that experimentation.

## Contributing

If you find a better workaround, a cleaner configuration, or a fix for a specific Mali device, feel free to open an issue or submit a pull request.

If you get this working on another Mali device, sharing the hardware and software configuration would also be useful for figuring out how portable the workaround actually is.

## License

This project is provided as-is.


