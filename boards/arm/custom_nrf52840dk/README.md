# Custom nRF52840 Board

`custom_nrf52840` board is used to demonstrate how to create custom boards. It
is in fact a simplified version of the nRF52840-DK board, so the
`app` can be run on that development kit when using `custom_nrf52840dk`.

Only speciality is that the jlink runner is used by default when using `west
flash`, this is set by `board.cmake` file.
