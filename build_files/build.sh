#!/bin/bash

set ${SET_X:+-x} -eou pipefail

trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
    echo -e "\n\n=== $* ===\n\n"
}

### Install packages
log "Starting packages installation"

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

# COPR repos
log "Enabling COPR"
COPR_REPOS=(
    atim/starship
)
dnf5 -y copr enable "${COPR_REPOS[@]}"

# Layered Applications
log "Installing RPM packages"
LAYERED_PACKAGES=(
    starship
    tmux
)
dnf5 install --setopt=install_weak_deps=False -y "${LAYERED_PACKAGES[@]}"

# MEGA
mkdir -p /var/opt/megasync
wget https://mega.nz/linux/repo/Fedora_42/x86_64/megasync-Fedora_42.x86_64.rpm && dnf5 install -y //megasync-Fedora_42.x86_64.rpm
wget https://mega.nz/linux/repo/Fedora_41/x86_64/nautilus-megasync-Fedora_41.x86_64.rpm && dnf5 install -y //nautilus-megasync-Fedora_41.x86_64.rpm

log "Enabling System Unit Files"

#### Example for enabling a System Unit File
systemctl enable podman.socket

log "Disabling COPR"
dnf5 -y copr disable "${COPR_REPOS[@]}"

log "Build completed"
