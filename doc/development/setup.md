# Development Setup

If you do not already have them you will need to:

- [install west](https://docs.zephyrproject.org/latest/develop/west/install.html)
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

# Create default VERSION files
make gen-version
```

## Setup `pre-commit`

Turn on `pre-commit` tool by running `pre-commit install`. If you do not have it yet **or the
command did not succeed** follow instructions
[here](https://github.com/IRNAS/irnas-guidelines-docs/tree/main/tools/pre-commit).
