# Tests

This document contains relevant instructions on how to use Zephyr's unit testing framework Ztest and
test runner Twister.

As Zephyr already provides great documentation on this [topic], this document will only provide
basic instructions, working examples and tips and tricks.

[topic]: https://docs.zephyrproject.org/latest/develop/test/index.html

## Quick start with the `sample_test` project

`sample_test` project found in `tests` directory provides some examples on how to use Ztest
framework to test a trivial example library with unit tests.

### Running unit tests on host

To build and run it on your development machine:

```shell
cd tests/sample_test
east build -b native_sim -t run
```

<!-- prettier-ignore -->
> [!NOTE]
> If you run into any problems when building or running the above command, try using
> `native_sim/native/64` board instead.

After the build process, you will be greeted with the following output:

```code
*** Booting nRF Connect SDK v2.7.0-5cb85570ca43 ***
*** Using Zephyr OS v3.6.99-100befc70c74 ***
Running TESTSUITE sample_test_suite
===================================================================
START - test_example_1
 PASS - test_example_1 in 0.000 seconds
===================================================================
START - test_example_2
 PASS - test_example_2 in 0.000 seconds
===================================================================
START - test_example_lib
 PASS - test_example_lib in 0.000 seconds
===================================================================
TESTSUITE sample_test_suite succeeded

------ TESTSUITE SUMMARY START ------

SUITE PASS - 100.00% [sample_test_suite]: pass = 3, fail = 0, skip = 0, total = 3 duration = 0.000 seconds
 - PASS - [sample_test_suite.test_example_1] duration = 0.000 seconds
 - PASS - [sample_test_suite.test_example_2] duration = 0.000 seconds
 - PASS - [sample_test_suite.test_example_lib] duration = 0.000 seconds

------ TESTSUITE SUMMARY END ------
```

Alternatively you could also just build it and directly run the executable:

```code
east build -b native_sim
./build/zephyr/zephyr.elf
```

The created `zephyr.elf` file is just a normal Linux executable. To debug it with `gdb` you can run:

```code
gdb build/zephyr/zephyr.elf
```

While debugging you will probably want to enable below two Kconfig symbols in the `prj.conf` for
better debugging experience:

```Kconfig
# Compiler optimizations will be set to -Og independently of other options.
CONFIG_DEBUG_OPTIMIZATIONS=y
# This option enables the addition of various information that can be
# used by debuggers in debugging the system, or enabling additional debugging
# information to be reported at runtime.
CONFIG_DEBUG_INFO=y
```

You can also run the binary with `valgrind` to check for memory leaks:

```shell
sudo apt install valgrind
apt-get install libc6-dbg:i386
valgrind --leak-check=yes ./build/zephyr/zephyr.exe
```

### Running unit tests on the target

To build and run it on the target:

```shell
# build for default DK board
east build -b nrf52840dk/nrf52840
# or build for custom board (mimics nRF52840DK)
east build -b custom_board
# flash the board
east flash
```

To see the serial output:

```shell
minicom -D /dev/ttyACM0
```

Note: The exact path will wary, check for the board with `ls -al /dev/tty*` command.

## Writing unit tests with Ztest

Again, the ultimate source of truth is the [Zephyr's Ztest] documentation. Some basic explanation
follows.

[zephyr's ztest]: https://docs.zephyrproject.org/latest/develop/test/ztest.html

### Structure of unit test

Ztest framework heavily uses macros to keep the boilerplate code down.

Here is a simple unit test that just checks if variable `a` is equal to `0`.

```C
ZTEST(my_test_suite, simple_equality)
{
    int a = 0;
     zassert_equal(0, a, "Not equal, a is %i", a);
}
```

- Each unit test needs to be placed inside the `ZTEST` macro. First argument is `suit_name`, second
  is the `test_name`. `test_name` must start with `test_` prefix so it can be picked up by Twister.
- Multiple tests can use the same `suit_name`, but need to have different `test_name`.
- Various `zassert_*` [assertions] can then be used to check the equality if the condition is true,
  false, etc. The common theme is that they all can take a message with arguments in the end (just
  like `printf`), which is printed if an assert fails.
- A suite of tests can have common setup, teardown, etc. functions to decrease boilerplate code. See
  [Creating a test suite] section for more info.

See
[zephyr/tests/ztest/base](https://github.com/zephyrproject-rtos/zephyr/tree/main/tests/ztest/base)
for some basic use cases of Ztest framework.

[assertions]: https://docs.zephyrproject.org/latest/develop/test/ztest.html#assertions
[creating a test suite]:
  https://docs.zephyrproject.org/latest/develop/test/ztest.html#creating-a-test-suite
