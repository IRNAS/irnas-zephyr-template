*** Comments ***
# Filename: test-button.robot

*** Keywords ***
Start Test
    Set Suite Variable      ${Accelerometer}    sysbus.twi0.acc
    # We can also import .resc files instead of creating a machine from scratch in the .robot file
    Execute Command     path add @${CURDIR}
    Execute Command     include @renode/nrf52840dk_example.resc
    Create Terminal Tester    sysbus.uart0
    Start Emulation


*** Settings ***
Resource            ${RENODEKEYWORDS}

Suite Setup         Setup
Suite Teardown      Teardown
Test Setup          Reset Emulation


*** Variables ***


*** Test Cases ***
Help
    [Documentation]    Prints help menu of the command prompt

    Start Test

    Write Line To Uart    help
    Wait For Line On Uart    help    timeout=1

Get Button Pressed
    [Documentation]    Simulates button press and checks if the button was pressed

    Start Test

    Execute Command     sysbus.gpio0.userButton Press
    Execute Command     sysbus.gpio0.userButton Release
    Execute Command     sysbus.gpio0.userButton Press
    Execute Command     sysbus.gpio0.userButton Release
    Wait For Line On Uart    GPIO Interrupt fired    timeout=2


Set Acc X
    [Documentation]     Set acceleration on X axis and read it back

    Start Test

    Execute Command     ${Accelerometer} AccelerationX 0.1
    Write Line To Uart  sensor get lis2dw12@19 accel_x
    Wait For Line On Uart    0.976271    timeout=2

Set Acc Y
    [Documentation]     Set acceleration on Y axis and read it back

    Start Test

    Execute Command     ${Accelerometer} AccelerationY -0.1
    Write Line To Uart  sensor get lis2dw12@19 accel_y
    Wait For Line On Uart    -0.976271    timeout=2

Set Acc Z
    [Documentation]     Set acceleration on Z axis and read it back

    Start Test

    Execute Command     ${Accelerometer} AccelerationZ 0.1
    Write Line To Uart  sensor get lis2dw12@19 accel_z
    Wait For Line On Uart    0.976271    timeout=2

#Set STTS751 Temperature
#    [Documentation]     Set temperature and read it back
#
#    Start Test
#
#    Execute Command     sysbus.twi0.stts Temperature 25.5
#    Write Line To Uart  sensor get stts751@4a ambient_temp
#    Write Line To Uart  sensor get stts751@4a ambient_temp
#    Wait For Line On Uart    25.5    timeout=2
