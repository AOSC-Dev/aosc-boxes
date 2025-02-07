# aosc-boxes

## Images

### QCOW2 images
At the time of writing we offer two different QCOW2 images. The images are synced to the mirrors under the `images` directory, e.g.: https://releases.aosc.io/os-amd64/images/.

#### Basic image
The basic image is meant for local usage and comes preconfigured with the user `aosc` (password: `aosc`) and sshd running.

#### Cloud image
The cloud image is meant to be used in "the cloud" and comes with [`cloud-init`](https://cloud-init.io/) preinstalled.

## Development

### Dependencies
You'll need the following dependencies:

* libisoburn

### How to build this
The official builds are done in our Arch Linux GitLab CI and can be built locally by running (as root):

    ./build.sh
