#!/bin/bash
#
# user_create.sh
#
# Creates 20 user accounts (ahead_user00 … ahead_user19), installs xauth, XFCE, and TigerVNC,
# and pre-creates each user’s ~/.Xauthority so that VNC/X11 will work without complaining.
#
# Run this script ONCE as root (or via sudo) on Ubuntu 20.04/22.04/24.04+.

set -euo pipefail

NUM_USERS=20
USER_PREFIX="ahead_user"

# 1) Ensure we are root
if [[ "$(id -u)" -ne 0 ]]; then
  echo "ERROR: This script must be run as root (sudo)." >&2
  exit 1
fi

echo
echo "============================================"
echo "  STEP 1: Install prerequisites (xauth, XFCE, TigerVNC)"
echo "============================================"
echo

# 1a) Update package lists
apt-get update -qq

# 1b) Install xauth (for ~/.Xauthority creation)
if ! dpkg -l | grep -qw xauth; then
  echo "  • Installing xauth..."
  apt-get install -y xauth
else
  echo "  • xauth is already installed."
fi

# 1c) Install XFCE4 desktop environment (lightweight)
if ! dpkg -l | grep -qw xfce4; then
  echo "  • Installing xfce4 and xfce4-goodies..."
  apt-get install -y xfce4 xfce4-goodies
else
  echo "  • xfce4 is already installed."
fi

# 1d) Install TigerVNC server & common utilities
if ! dpkg -l | grep -qw tigervnc-standalone-server; then
  echo "  • Installing tigervnc-standalone-server and tigervnc-common..."
  apt-get install -y tigervnc-standalone-server tigervnc-common
else
  echo "  • tigervnc-standalone-server is already installed."
fi

echo
echo "Prerequisites installed."
echo

# 2) Create (or verify) each user and pre-create ~/.Xauthority
echo "============================================"
echo "  STEP 2: Create users and pre-create ~/.Xauthority"
echo "============================================"
echo

for i in $(seq -w 0 $((NUM_USERS - 1))); do
  user="${USER_PREFIX}${i}"
  home="/home/${user}"

  echo "--------------------------------------------"
  echo "Configuring account: ${user}"
  echo "--------------------------------------------"

  # 2a) If user doesn’t exist, create it
  if ! id "${user}" &>/dev/null; then
    echo "  • User ${user} does not exist. Creating..."
    useradd -m -s /bin/bash "${user}"
    # Lock the account (no login password). Admins can set later if needed.
    passwd -l "${user}" &>/dev/null || true
  else
    echo "  • User ${user} already exists."
  fi

  # 2b) Ensure home directory exists and is owned by that user
  if [[ ! -d "${home}" ]]; then
    echo "    ⚠️  Home directory ${home} missing. Recreating..."
    mkdir -p "${home}"
  fi
  chown "${user}:${user}" "${home}"
  chmod 700            "${home}"
  echo "  • Verified ${home} ownership and permissions."

  # 2c) Pre-create ~/.Xauthority (so that VNC's xauth won't complain)
  XAUTH_FILE="${home}/.Xauthority"
  if [[ ! -f "${XAUTH_FILE}" ]]; then
    echo "  • Creating ${XAUTH_FILE} (for xauth/X11)..."
    sudo -u "${user}" touch "${XAUTH_FILE}"
  fi
  chown "${user}:${user}" "${XAUTH_FILE}"
  chmod 600                   "${XAUTH_FILE}"
  echo "  • ${XAUTH_FILE} owned by ${user} (mode 600)."

  echo "  ✅ ${user} account ready."
  echo
done

echo "============================================"
echo "All ${NUM_USERS} users created/verified. ~/.Xauthority pre-created."
echo "You can now run 'user_vnc.sh' to set up each user’s VNC directories."
echo "============================================"