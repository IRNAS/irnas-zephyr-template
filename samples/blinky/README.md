# Blinky

This is a copy of Zephyr's blinky example. It is provided here to showcase how a sample can be
provided as part of a firmware repository, how it is built and released.

## Building

```bash
# For the DK
east build -b nrf52840dk/nrf52840 . -T sample.blinky


# For the custom board
east build -b custom_board . -T sample.blinky
```

## Flashing

```bash
east flash
```
