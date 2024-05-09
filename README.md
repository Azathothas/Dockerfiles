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
> > - Building
> > ```bash
> > !# Get Dockerfile
> > pushd "$(mktemp -d)" >/dev/null 2>&1 && \
> > curl -qfsSLJO "https://pub.ajam.dev/repos/Azathothas/Dockerfiles/x86_64-ubuntu.dockerfile"
> > export DOCKER_CONTAINER_FILE="./x86_64-ubuntu.dockerfile"
> > export DOCKER_CONTAINER_NAME="x86_64-ubuntu"
> > export DOCKER_CONTAINER_TAG="x86_64-ubuntu:debug"
> > 
> > !# Build [Remove --no-cache if wants to skip steps]
> > docker image remove "${DOCKER_CONTAINER_NAME}" --force 2>/dev/null
> > docker build "./" --file "${DOCKER_CONTAINER_FILE}" --tag "${DOCKER_CONTAINER_TAG}" --no-cache
> > docker images --filter "${DOCKER_CONTAINER_TAG}"
> > 
> > !# Run [Use --publish (p) "127.0.0.1:$PORT:22" to assign a Fixed Port ]
> > docker stop "$(docker ps -aqf name=${DOCKER_CONTAINER_NAME})" 2>/dev/null ; docker rm "$(docker ps -aqf name=${DOCKER_CONTAINER_NAME})" 2>/dev/null
> > docker run --runtime="sysbox-runc" --detach --name "${DOCKER_CONTAINER_NAME}" "${DOCKER_CONTAINER_TAG}"
> > # docker run --runtime="sysbox-runc" --detach --publish-all --name "${DOCKER_CONTAINER_NAME}" "${DOCKER_CONTAINER_TAG}"
> > # docker run --runtime="sysbox-runc" --detach --publish "127.0.0.1:2222:22" --name "${DOCKER_CONTAINER_NAME}" "${DOCKER_CONTAINER_TAG}"
> > echo -e "IP Address : $(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${DOCKER_CONTAINER_NAME})"
> > 
> > # If Publised Ports : echo -e "Ports : $(docker inspect --format='{{range $p, $conf := .NetworkSettings.Ports}}{{$p}} -> {{(index $conf 0).HostPort}} {{end}}' ${DOCKER_CONTAINER_NAME})"
> >
> > !# SSH
> > SSH_IP="$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${DOCKER_CONTAINER_NAME})" 2>/dev/null ; \
> > SSH_PORT="$(docker inspect --format='{{(index (index .NetworkSettings.Ports "22/tcp") 0).HostPort}}' ${DOCKER_CONTAINER_NAME} 2>/dev/null)" ; \
> > echo -e "\n To SSH (password: runneradmin)\n ssh-keygen -f \"$HOME/.ssh/known_hosts\" -R \"${SSH_IP}\"\n ssh \"runner@${SSH_IP}\" -p \"${SSH_PORT:-22}\" -o \"StrictHostKeyChecking=no\"\n"
> >
> > !# If SSH Fails
> > docker exec --interactive --tty "${DOCKER_CONTAINER_NAME}" bash -il
> > 
> > !# Cleanup
> > docker stop "$(docker ps -aqf name=${DOCKER_CONTAINER_NAME}" 2>/dev/null ; docker rm "$(docker ps -aqf name=${DOCKER_CONTAINER_NAME})" 2>/dev/null
> > docker image remove "${DOCKER_CONTAINER_TAG}" --force
> > popd >/dev/null 2>&1
> > ```
