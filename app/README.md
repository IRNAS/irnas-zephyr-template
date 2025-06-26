# Main application example

This is a simple hello world + blinky example. The purpose is to show how to utilize the build
system to build various application types.

## Building

This app can be build for various boards and build types. The supported board are listed in
[sample.yaml](./sample.yaml) under the `platform_allow` section. The supported build types are
listed in the `tests` section.

Also note that build types with the `FILE_SUFFIX=dev` extra argument will be build without MCUboot,
and the rest with MCUboot. See
[file suffixes](https://docs.zephyrproject.org/latest/develop/application/index.html#file-suffixes)
for more information.

The build command is as follows:

```bash
east build -b <board> . -T <build type>
```

For example:

```bash
# Production build for custom board default revision
east build -b custom_board . -T app.prod

# Development/Debugging build for custom board default revision
east build -b custom_board@1.0.0 . -T app.debug

# RTT build for the DK
east build -b nrf52840dk/nrf52840 . -T app.rtt
```

## Flashing and viewing logs

The flashing command is as follows:

```bash
east flash
```

If the build type is `app.uart`, logs can be viewed using a serial terminal program like `minicom`
or `tio`.

If the build type is `app.rtt`, logs can be viewed using:

```bash
# First terminal
east util connect

# Second terminal
east util rtt
```

## Running on native_sim

The application can also be run on the native simulator. This is useful for testing and debugging.
The LED blinking will not be visible, but the logs can be viewed in the console.

To build and run the application on the native simulator, use the following command:

```bash
# Build the application for native_sim
east build -b native_sim . -T app.native_sim
# Execute the application
east build --domain app -t run
```
