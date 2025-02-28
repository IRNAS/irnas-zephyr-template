# Twister

Twister is a script that scans for the set of unit test applications in the git repository and
attempts to execute them. For listed boards, it can build the applications, run them, check if they
every successful and generate a report.

Due to the number of features that it has it can take some time to figure out how to do something
that you want, see `east twister --extra-help` for the supported options.

Also, see [Zephyr's documentation](https://docs.zephyrproject.org/latest/develop/test/twister.html)
for more info.

## Simple example

From the project's root directory run:

```shell
east twister -p native_sim -T tests
```

Twister will detect all projects with `testcase.yaml` in their project root under `tests` directory
and execute them.

To run the same thing on the target you need to provide more info to the Twister:

```shell
east twister -T tests -p nrf52dk_nrf52832 --device-testing --device-serial /dev/ttyACM0
```

Check the output for the results.

## `twister-out` folder

With every invocation of the `east twister` a `twister-out` folder is created. It contains all build
folders of the created projects, as well as the report files.

Keep in mind, if you keep running `east twister` command and not deleting the `twister-out` folder,
then the command will rename it to `twister-out.X` (Where `X` is a unique ascending number, starting
with 1) before running the full build.

## `testcase.yaml` file

`testcase.yaml` file marks that a Twister should pick up the test folder and build it. Its content
defines for which platforms it should be built and tested.

See [Test Cases] section for more info.

[test cases]: https://docs.zephyrproject.org/latest/develop/test/twister.html#test-cases

## Coverage report

Twister supports creating coverage reports from test runs with `gcovr` tool. Adding extra flags to
the command invocation creates an html file (among others) which shows code coverage for each file.

```shell
east twister -T tests -p native_sim --coverage  --coverage-tool gcovr
```

Note that you might need to change `--coverage-basedir` or add new ones for your project.

To open the coverage report in the browser:

```shell
firefox twister-out/coverage/index.html
```

## Make commands

`makefile` in the root of the project contains useful targets for running tests.

To setup host machine for running tests (needed to be run only once):

```shell
make install-dep
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
