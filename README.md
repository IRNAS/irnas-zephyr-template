# Irnas's Zephyr Project template

IRNAS template for a GitHub repository. It comes with a
[Zephyr group](https://github.com/IRNAS/irnas-workflows-software/tree/main/workflow-templates/zephyr)
of CI workflows for release automation.

## Checklist

- [ ] Provide a concise and accurate description of your project in the GitHub
      "description" field.
- [ ] Provide a concise and accurate description of your project in this
      `README.md` file, replace the title.
- [ ] Ensure that your project follows [repository naming scheme].
- [ ] Turn on `gitlint` tool by running `gitlint install-hook`. If you do not
      have it yet, follow instructions
      [here](https://github.com/IRNAS/irnas-guidelines-docs/tree/main/tools/gitlint).
- [ ] Select the version of NCS in the `west.yaml` file, check the below section
      for specifics.
- [ ] Provide repository setup instructions, use template in _Setup_ section
      below. Replace `<repo-name>`, `<board_name>`, and `<build_type>` as
      appropriate for your project.
- [ ] Set required [GitHub Actions secrets]. You can also **contact person in
      charge for this** to do it for you.
- [ ] Create a new project on the CodeChecker server. You can also **contact
      person in charge** to do it for you.
- [ ] (Optional) Include the `twister-rpi.yaml` GitHub Actions workflow for the
      on-target testing. To do this copy the workflow from the [Twister RPi
      workflow] into this project and see it's [README.md] in this repo for more
      information on the requirements and setup.
- [ ] Remove any files and folders that your project doesn't require. This avoid
      possible multiple definition issues down the road and keeps your project
      clean from redundant files.
- [ ] Ensure that all rule targets provided in the example makefile work and are
      relevant for your project. Change them or remove them, if you need to. If
      you remove them make sure that they are not called from the enabled
      workflows.
- [ ] As a final step delete this checklist and commit changes.

[repository naming scheme]:
  https://github.com/IRNAS/irnas-guidelines-docs/blob/main/docs/github_projects_guidelines.md#repository-naming-scheme-
[GitHub Actions secrets]:
  https://github.com/IRNAS/irnas-workflows-software/tree/main/workflow-templates/zephyr#required-github-action-secrets
[README.md]: scripts/rpi-jlink-server/README.md
[Twister RPi workflow]:
  https://github.com/IRNAS/irnas-workflows-software/tree/main/workflow-templates/rpi-twister-hil

## Setup

If you do not already have them you will need to:

- [install west](https://developer.nordicsemi.com/nRF_Connect_SDK/doc/latest/nrf/gs_installing.html#install-west)
- [install east](https://github.com/IRNAS/irnas-east-software)

Then follow these steps:

```shell
east init -m https://github.com/IRNAS/<repo-name> <repo-name>
cd <repo-name>/project

# Set up east globally (this only needs to be done once on each machine)
east install nrfutil-toolchain-manager
# Install toolchain for the version of NCS used in this project
east install toolchain

# Run `west update` via east to set up west modules in the repository
east update
```

## Building and flashing

To build the application firmware:

```bash
cd app
east build -b <board_name> -u <build_type>
```

To flash the firmware:

```bash
east flash
```

To view RTT logs:

```bash
# Run in first terminal window
east util connect

# Run in second, new terminal window
east util rtt
```

## west.yaml and name-allowlist

The manifest file (`west.yaml`) that comes with this template by default only
allows certain modules from Nordic's `sdk-nrf` and `sdk-zephyr` repositories,
while ignoring/blocking others.

This means that a setup on the new machine and in CI is faster as the
`west update` command does not clone all modules from the mentioned repositories
but only the ones that are needed.

Manifest file only allows modules that are commonly used by IRNAS, however this
can be easily changed by uncommenting the required modules and running
`west update`.

**IMPORTANT:** Such improvements do not come with some tradeoffs, there are now
two things that a developer must take note of.

### Compile time errors cause of blocked/missing headers

If the application source code includes some headers from blocked/missing
modules or if included headers use blocked/missing modules you will get an error
that will complain about missing header files. In that case, you have to go to
manifest file, find commented module, run `west update`, return to the app
folder, delete build folder and build again.

### Updating `sdk-nrf` version

Whenever you want to update the version of `sdk-nrf` (also know simply as `NCS`)
you need to keep one general thing in mind: you need to manually keep revisions
of `sdk-nrf` and `sdk-zephyr` projects, as well as their imports in sync.

1. Open `west.yml` file in `sdk-nrf` repository
   ([link](https://github.com/nrfconnect/sdk-nrf)). Make sure that you select
   correct tag from selection from top-left dropdown menu.
2. Check what repos are under `sdk-zepyhr` project's `name-allowlist`, those
   should match the repos in `west.yaml` of your project (and this template),
   under `sdk-zepyhr` project's `name-allowlist`. Most of the time they should
   be commented out, but depends.
3. Check what other repositories appear under `sdk-zepyhr` project as standalone
   projects, they start appearing around line 100, after `NCS repositories`
   comment. This projects should match the repos in `west.yaml` of your project
   (and this template), under `sdk-nrf` project's `name-allowlist`. Most of the
   time they should be commented out, but again, this depends.

When a new `sdk-nrf` version is released, some new repos as `NCS repositories`
might appear or be moved into `sdk-zephyr`.

After any change to the `west.yaml` do not forget to run `west update`.
