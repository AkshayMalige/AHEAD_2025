#!/bin/bash
#
# user_create.sh
#
# Creates 20 user accounts (ahead_user00 … ahead_user19), installs xauth, XFCE, and TigerVNC,
# and assigns each user a known login password ("workshop").  It also pre-creates ~/.Xauthority
# so that VNC/X11 will work without “.Xauthority does not exist” errors.
#
# Run this script ONCE as root (or via sudo) on Ubuntu 20.04/22.04/24.04+.

set -euo pipefail

NUM_USERS=20
USER_PREFIX="ahead_user"
DEFAULT_PASSWORD="workshop"

# 1) Ensure we are root
if [[ "$(id -u)" -ne 0 ]]; then
  echo "ERROR: This script must be run as root (sudo)." >&2
  exit 1
fi

echo
echo "=================================================="
echo "  STEP 1: Install prerequisites (xauth, XFCE, VNC) "
echo "=================================================="
echo

# Update package lists quietly
apt-get update -qq

# 1a) Install xauth (for ~/.Xauthority creation)
if ! dpkg -l | grep -qw xauth; then
  echo "  • Installing xauth..."
  apt-get install -y xauth
else
  echo "  • xauth is already installed."
fi

# 1b) Install XFCE4 desktop environment (lightweight)
if ! dpkg -l | grep -qw xfce4; then
  echo "  • Installing xfce4 and xfce4-goodies..."
  apt-get install -y xfce4 xfce4-goodies
else
  echo "  • xfce4 is already installed."
fi

# 1c) Install TigerVNC server & common utilities
if ! dpkg -l | grep -qw tigervnc-standalone-server; then
  echo "  • Installing tigervnc-standalone-server and tigervnc-common..."
  apt-get install -y tigervnc-standalone-server tigervnc-common
else
  echo "  • tigervnc-standalone-server is already installed."
fi

echo
echo "Prerequisites installed."
echo

# 2) Create (or verify) each user, set their password, and pre-create ~/.Xauthority
echo "=================================================="
echo "  STEP 2: Create users, set password, make .Xauthority"
echo "=================================================="
echo

for i in $(seq -w 0 $((NUM_USERS - 1))); do
  user="${USER_PREFIX}${i}"
  home="/home/${user}"

  echo "----------------------------------------------"
  echo "Configuring account: ${user}"
  echo "----------------------------------------------"

  # 2a) If user doesn’t exist, create it
  if ! id "${user}" &>/dev/null; then
    echo "  • User ${user} does not exist. Creating..."
    useradd -m -s /bin/bash "${user}"
  else
    echo "  • User ${user} already exists."
  fi

  # 2b) Set (or reset) the UNIX login password to $DEFAULT_PASSWORD
  echo "${user}:${DEFAULT_PASSWORD}" | chpasswd
  echo "  • Password for ${user} set to '${DEFAULT_PASSWORD}'."

  # 2c) Ensure home directory exists & is owned by that user
  if [[ ! -d "${home}" ]]; then
    echo "    ⚠️  Home directory ${home} missing. Recreating..."
    mkdir -p "${home}"
  fi
  chown "${user}:${user}" "${home}"
  chmod 700            "${home}"
  echo "  • Verified ownership/permissions on ${home}"

  # 2d) Pre-create ~/.Xauthority (so that VNC's xauth won't complain)
  XAUTH_FILE="${home}/.Xauthority"
  if [[ ! -f "${XAUTH_FILE}" ]]; then
    echo "  • Creating ${XAUTH_FILE} (for xauth/X11)..."
    sudo -u "${user}" touch "${XAUTH_FILE}"
  fi
  chown "${user}:${user}" "${XAUTH_FILE}"
  chmod 600                   "${XAUTH_FILE}"
  echo "  • ${XAUTH_FILE} owned by ${user} (mode 600)."

  echo "  ✅ ${user} account ready (login password = '${DEFAULT_PASSWORD}')."
  echo
done

echo "=================================================="
echo "All ${NUM_USERS} users created/verified."
echo "You can now run 'user_vnc.sh' to set up each user’s VNC directories."
echo "=================================================="