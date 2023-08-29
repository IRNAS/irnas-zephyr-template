# Tests

This document contains relevant instructions on how to use Zephyr's unit testing
framework Ztest and test runner Twister.

As Zephyr already provides great documentation on this [topic], this document
will only provide basic instructions, working examples and tips and tricks.

### Test and coverage reports

`makefile` in the root of the project directory has several useful commands

[topic]: https://docs.zephyrproject.org/latest/develop/test/index.html

## Quick start with the `sample_test` project

`sample_test` project found in `tests` directory provides some examples on how
to use Ztest framework to test a trivial example library with unit tests.

### Running unit tests on host

To build and run it on your development machine:

```shell
cd tests/sample_test
east build -b native_posix -t run
```

After the build process, you will be greeted with the following output:

```
*** Booting Zephyr OS build v3.3.99-ncs1 ***
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

```
east build -b native_posix
./build/zephyr/zephyr.elf
```

The created `zephyr.elf` file is just a normal Linux executable. To debug it
with `gdb` you can run:

```
gdb build/zephyr/zephyr.elf
```

While debugging you will probably want to enable below two Kconfig symbols in
the `prj.conf` for better debugging experience:

```Kconfig
# Compiler optimizations will be set to -Og independently of other options.
CONFIG_DEBUG_OPTIMIZATIONS=y
# This option enables the addition of various information that can be
# used by debuggers in debugging the system, or enabling additional debugging
# information to be reported at runtime.
CONFIG_DEBUG_INFO=y
```

### Running unit tests on the target

To build and run it on your target, for example nRF52DK board:

```shell
east build -b nrf52dk_nrf52832
east flash
```

To see the serial output:

```shell
minicom -D /dev/ttyACM0
```

Note: The exact path will wary, check for the board with `ls -al /dev/tty*`
command.

## Writing unit tests with Ztest

Again, the ultimate source of truth is the [Zephyr's Ztest] documentation. Some
basic explanation follows.

[zephyr's ztest]: https://docs.zephyrproject.org/latest/develop/test/ztest.html

### Structure of unit test

Ztest framework heavily uses macros to keep the boilerplate code down.

Here is a simple unit test that just checks if variable `a` is equal to `0`.

```
ZTEST(my_test_suite, simple_equality)
{
    int a = 0;
     zassert_equal(0, a, "Not equal, a is %i", a);
}
```

- Each unit test needs to be placed inside the `ZTEST` macro. First argument is
  `suit_name`, second is the `test_name`. `test_name` must start with `test_`
  prefix so it can be picked up by Twister.
- Multiple tests can use the same `suit_name`, but need to have different
  `test_name`.
- Various `zassert_*` [assertions] can then be used to check the equality if the
  condition is true, false, etc. The common theme is that they all can take a
  message with arguments in the end (just like `printf`), which is printed if an
  assert fails.
- A suite of tests can have common setup, teardown, etc. functions to decrease
  boilerplate code. See [Creating a test suite] section for more info.

See
[zephyr/tests/ztest/base](https://github.com/zephyrproject-rtos/zephyr/tree/main/tests/ztest/base)
for some basic usecases of Ztest framework.

[assertions]:
  https://docs.zephyrproject.org/latest/develop/test/ztest.html#assertions
[creating a test suite]:
  https://docs.zephyrproject.org/latest/develop/test/ztest.html#creating-a-test-suite

## Twister

Twister is a script that scans for the set of unit test applications in the git
repository and attempts to execute them. For listed boards, it can build the
applications, run them, check if they every successful and generate a report.

Due to the number of features that it has it can take some time to figure out
how to do something that you want, see east twister `--extra-help` for the
supported options.

Also, see
[Zephyr's documentation](https://docs.zephyrproject.org/latest/develop/test/twister.html)
for more info.

### Simple example

From the project's root directory run:

```shell
east twister -b native_posix -T tests
```

Twister will detect all projects with `testcase.yaml` in their project root
under `tests` directory and execute them.

To run the same thing on the target you need to provide more info to the
Twister:

```shell
east twister -T tests -p nrf52dk_nrf52832 --device-testing --device-serial /dev/ttyACM0
```

Check the output for the results.

### `twister-out` folder

With every invocation of the `east twister` a `twister-out` folder is created.
It contains all build folders of the created projects, as well as the report
files.

Keep in mind, if you keep running `east twister` command and not deleting the
`twister-out` folder, then the command will rename it to `twister-out.X` (Where
`X` is a unique ascending number, starting with 1) before running the full
build.

### `testcase.yaml` file

`testcase.yaml` file marks that a Twister should pick up the test folder and
build it. Its content defines for which platforms it should be built and tested.

See [Test Cases] section for more info.

[test cases]:
  https://docs.zephyrproject.org/latest/develop/test/twister.html#test-cases

### Coverage report

Twister supports creating coverage reports from test runs with `gcovr` tool.
Adding extra flags to the command invocation creates a html file (among others)
which shows code coverage for each file.

```shell
east twister -T tests -p native_posix --coverage  --coverage-tool gcovr
```

Note that you might need to change `--coverage-basedir` or add new ones for your
project.

To open the coverage report in the browser:

```shell
firefox twister-out/coverage/index.html
```

## Make commands

`makefile` in the root of the project contains useful targets for running tests.

To setup host machine for running tests (needed to be run only once):

```shell
make install-dep
make install-test-dep
```

To run all tests with Twister:

```shell
make test
```

To see unit test results:

```shell
make test-report
```

To see code coverage report:

```shell
make coverage-report
```
