# STTS751

This document outlines the steps required to implement a custom peripheral for
Phenode. This chip is supported by Zephyr, but is not implemented in Renode.

Useful inks:

- Renode Writing a new peripheral:
  https://renode.readthedocs.io/en/latest/advanced/writing-peripherals.html#
- LIS2DW12 -
  https://github.com/renode/renode-infrastructure/blob/master/src/Emulator/Peripherals/Peripherals/Sensors/LIS2DW12.cs

Observations during the implementation process:

1. Add I2C device to .overlay file - driver must be supported in Zephyr
2. Add sensor to `.repl` file, using the same address as in `.overlay` file
3. Add Sensor implementation to `STTS751.cs` (this file). There are several ways
   to implement the sensor. We have followed the example of `LIS2DW12.cs`.
   Several methods must be implemented, this depends on the class the sensor
   inherits from.
4. Include the `STTS751.cs` sensor in the `.resc` file using the `include`
   syntax
5. Add a simple test to the `.robot` file
