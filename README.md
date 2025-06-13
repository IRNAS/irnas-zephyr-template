# Irnas's Zephyr Project template

IRNAS template for a GitHub repository. It comes with a
[Zephyr group](https://github.com/IRNAS/irnas-workflows-software/tree/main/workflow-templates/zephyr)
of CI workflows for release automation.

The project's documentation can be found in the [doc/](./doc/README.md) folder.

## Checklist

### General GitHub setup

- [ ] Provide a concise and accurate description of your project in the GitHub "description" field.
- [ ] Provide a concise and accurate description of your project in this `README.md` file, replace
      the title. Make sure that you leave the link to the documentation there.
- [ ] Ensure that your project follows [repository naming scheme].

### Tooling

- [ ] Turn on `pre-commit` tool by running `pre-commit install`. If you do not have it yet **or the
      command did not succeed** follow our [instructions].

[instructions]: https://github.com/IRNAS/irnas-guidelines-docs/tree/main/tools/pre-commit

### Zephyr specifics

- [ ] Select the version of NCS in the `west.yaml` file, check the
      [west.yml_usage document](./doc/development/west_yml_usage.md) for more information.
- [ ] Provide repository setup instructions, use the template in the
      [Setup document](./doc/development/setup.md). Replace `<repo-name>` and `<board_name>` as
      appropriate for your project.

### GitHub Actions

- [ ] Set required [GitHub Actions secrets].
- [ ] Create a new project on the [CodeChecker server].
- [ ] Ensure that all rule targets provided in the example makefile work and are relevant for your
      project. Change them or remove them, if you need to. If you remove them make sure that they
      are not called from the enabled workflows.
- [ ] (Optional) Include the `twister-rpi.yaml` GitHub Actions workflow for the on-target testing.
      To do this copy the workflow from the [Twister RPi workflow] into this project and see it's
      [README.md] in this repo for more information on the requirements and setup.
- [ ] (Optional) If creating a public repo, you need to properly configure all `runs-on` statements
      in the GitHub Actions workflows files. See instructions in the [workflows documentation].

### Cleanup

- [ ] Remove any files and folders that your project doesn't require. This avoids possible multiple
      definition issues down the road and keeps your project clean from redundant files.
- [ ] (Optional) If you don't have any Ztest projects in the `test/` folder at this point, disable
      Twister workflow to prevent CI failures. This can be done from:
      `Actions tab -> Twister in the left sidebar -> three dots menu on the right side -> Disable workflow`.
      Don't forget to enable back the workflow (again from the `Actions tab`) when you add first
      Ztests.
- [ ] As a final step delete this checklist and commit changes.

[repository naming scheme]:
  https://github.com/IRNAS/irnas-guidelines-docs/blob/main/docs/github_projects_guidelines.md#repository-naming-scheme-
[GitHub Actions secrets]:
  https://github.com/IRNAS/irnas-workflows-software/tree/main/workflow-templates/zephyr#required-github-action-secrets
[README.md]: scripts/rpi-jlink-server/README.md
[Twister RPi workflow]:
  https://github.com/IRNAS/irnas-workflows-software/tree/main/workflow-templates/rpi-twister-hil
[CodeChecker server]:
  https://github.com/IRNAS/irnas-codechecker-software?tab=readme-ov-file#creating-new-products---codechecker-integration-in-east

## Repository folder structure

- `app` - The main application code, intended to be used in the production.
- `boards` - Board definitions files for custom boards.
- `doc` - Project and development documentation.
- `drivers` - Low-level drivers for peripherals.
- `dts` - Device tree bindings file.
- `samples` - Sample/example code, used either to demonstrate the use or functionality of smaller
  parts of the main application code or used for some testing purposes.
- `scripts` - Various scripts used for development, testing, or automation.
- `subsys` - Subsystem and libraries used by the application and samples.
- `tests` - Firmware used exclusively for unit testing testing or integration testing purposes.
- `.github` - GitHub Actions workflows and other GitHub related files.
