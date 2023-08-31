# Renode Example

[Renode](https://renode.io/) is an open-source software development framework
with commercial support from Antmicro that lets you develop, debug and test
multi-node device systems reliably, scalably and effectively.

The goal of this sample is to review the Renode platform and how to use it with
the nrf52840dk board.

This sample contains a simple firmware for the nrf52840dk board, which does the
following:

- On the press of Button 1 (on the nrf52840DK) it prints `GPIO Interrupt fired`.
- It has enabled GPIO and Sensor shells.
- It specifies in its device tree LIS2DW12 accelerometer and STTS751 temperature
  sensors.

## Pre-Requisites

### Install Renode and Robot Framework

To install Renode and all its required dependencies use the below installation
script:

```shell
cd <project root dir>
./scripts/renode/install.sh
```

### Build the firmware

Run below command:

```shell
east build -b nrf52840dk_nrf52840
```

## Running Renode

To run the built firmware in the Renode simulator just run:

```shell
renode renode/nrf52840dk_example.resc
```

The above command will open Renode GUI and load the provided script into it. At
the same time it will open another terminal window with uart communication.

Renode scripts [.resc] enable you to encapsulate repeatable elements of your
project (like creating a machine and loading a binary) to conveniently execute
them multiple times.

[.resc]:
  https://renode.readthedocs.io/en/latest/introduction/using.html#resc-scripts

## Robot Framework

Renode greatly
[integrates](https://renode.readthedocs.io/en/latest/introduction/testing.html)
with the `Robot Framework` test automation framework. For this sample, we have
created the `test-nrf52840dk.robot` file which will load the
`nrf52840dk_nrf52840.repl` file, load the created sample `zephyr.elf` firmware
file, start the machine and execute tests. The tests are defined in the
`test-nrf52840dk.robot` file.

To run the tests:

```
renode-test test-nrf52840dk.robot
```

## Caveats

We have implemented a simulated temperature driver in
`renode/STTS751/STTS751.cs`. During development, we discovered that the same
driver in the Zephyr kernel has a bug in the temperature conversion procedure
(see `stts751_temp_convert` function in `drivers/sensor/stts751/stts751.c`).

This means that if we input the simulated temperature value with:

```
sysbus.twi0.stts Temperature -5.5
```

will not get the expected response if we send the below shell command to the
firmware:

```
uart:~$ sensors get stts751@4a ambient_temp

# Returned response
channel idx=13 ambient_temp =   -6.280000
```

## Useful links and resources

- [Documentation](https://renode.readthedocs.io/en/latest/index.html)
- [Robot Framework User Guide](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#toc-entry-1)
- [List of Robot Framework keywords](https://github.com/renode/renode/tree/master/src/Renode/RobotFrameworkEngine)
- [List of supported Renode peripherals](https://github.com/renode/renode-infrastructure/tree/04392478931d2540623450598776cc41ff232aad/src/Emulator/Peripherals/Peripherals)
- [Example .robot file](https://github.com/renode/renode/blob/master/tests/platforms/NRF52840.robot)
