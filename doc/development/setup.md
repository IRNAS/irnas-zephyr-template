# Development Setup

If you do not already have them you will need to:

- [install west](https://docs.zephyrproject.org/latest/develop/west/install.html)
- [install east](https://github.com/IRNAS/irnas-east-software)

Then follow these steps:

```shell
git clone https://github.com/IRNAS/<repo-name> <repo-name>/project
cd <repo-name>/project

make install-dep
make project-setup
make pre-build
```

## Setup `pre-commit`

Turn on `pre-commit` tool by running `pre-commit install`. If you do not have it installed or the
**command did not succeed** follow
[these instructions](https://github.com/IRNAS/irnas-guidelines-docs/tree/main/tools/pre-commit).
