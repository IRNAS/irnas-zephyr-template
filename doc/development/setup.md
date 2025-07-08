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

## Setup signing keys

This project uses the MCUboot bootloader which uses private-public key cryptography to validate the
image signatures at boot time. When building images the build system needs to have access to the
signing keys, so it can sign the built image.

1. Find the keys in 1Password, search by the repository GitHub name.
2. Copy the contents of the signing key files to a local file at the expected paths. The expected
   paths can be found by checking the `pre-build` make target in the `Makefile`.

<!-- prettier-ignore -->
> [!WARNING]
> Signing keys are private keys! Therefore, they must never be leaked to the public. That is why
> they are not included in the repository and ignored in the `.gitignore` file.
> They must always be added to each developer's local environment manually, as described above.
