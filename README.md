# Irnas's Zephyr Project template

IRNAS template for a GitHub repository. It comes with a
[basic group](https://github.com/IRNAS/irnas-workflows-software/tree/dev/workflow-templates/basic)
of CI workflows for release automation.

## Checklist

- [ ] Provide a concise and accurate description of your project in the GitHub
      "description" field.
- [ ] Provide a concise and accurate description of your project in this
      `README.md` file, replace the title.
- [ ] Ensure that your project follows
      [repository naming scheme](https://github.com/IRNAS/irnas-guidelines-docs/blob/dev/docs/github_projects_guidelines.md#repository-naming-scheme-).
- [ ] Turn on `gitlint` tool by following the instructions
      [here](https://github.com/IRNAS/irnas-guidelines-docs/tree/dev/tools/gitlint).
- [ ] Select the version of NCS in the `west.yaml` file, check the below section
      for specifics.
- [ ] Provide repository setup instructions, use template in _Setup_ section
      below. Replace `<repo-name>`, `<board_name>`, and `<build_type>` as
      appropriate for your project.
- [ ] As the final step delete this checklist and commit changes.

## Setup

If you do not already have them you will need to:

- [install west](https://developer.nordicsemi.com/nRF_Connect_SDK/doc/latest/nrf/gs_installing.html#install-west)
- [install east](https://github.com/IRNAS/irnas-east-software)

Then follow these steps:

```bash
west init -m https://github.com/IRNAS/<repo-name> <repo-name>
cd <repo-name>/project
west update

# set up east globally (this only needs to be done once on each machine)
east sys-setup
# install toolchain for the version of NCS used in this project
east update toolchain
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
