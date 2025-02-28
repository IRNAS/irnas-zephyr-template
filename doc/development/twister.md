# Twister

Twister is a script that searches for a set of applications (based on command line arguments),
attempts to build them, and possibly executes them. If the applications are tests, a test report is
generated.

In this project, Twister is used for three distinct purposes:

- Build and run the unit tests on the Host PC (`native_sim`).
- Build and run the integration tests on the target.
- Build all release artifacts and get them ready for release.

The unit and integration tests are located in the `tests/` directory. Targets that can be built as
apart of a release can be located anywhere in the repository, however, they require a specific
setup. For more information refer to the
[Configuration and Release Artifacts](./configuration_and_release_artifacts.md) document.

## Twister basics

The behavior of Twister is controlled by:

- `<board_name>.yaml` file - Each board needs to have one so that Twister is even aware of it.
- `testcase.yaml` and `sample.yaml` files - This file is used to mark the project for Twister to
  pick up, build and possibly run.
- Command line options passed to the `east twister`.

Once Twister is invoked, it will scan the repository for the `testcase.yaml` and `sample.yaml` files
and build the projects as dictated by the content of these files. The results are then stored in the
`twister-out` directory.

The below sections provide some basic info on the above items, but for more detailed info see the
[Twister's documentation](https://docs.zephyrproject.org/latest/develop/test/twister.html).

### `<board_name>.yaml` file

This file contains the board's metadata, which Zephyr picks up and uses for test purposes. It is
located in the board directory. See the [Board Configuration] section in Twister documentation for
more info.

Example for `nrf52840dk/nrf52840`:

```yaml
identifier: nrf52840dk/nrf52840
name: nRF52840-DK-NRF52840
type: mcu
arch: arm
ram: 256
flash: 1024
toolchain:
  - zephyr
  - gnuarmemb
  - xtools
supported:
  - adc
  - arduino_gpio
  - arduino_i2c
  - arduino_serial
  - arduino_spi
  - ble
  - counter
  - gpio
  - i2c
  - i2s
  - pwm
  - spi
  - usb_device
  - usbd
  - watchdog
  - netif:openthread
vendor: nordic
```

<!-- prettier-ignore -->
> [!IMPORTANT]
> The `identifier` field should be exactly the same as the board name that is usually
> passed to the `east build -b <board_name>` command. If this is not the case, Twister will not
> be able to find the board metadata and thus won't build or run tests for it. This is
> a mistake that often happens with the custom boards.

[Board Configuration]:
  https://docs.zephyrproject.org/latest/develop/test/twister.html#board-configuration

### `testcase.yaml` and `sample.yaml` files

`testcase.yaml` or `sample.yaml` file marks that a project should be picked up by Twister, built and
possibly run. Its content defines for which platforms it should be built and tested. There is no
functional difference between the two files, although `testcase.yaml` is conventionally used only
for the projects under `tests/` directory and `sample.yaml` for everything else.

Below is an example of the `sample.yaml` file:

```yaml
sample:
  name: Main app
  description: Main application of the IRNAS Zephyr template
common:
  sysbuild: true
  tags:
    - release
    - quick-build
  platform_allow:
    - nrf52840dk/nrf52840
    - nrf9160dk/nrf9160
tests:
  app.prod: {}
  app.rtt:
    extra_overlay_confs:
      - rtt.conf
  app.debug:
    platform_allow:
      - native_sim
    extra_args:
      - CONFIG_DEBUG_OPTIMIZATIONS=y
      - CONFIG_DEBUG_THREAD_INFO=y
      - CONFIG_DEBUG_INFO=y
```

Some comments:

- The `description` and `name` fields are mandatory but they don't really control anything.
- The `tests` section is where the actual Test Scenarios are defined. In the above example there are
  3: `app.prod`, `app.rtt` and `app.debug`. Test Scenario names must be strings, without space or
  special characters and they **must** have at least one dot. The convention is to use the dot to
  separate the Test Scenarios as per the folder structure and conditions that they are testing.
  **Test Scenarios must be unique across the whole repository**.
- Each Test Scenario can have several fields that apply only to it.
- `platform_allow` field lists a set of platforms that this Test Scenario should only be run for.
  This field in most of cases acts as a filter, however, this depends on how Twister is invoked. See
  [Selecting platform scope] for more info.
- Fields under the `common` section are applied to all Test Scenarios. They are extended by the Test
  Scenario specific fields. For example `app.rtt` Test Scenario will be built only for the
  `nrf52840dk/nrf52840`, `nrf9160dk/nrf9160` platforms, while `app.debug` will be built for the
  `native_sim` platform as well.
- `tags` field can be used to limit the scope of the Test Scenarios that are run. For example, if
  you want to run only the Test Scenarios that have the `release` tag, you can pass the
  `--tag release` option to the `east twister`.

Many more fields are described in the [Tests] documentation.

[Tests]: https://docs.zephyrproject.org/latest/develop/test/twister.html#tests
[Selecting platform scope]:
  https://docs.zephyrproject.org/latest/develop/test/twister.html#selecting-platform-scope

## Twister's command line options

Twister has a lot of command line options that can be used to control its behavior. Run
`east twister --extra-help` to see them.

Some more important options are:

- `-T TESTSUITE_ROOT, --testsuite-root TESTSUITE_ROOT` - Base directory to recursively search for
  test cases. All `testcase.yaml` and `sample.yaml` files under here will be processed. May be
  called multiple times. Defaults to the `samples/` and `tests/` directories at the base of the
  Zephyr tree, so make sure that you always specify it.
- `-p PLATFORM, --platform PLATFORM` - Platform filter for testing. This option may be used multiple
  times. Test suites will only be built/run on the platforms specified. If this option is not used,
  then platforms marked as default in the platform metadata file will be chosen to build and test.
- `-t TAG, --tag TAG` - Specify tags to restrict which tests to run by tag value. The default is to
  not do any tag filtering. Multiple invocations are treated as a logical 'or' relationship.
- `-b, --build-only` - Only build the code, do not attempt to run the code on targets.
- `-f, --only-failed` - Run only those tests that failed the previous twister run invocation.
- `-y, --dry-run` - Create the filtered list of test cases, but don't actually run them. Useful if
  you're just interested in the test plan generated for every run and saved in the specified output
  directory (`testplan.json`).
- `--overflow-as-errors` - Treat FLASH/RAM/SRAM overflows as errors. **This one is important. If not
  used the test that overflows is considered to be skipped and not that it has failed.**
- `-v, --verbose` - Emit build logs, call multiple times to increase verbosity.

## `twister-out` directory

With every invocation of the `east twister` a `twister-out` folder is created. It contains all the
build folders of the created projects, as well as the report files.

Keep in mind, if you keep running the `east twister` command and not deleting the `twister-out`
folder, then the command will rename it to `twister-out.X` (Where `X` is a unique ascending number,
starting with 1) before running the full build. Thus, `twister-out` is always the result of the
latest twister invocation.

## Cookbook style examples

### Running tests on the Host PC

You want to build and run all tests under the `tests/` directory meant for testing on the Host PC.

`testcase.yaml` file in all the applicable projects under the `tests/` directory should contain
this:

```yaml
tests:
  tests.test_name.native:
    platform_allow: native_sim
    harness: ztest
```

**Remember**: Test Scenarios must be unique across the whole repository.

From the project's root directory run:

```shell
east twister -p native_sim -T tests
```

### Running tests on the target

You want to build and run all tests under `tests/` directory on the target.

`testcase.yaml` file in all the applicable projects under the `tests/` directory should contain some
Test case that is meant to be run on the target:

```yaml
tests:
  tests.test_name.target:
    platform_allow: nrf52dk/nrf52832
    harness: ztest
```

From the project's root directory run:

```shell
east twister -T tests -p nrf52dk/nrf52832 --device-testing --device-serial /dev/ttyACM0
```

### Filtering by tags

You want to build (and not run) all projects in the repository that have a tag `some_tag` on
`nrf52dk/nrf52832` target.

The `testcase.yaml` file should then look like this:

```yaml
tests:
  samples.bitshifter.with_tag:
    platform_allow: nrf52dk/nrf52832
    tag: some_tag
  samples.bitshifter.without_tag:
    platform_allow: nrf52dk/nrf52832
```

From the project's root directory run:

```shell
east twister -T . -t some_tag -p nrf52dk/nrf52832 --build-only
```

In above example, only the `samples.bitshifter.with_tag` project will be built.

### platform_allow acts as a list and not as a filter

You want `platform_allow` to act as a list of platforms that Twister should consider and not as a
filter, as you want to avoid the [scope presumption] behavior. You don't want to specify the
`--platform` option as this can be hard to maintain.

[scope presumption]:
  https://docs.zephyrproject.org/latest/develop/test/twister.html#selecting-platform-scope

`testcase.yaml` file should then look like this:

```yaml
tests:
  app.rtt:
    platform_allow: nrf52dk/nrf52832 nrf52840dk/nrf52840
  app.debug:
    platform_allow: nrf52dk/nrf52832 nrf52840dk/nrf52840 native_sim
```

Extra `twister_config.yaml` file is needed:

```yaml
platforms:
  override_default_platforms: true
```

From the project's root directory run:

```shell
east twister -T . --test-config twister_config.yaml
```

## Coverage report

Twister supports creating coverage reports from test runs with `gcovr` tool. Adding extra flags to
the command invocation creates an html file (among others) which shows code coverage for each file.

```shell
east twister -T tests -p native_sim --coverage --coverage-tool gcovr
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
