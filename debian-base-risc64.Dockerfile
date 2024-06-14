# syntax=docker/dockerfile:1
#------------------------------------------------------------------------------------#
#Releases:: https://www.debian.org/releases/
#https://hub.docker.com/_/debian/tags
# Preconfigured with: SSHD (root:root | debian:debian)
# REF :: https://docs.docker.com/engine/reference/builder/
# LINT :: https://github.com/hadolint/hadolint
## Note :: NO SPACE after EOS using heredoc `EOS` to write multiline scripts
# URL: https://hub.docker.com/r/azathothas/debian-base-risc64
#FROM debian:latest
FROM debian:testing
#------------------------------------------------------------------------------------#
##ARG for QEMU Config
ARG QM_RAM
#default 2GB
ENV QM_RAM="2G"
ARG QM_CPU
#default 2Cores
ENV QM_CPU="2"
#------------------------------------------------------------------------------------#

#------------------------------------------------------------------------------------#
##Base Deps
ENV DEBIAN_FRONTEND="noninteractive"
RUN <<EOS
  #Base
  apt-get update -y
  apt-get install -y --ignore-missing apt-transport-https apt-utils bash btrfs-progs ca-certificates coreutils curl file git gnupg2 htop jq lsof moreutils ntp software-properties-common sudo tar tmux util-linux wget zip 2>/dev/null
  #RE
  apt-get install -y --ignore-missing apt-transport-https apt-utils bash ca-certificates coreutils curl dos2unix fdupes findutils git gnupg2 jq locales locate moreutils nano ncdu p7zip-full rename rsync software-properties-common texinfo sudo tmux unzip util-linux xz-utils wget zip 2>/dev/null
  apt-get install -y --ignore-missing apt-transport-https apt-utils bash bash-completion build-essential ca-certificates coreutils curl fakeroot file fuse git gnupg2 gpg-agent htop jq kmod less lsof moreutils nano ntp pciutils procps psmisc rsync software-properties-common sudo supervisor tar tmux util-linux xterm wget zip 2>/dev/null
  apt-get install dnsutils 'inetutils*' net-tools netcat-traditional -y -qq 2>/dev/null
  apt-get install 'iputils*' -y -qq 2>/dev/null
  apt-get install 'openssh*' ssh -y -qq 2>/dev/null
  locale-gen "en_US.UTF-8" 2>/dev/null
  #Python
  apt-get install python3 -y
  #Test
  python --version 2>/dev/null ; python3 --version 2>/dev/null
  #Install pip:
  #python3 -m ensurepip --upgrade ; pip3 --version
  #curl -qfsSL "https://bootstrap.pypa.io/get-pip.py" -o "$SYSTMP/get-pip.py" && python3 "$SYSTMP/get-pip.py"
  apt-get install libxslt-dev lm-sensors pciutils procps python3-distro python-dev-is-python3 python3-lxml python3-netifaces python3-pip python3-venv sysfsutils virt-what -y --ignore-missing
  pip install --break-system-packages --upgrade pip || pip install --upgrade pip
  #Misc
  pip install ansi2txt --break-system-packages --force-reinstall --upgrade
  #pipx
  pip install pipx --upgrade 2>/dev/null
  pip install pipx --upgrade --break-system-packages 2>/dev/null
EOS
#------------------------------------------------------------------------------------#

#------------------------------------------------------------------------------------#
##Install QEMU (From Source)
RUN <<EOS
  #Build Deps
  apt-get update -y
  apt-get install -y --no-install-recommends ca-certificates git wget build-essential ninja-build libglib2.0-dev libpixman-1-dev u-boot-qemu unzip libslirp-dev python3-venv -y
  #Build QEMU
  cd "/root" && git clone --filter="blob:none" --quiet "https://github.com/qemu/qemu" 
  mkdir -p "/root/qemu/build" && cd "/root/qemu/build"
  "/root/qemu/configure" --target-list="riscv64-softmmu"
  make --jobs="$(($(nproc)+1))" && make install
  #Cleanup
  apt-get autoremove -y 2>/dev/null
  apt-get clean 2>/dev/null
  rm -rf "/var/lib/apt/lists/"* 2>/dev/null  
  cd "/" && rm -rf "/root/qemu"
EOS
#------------------------------------------------------------------------------------#

#------------------------------------------------------------------------------------#
##Get RISC-V Debian Image : https://gitlab.com/giomasce/dqib
RUN <<EOS
  #https://people.debian.org/~gio/dqib/
  cd "/root" && wget --quiet --show-progress "https://gitlab.com/api/v4/projects/giomasce%2Fdqib/jobs/artifacts/master/download?job=convert_riscv64-virt" -O "./artifacts.zip"
  unzip -jo "./artifacts.zip" -d "/root/riscv64-virt/" && rm -rf "./artifacts.zip"
EOS
#------------------------------------------------------------------------------------#

#------------------------------------------------------------------------------------#
#Expose SSH (root:root | debian:debian)
EXPOSE 2222
#IP: sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_ID
#ssh debian@$CONTAINER_IP -p 2222 
#RUN QEMU: https://wiki.qemu.org/Documentation/Platforms/RISCV
CMD qemu-system-riscv64 -smp "${QM_CPU}" -m "${QM_RAM}" -cpu "rv64" -nographic -machine "virt" -kernel "/usr/lib/u-boot/qemu-riscv64_smode/uboot.elf" -device "virtio-blk-device,drive=hd" -drive "file=/root/riscv64-virt/image.qcow2,if=none,id=hd" -device "virtio-net-device,netdev=net" -netdev "user,id=net,hostfwd=tcp::2222-:22" -object "rng-random,filename=/dev/urandom,id=rng" -device "virtio-rng-device,rng=rng" -append "root=LABEL=rootfs console=ttyS0"
#------------------------------------------------------------------------------------#
