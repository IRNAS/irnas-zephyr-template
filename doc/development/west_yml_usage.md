# `west.yml` usage

## `west.yaml` and `name-allowlist`

The manifest file (`west.yaml`) that comes with this template by default only allows certain modules
from Nordic's `sdk-nrf` and `sdk-zephyr` repositories, while ignoring/blocking others.

This means that a setup on the new machine and in CI is faster as the `east update` command does not
clone all modules from the mentioned repositories but only the ones that are needed.

Manifest file only allows modules that are commonly used by IRNAS, however this can be easily
changed by uncommenting the required modules and running `east update`.

**IMPORTANT:** Such improvements do not come without some trade-offs. There are now two things that
a developer must take note of.

### Compile time errors cause of blocked/missing headers

If the application source code includes some headers from blocked/missing modules or if included
headers use blocked/missing modules you will get an error that will complain about missing header
files. In that case, you have to go to manifest file, find and uncomment the module, run
`east update`, return to the `app` directory, delete `build/` directory and build again.

### Updating `sdk-nrf` version

Whenever you want to update the version of `sdk-nrf` (also know simply as `NCS`) you need to keep
one general thing in mind: you need to manually keep revisions of `sdk-nrf` and `sdk-zephyr`
projects, as well as their imports in sync.

1. Open `west.yml` file in the `sdk-nrf` ([repository](https://github.com/nrfconnect/sdk-nrf)). Make
   sure that you select the correct tag from the available selection from the top-left drop-down
   menu.
2. Check which repositories appear under `sdk-zepyhr` project as standalone projects, they start
   appearing around line 114, after the `# NCS repositories` comment. These projects should match
   the repos in `west.yaml` of your project, under `sdk-nrf` project's `name-allowlist`. Leave them
   all commented out, unless required by the project.
3. Open `west.yml` file in the `sdk-zephyr`
   ([repository](https://github.com/nrfconnect/sdk-zephyr/)). Make sure that you select the correct
   tag from the available selection from the top-left drop-down menu.
4. Check what repos are under `projects`. those should match the repos in `west.yaml` of your
   project, under `sdk-zepyhr` project's `name-allowlist`. Leave them all commented out, unless
   required by the project.

When a new `sdk-nrf` version is released, some new repos as `NCS repositories` might appear or be
moved into `sdk-zephyr`.

After any change to the `west.yaml` do not forget to run `east update`.
