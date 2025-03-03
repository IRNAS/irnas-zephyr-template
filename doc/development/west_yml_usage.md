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
files. In that case, you have to go to manifest file, find commented module, run `east update`,
return to the `app` directory, delete `build/` directory and build again.

### Updating `sdk-nrf` version

Whenever you want to update the version of `sdk-nrf` (also know simply as `NCS`) you need to keep
one general thing in mind: you need to manually keep revisions of `sdk-nrf` and `sdk-zephyr`
projects, as well as their imports in sync.

1. Open `west.yml` file in `sdk-nrf` repository ([link](https://github.com/nrfconnect/sdk-nrf)).
   Make sure that you select correct tag from selection from top-left drop-down menu.
2. Check what repos are under `sdk-zepyhr` project's `name-allowlist`, those should match the repos
   in `west.yaml` of your project (and this template), under `sdk-zepyhr` project's
   `name-allowlist`. Most of the time they should be commented out, but depends.
3. Check what other repositories appear under `sdk-zepyhr` project as standalone projects, they
   start appearing around line 100, after `NCS repositories` comment. This projects should match the
   repos in `west.yaml` of your project (and this template), under `sdk-nrf` project's
   `name-allowlist`. Most of the time they should be commented out, but again, this depends.

When a new `sdk-nrf` version is released, some new repos as `NCS repositories` might appear or be
moved into `sdk-zephyr`.

After any change to the `west.yaml` do not forget to run `east update`.
