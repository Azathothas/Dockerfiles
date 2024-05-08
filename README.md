- #### Setup
> - [Install Sysbox](https://github.com/nestybox/sysbox) ([Supported Distros](https://github.com/nestybox/sysbox/blob/master/docs/distro-compat.md#supported-linux-distros))
> ```bash
> !# Del Existing Docker Images
> docker rm $(docker ps -a -q) -f
> ARCH="$(uname -m)" ; [ "${ARCH}" = "aarch64" ] && ARCH="arm64" || [ "${ARCH}" = "x86_64" ] && ARCH="amd64"
>
> #-------------------------------------------------------#
> 🌀 ❯ [Debian]
> !# Install Deps
> sudo apt-get update -y -qq
> sudo apt-get install fuse3 libfuse-dev -y
> sudo apt-get install "linux-headers-$(uname -r)" -y
> sudo apt-get install linux-headers-"${ARCH}" -y
> sudo apt-get --fix-broken install -y
> 
> # Get .Deb PKGS
> pushd "$(mktemp -d)" >/dev/null 2>&1 && \
> wget --quiet --show-progress "$(curl -qfsSL 'https://api.github.com/repos/nestybox/sysbox/releases/latest' | jq -r '.body' | sed -n 's/.*(\(https:\/\/.*\.deb\)).*/\1/p' | grep -i "${ARCH}")" -O "./sysbox.deb" && sudo dpkg -i "./sysbox.deb" ; popd >/dev/null 2>&1
> sudo apt-get autoremove -y -qq ; sudo apt-get update -y -qq && sudo apt-get upgrade -y -qq
> #Test
> sysbox-runc --version
> #-------------------------------------------------------#
> ```
---
- #### [x86_64-Ubuntu](https://github.com/Azathothas/Dockerfiles/blob/main/x86_64-ubuntu.dockerfile)
> - This is a base image [`ubuntu:latest`](https://hub.docker.com/_/ubuntu) with some additional tweaks & addons
> - **Preconfigured** : `Systemd + SSHD + Docker`
> - **Runtime** : [`sysbox-runc`]((https://github.com/nestybox/sysbox))
> - **Init** : [s6-overlay](https://github.com/just-containers/s6-overlay)
> - **Docker Hub** : (https://hub.docker.com/r/azathothas/x86_64-ubuntu)
> ```bash
> docker run --runtime="sysbox-runc" -it --rm --name="ubuntu-systemd" "azathothas/ubuntu-systemd-base:latest"
> !# Login
> "${USER}"="runner"
> "${PASSWORD}"="runneradmin"
> ```
