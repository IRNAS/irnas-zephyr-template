# irnas-projects-template

IRNAS template for a GitHub repository. It comes with a [basic
group](https://github.com/IRNAS/irnas-workflows-software/tree/dev/workflow-templates/basic)
of CI workflows for release automation.

## Checklist

- [ ] Provide a concise and accurate description of your project in the GitHub
  "description" field.
- [ ] Provide a concise and accurate description of your project in this
  `README.md` file, replace the title.
- [ ] Ensure that your project follows [repository naming scheme](https://github.com/IRNAS/irnas-guidelines-docs/blob/dev/docs/github_projects_guidelines.md#repository-naming-scheme-).
- [ ] Turn on `gitlint` tool by following the instructions [here](https://github.com/IRNAS/irnas-guidelines-docs/tree/dev/tools/gitlint).
- [ ] Select the version of NCS in the `west.yaml` file, check the below section for
  specifics.
- [ ] Provide repository setup instructions, use template in _Setup_ section
  below.
- [ ] As the final step delete this checklist and commit changes.

## Setup

If not already set up, install west and other required tools.
Follow the steps [here](https://developer.nordicsemi.com/nRF_Connect_SDK/doc/latest/nrf/gs_installing.html)
from [Install the required tools](https://developer.nordicsemi.com/nRF_Connect_SDK/doc/latest/nrf/gs_installing.html#install-the-required-tools)
up to (including) [Install west](https://developer.nordicsemi.com/nRF_Connect_SDK/doc/latest/nrf/gs_installing.html#install-the-required-tools).

Then follow these steps:

```bash
west init -m https://github.com/IRNAS/<repo-name> <repo-name>
cd <repo-name>/
west update
# remember to source zephyr env
source zephyr/zephyr-env.sh
```

## west.yaml and name-allowlist

The manifest file (`west.yaml`) that comes with this template by default only allows
certain modules from Nordic's `sdk-nrf` and `sdk-zephyr` repositories, while
ignoring/blocking others.

This means that a setup on the new machine and in CI is faster as `west update`
the command does not clone all modules from mentioned repositories but only the ones
that is needed.

Manifest file only allows modules that are commonly used by IRNAS, however this
can be easily changed by uncommenting the required module and running `west update`.

**IMPORTANT:** Such improvements do not come with some tradeoffs, there are now
two things that a developer must take note of:
1. If the application source code includes some headers from blocked modules or if
   included headers use blocked modules you will get an error that will
   complain about missing header files. In that case, you have to go to manifest
   file, find commented module, run `west update`, return to the app folder, delete
   build folder and build again.
2. You need to manually keep revisions of `sdk-nrf` and `sdk-zephyr` projects in
   sync: If you update `sdk-nrf` revision, open their repo in the GitHub, select
   the used revision tag and check in the `west.yaml` what version of
   `sdk-zepyhr` is used. Run `west update` after the change.
