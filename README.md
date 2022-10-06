# irnas-projects-template

IRNAS template for a Github repository. It comes with a [basic
group](https://github.com/IRNAS/irnas-workflows-software/tree/dev/workflow-templates/basic)
of CI workflows for release automation.

## Checklist

- [ ] Provide a concise and accurate description of your project in the GitHub "description" field.
- [ ] Provide a concise and accurate description of your project in this `README.md` file, replace the title.
- [ ] Ensure that your project follows [repository naming scheme](https://github.com/IRNAS/irnas-guidelines-docs/blob/dev/docs/github_projects_guidelines.md#repository-naming-scheme-).
- [ ] Turn on `gitlint` tool by following the instructions [here](https://github.com/IRNAS/irnas-guidelines-docs/tree/dev/tools/gitlint).
- [ ] As final step delete this checklist and commit changes.


## west.yaml and name-allowlist

Manifest file (`west.yaml`) that comes with this template by defulat only allows
certain modules from Nordic's `sdk-nrf` and `sdk-zephyr` repositories, while
ignoring/blocking others.

This means that a setup on the new machine and in CI is faster as `west update`
command does not clone all modules from mentioned repositories but only the ones
that are needed.

Manifest file only allows modules that are commonly used by IRNAS, however this
can be easly changed by uncommenting required module and runnning `west update`.

**IMPORTANT:** Such improvements do not come with some tradeoffs, there are now
two things that a developer must take note of:
1. If application source code includes some headers from blocked modules or if
   included headers use blocked modules you will get an error that will
   complain about missing header file. In that case you have to go to manifest
   file, find commented module, run `west update`, return to app folder, delete
   build folder and build again.
2. You need to manually keep revisions of `sdk-nrf` and `sdk-zephyr` projects in
   sync: If you update `sdk-nrf` revision, open their repo in the GitHub, select
   the used revision tag and check in the `west.yaml` what version of
   `sdk-zepyhr` is used. Run `west update` after change.
