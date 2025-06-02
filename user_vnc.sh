#!/bin/bash
#
# user_vnc.sh
#
# This script configures 20 “ahead_userXX” accounts (ahead_user00 … ahead_user19)
# to run TigerVNC with a minimal XFCE desktop. It:
#   • Installs xauth, XFCE, and TigerVNC if missing
#   • Verifies ownership/permissions on /home/ahead_userXX
#   • Creates ~/.Xauthority so xauth won’t complain
#   • Builds ~/.vnc/xstartup to launch XFCE via “exec startxfce4”
#   • Writes a default VNC password file (password = “workshop”)
#
# Run **once** as root (or via sudo) on Ubuntu 20.04/22.04/24.04+.
# After this script finishes, each ahead_userXX can “vncserver :N” and
# will get a persistent XFCE desktop (no more .Xauthority errors, and
# GUI apps like Firefox or terminal will launch correctly).

set -euo pipefail

NUM_USERS=20
USER_PREFIX="ahead_user"

# 1) Ensure the script is run as root
if [[ "$(id -u)" -ne 0 ]]; then
  echo "ERROR: This script must be run as root (sudo)."
  exit 1
fi

echo
echo "========================================"
echo "    VNC Setup Script for 20 Users       "
echo "========================================"
echo

# 2) Install system-wide prerequisites if missing
echo "==> Installing packages (xauth, XFCE4, TigerVNC)…"

# Update package lists
apt-get update -qq

# 2a) xauth (for ~/.Xauthority creation)
if ! dpkg -l | grep -qw xauth; then
  echo "    • Installing xauth"
  apt-get install -y xauth
else
  echo "    • xauth already installed"
fi

# 2b) XFCE4 desktop (lightweight)
if ! dpkg -l | grep -qw xfce4; then
  echo "    • Installing xfce4 and xfce4-goodies"
  apt-get install -y xfce4 xfce4-goodies
else
  echo "    • xfce4 already installed"
fi

# 2c) TigerVNC server & common
if ! dpkg -l | grep -qw tigervnc-standalone-server; then
  echo "    • Installing tigervnc-standalone-server and tigervnc-common"
  apt-get install -y tigervnc-standalone-server tigervnc-common
else
  echo "    • tigervnc-standalone-server already installed"
fi

echo "==> Package installation complete."
echo

# 3) Loop over each user (ahead_user00 … ahead_user19)
for i in $(seq -w 0 $((NUM_USERS - 1))); do
  user="${USER_PREFIX}${i}"
  home_dir="/home/${user}"

  echo "----------------------------------------"
  echo "Configuring VNC for user: ${user}"
  echo "----------------------------------------"

  # 3a) Create user if it does not exist
  if ! id "${user}" &> /dev/null; then
    echo "    • User ${user} does not exist. Creating…"
    useradd -m -s /bin/bash "${user}"
    # Lock the account (optional—adjust if you want to set a password)
    passwd -l "${user}" &> /dev/null || true
  else
    echo "    • User ${user} already exists."
  fi

  # 3b) Ensure /home/ahead_userXX is owned by that user
  if [[ ! -d "${home_dir}" ]]; then
    echo "    • Home directory ${home_dir} missing. Recreating…"
    mkdir -p "${home_dir}"
  fi
  chown "${user}:${user}" "${home_dir}"
  chmod 700            "${home_dir}"
  echo "    • Verified ownership/permissions on ${home_dir}"

  # 3c) Create ~/.Xauthority for xauth
  # On first VNC start, xauth will write to ~/.Xauthority—but to avoid "file … does not exist"
  # we explicitly create it now, owned by the user.
  XAUTH_FILE="${home_dir}/.Xauthority"
  if [[ ! -f "${XAUTH_FILE}" ]]; then
    echo "    • Creating ${XAUTH_FILE}"
    sudo -u "${user}" touch "${XAUTH_FILE}"
  fi
  chown "${user}:${user}" "${XAUTH_FILE}"
  chmod 600                   "${XAUTH_FILE}"
  echo "    • Set ownership/permissions on ${XAUTH_FILE}"

  # 3d) Create ~/.vnc directory
  VNC_DIR="${home_dir}/.vnc"
  if [[ ! -d "${VNC_DIR}" ]]; then
    echo "    • Creating ${VNC_DIR}"
    mkdir -p "${VNC_DIR}"
  fi
  chown "${user}:${user}" "${VNC_DIR}"
  chmod 700                  "${VNC_DIR}"
  echo "    • Verified ${VNC_DIR}"

  # 3e) Create or overwrite ~/.vnc/passwd (default password = "workshop")
  echo "workshop" | sudo -u "${user}" vncpasswd -f > "${VNC_DIR}/passwd"
  chmod 600 "${VNC_DIR}/passwd"
  chown "${user}:${user}" "${VNC_DIR}/passwd"
  echo "    • Wrote VNC password file at ${VNC_DIR}/passwd (password = 'workshop')"

  # 3f) Create ~/.vnc/xstartup to launch XFCE properly
  XSTARTUP_FILE="${VNC_DIR}/xstartup"
  cat << 'EOF' > "${XSTARTUP_FILE}"
#!/bin/sh
#
# ~/.vnc/xstartup
# Starts a lightweight XFCE4 session under TigerVNC.

# Load ~/.Xresources if it exists (optional)
[ -r "$HOME/.Xresources" ] && xrdb "$HOME/.Xresources"

# Enable clipboard integration between VNC and local (optional)
vncconfig -iconic &

# Start the XFCE4 desktop. 'exec' ensures XFCE runs in foreground,
# so the VNC session does not exit immediately.
exec startxfce4
EOF

  chmod +x "${XSTARTUP_FILE}"
  chown "${user}:${user}" "${XSTARTUP_FILE}"
  echo "    • Wrote and made executable: ${XSTARTUP_FILE}"

  echo "    ✅ ${user} is now VNC-ready."
  echo
done

echo "========================================"
echo " All ${NUM_USERS} users have been configured for VNC."
echo
echo " Each user can now log in (SSH) and run:"
echo "   vncserver :<display_number>"
echo " For example:"
echo "   su - ahead_user00"
echo "   vncserver :1"
echo
echo " Then connect your VNC viewer to <server_IP>:5901 (if :1)."
echo " The password for all users (by default) is 'workshop'."
echo
echo " Inside the VNC XFCE desktop, you can open a terminal (Menu → Accessories → Terminal)"
echo " or run: firefox &"
echo
echo " Script complete."
echo "========================================"