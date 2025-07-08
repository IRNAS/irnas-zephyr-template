# Signing keys

Each project using MCUBoot requires signing keys to sign the firmware images. These keys are used to
verify the integrity and authenticity of the firmware during the boot process.

In most cases, the project will require only a single signing key, due to using a single application
firmware. If more than one application firmware is needed, multiple signing keys are probably needed
as well.

## Creating the first signing key

1. Create a signing key file using the following command from the root of the project:

   ```shell
   east bypass -- python3 ../bootloader/mcuboot/scripts/imgtool.py keygen -t ecdsa-p256 -k app/signing_key.pem
   ```

2. Create an entry in 1Password and paste contents of the created signing key file, so that it can
   be used by other developers. Use GitHub repository name and keys purpose as the entry title, for
   example `client-project-firmware - Main application signing key`.

3. Add a new GitHub secret with the signing key file contents:

   - Go to your GitHub repository.
   - Navigate to `Settings -> Secrets and variables -> Actions`.
   - Press the `New secret` button.
   - Set the name of the secret to `IMAGE_SIGN_KEY`, and paste the contents of the signing key file.

The `app/signing_key.pem` file is not tracked by Git, so it will not be included in the repository.
If you ever delete the file, you will need to recreate it from the 1Password entry.

## Creating additional signing keys

For each additional signing key you need to create, follow these steps:

1. Follow the steps from the "Creating the first signing key" section to create an additional
   signing key. Use a different name for the signing key file, 1Password entry and GitHub secret.
   Use a consistent naming scheme.
2. Update the `env` section in each workflow file (found in `.github/workflow`) that calls the
   `make pre-build` target. The `env` section should convert the secret into an environment
   variable, e.g. `EXTRA_IMAGE_SIGN_KEY: ${{ secrets.EXTRA_IMAGE_SIGN_KEY}}`.
3. Update the `pre-build` make target in the `Makefile` by adding an additional call to the
   `create_signing_keys.sh` script with chosen signing key filename.
