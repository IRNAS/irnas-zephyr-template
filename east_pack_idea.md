# Context

`east release` command and `east.yaml` became more and more unsuitable as the Zephyr project kept
introducing newer build system concepts (ei. sysbuild, shields, snippets).

Instead of trying to keep up in terms of functionality in the east's codebase, it is more pragmatic
to reuse what Zephyr already offers and try to build on top of it.

I have recently opened an [issue](https://github.com/zephyrproject-rtos/zephyr/issues/86720) on the
Zephyr's GitHub to start the discussion on the topic of adding a release process generation tool to
the `west command` or `west twister`.

Since there wasn't much feedback from the community I decided that the way to go is to add
`east pack` command that will do something like I suggested in the linked issue:

> As a separate west command that processes the twister-out folder and generates the final release
> directory.

This issue serves as a place for discussion on how this new `east pack` command should be
implemented and how configurable it should be.

## High-level ideas

- `east pack` requires that `east twister` / `west twister` command was run first, as it requires
  `twister-out` as an input.
- It shouldn't be required that Twister was invoked with some specific flags for `east pack` to
  work.
- The selection of build artifacts should be configurable, since that is pretty much application
  specific. Some projects just need the final application hex file, in other cases we would need
  `app_update.bin`, `dfu_application.zip`.
- The resulting folder structure should be sensible and understandable by technical non-Zephyr
  users.

## Configurability

`east pack` should be configurable via `east.yaml` file.

Some rules about the configuration format:

- `pack.projects.<project_name>.artifacts` - list of artifacts that should be included in the
  release folder.
- `pack.projects.<project_name>.artifacts.<artifact_name>` - path to the artifact file (not dir). It
  must be relative to the build folder
- `$APP_DIR` - special variable that will be replaced with the path to the application directory
  that is found in generated build folder. Since that path is always different for each project and
  it can depend on whether the sysbuild is used or not, it is practical to hardcode it in the
  `east.yaml`.

```yaml
pack:
  projects:
    app.prod:
      artifacts:
        - $APP_DIR/zephyr.hex
        - $APP_DIR/zephyr.elf
        - $APP_DIR/mcuboot.hex
        - dfu_application.zip
    app.rtt:
      artifacts:
        - $APP_DIR/zephyr.hex
        - dfu_application.zip
```

To avoid duplication of the same artifacts for multiple projects, there should be a way to define
common artifacts for all projects. This can be done by adding a `pack.artifacts` key to the
`east.yaml`.

```yaml
pack:
  artifacts:
    - $APP_DIR/zephyr.hex
    - dfu_application.zip
  projects:
    app.prod:
      artifacts:
        - $APP_DIR/zephyr.elf
        - $APP_DIR/mcuboot.hex
```

- `pack.artifacts` - list of artifacts that should be included in the release folder for all
  projects. This is useful for artifacts that are common for all projects, like
  `dfu_application.zip` or `mcuboot.hey`.
- `pack.projects.<project_name>.artifacts` extends the `pack.artifacts` list.

From above follows:

- Each project needs to have a list of artifacts that should be gathered. It gets that list either
  by extending the common artifacts list or by defining its own list. If it doesn't have a list that
  is considered an configuration error and `east pack` should fail.

## Generated folder structure

TODO: This needs to be expanded.

## Definition of Done

TODO: This needs to be expanded.

## Related issues

Once this is implemented the following issues can be closed:

- #123
- #122
- #48

. ├── cmake_install.cmake ├── dfu_application.zip ├── dfu_application.zip_manifest.json ├──
domains.yaml ├── mcuboot │   ├── zephyr │   │   ├── runners.yaml │   │   ├── zephyr.bin │   │   ├──
zephyr.dts │   │   ├── zephyr.elf │   │   ├── zephyr_final.map │   │   ├── zephyr.hex │   │   ├──
zephyr.map ├── merged.hex ├── nrf91_app │   ├── tfm │   │   ├── api_ns │   │   ├── bin │   ├──
zephyr │   │   ├── runners.yaml │   │   ├── tfm_merged.hex │   │   ├── zephyr.bin │   │   ├──
zephyr.dts │   │   ├── zephyr.elf │   │   ├── zephyr_final.map │   │   ├── zephyr.hex │   │   ├──
zephyr.map │   │   ├── zephyr.signed.bin │   │   ├── zephyr.signed.hex ├── partitions.yml ├──
run_id.txt
