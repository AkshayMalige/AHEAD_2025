#!/bin/bash
#
# user_vnc.sh
#
# This script configures 20 “ahead_userXX” accounts (ahead_user00 … ahead_user19)
# for TigerVNC, sets up a minimal XFCE desktop environment for each user, and ensures
# that ~/.Xauthority and ~/.vnc/xstartup are created correctly so that terminals
# and GUI apps (e.g., Firefox) will launch without “.Xauthority does not exist” errors.
#
# Run this script **once** as root (or via sudo) on your Ubuntu machine.

set -e

NUM_USERS=20
USER_PREFIX="ahead_user"

# 0) Ensure the script is run as root
if [[ "$(id -u)" -ne 0 ]]; then
  echo "ERROR: This script must be run as root."
  exit 1
fi

# 1) Install system‐wide prerequisites if missing
echo "==> Installing required packages (xauth, XFCE4, TigerVNC) …"
apt-get update

# Install xauth (so ~/.Xauthority can be created)
if ! dpkg -l | grep -qw xauth; then
  apt-get install -y xauth
fi

# Install XFCE4 desktop (lightweight)
if ! dpkg -l | grep -qw xfce4; then
  apt-get install -y xfce4 xfce4-goodies
fi

# Install TigerVNC server & common files
if ! dpkg -l | grep -qw tigervnc-standalone-server; then
  apt-get install -y tigervnc-standalone-server tigervnc-common
fi

echo "==> Packages installed."

# 2) Loop over each user index (00…19)
for i in $(seq -w 0 $((NUM_USERS-1))); do
  user="${USER_PREFIX}${i}"
  home_dir="/home/${user}"

  echo "-------------------------------"
  echo "Configuring VNC for user: ${user}"

  # 2a) If the user account does not exist, create it with a home directory
  if ! id "${user}" &>/dev/null; then
    echo "  • Creating user ${user} …"
    useradd -m -s /bin/bash "${user}"
    # Optionally, you can set an initial password. Here we leave it locked.
    passwd -l "${user}"
  else
    echo "  • User ${user} already exists."
    # Ensure their home directory still exists
    if [[ ! -d "${home_dir}" ]]; then
      echo "    ⚠️  Home directory ${home_dir} is missing. Recreating…"
      mkdir -p "${home_dir}"
      chown "${user}:${user}" "${home_dir}"
    fi
  fi

  # 2b) Ensure the home directory is owned by the user
  chown "${user}:${user}" "${home_dir}"
  chmod 700 "${home_dir}"

  # 2c) Create ~/.vnc directory
  vnc_dir="${home_dir}/.vnc"
  mkdir -p "${vnc_dir}"
  chown "${user}:${user}" "${vnc_dir}"
  chmod 700 "${vnc_dir}"
  echo "  • Created ${vnc_dir}"

  # 2d) Create (or overwrite) the VNC password file (~/.vnc/passwd)
  #     Here we set a default VNC password “workshop”. Users can change it later.
  echo "workshop" | sudo -u "${user}" vncpasswd -f > "${vnc_dir}/passwd"
  chmod 600 "${vnc_dir}/passwd"
  chown "${user}:${user}" "${vnc_dir}/passwd"
  echo "  • Set VNC password file at ${vnc_dir}/passwd (password = “workshop”)"

  # 2e) Write a minimal ~/.vnc/xstartup that starts XFCE correctly
  xstartup_file="${vnc_dir}/xstartup"
  cat << 'EOF' > "${xstartup_file}"
#!/bin/sh
#
# ~/.vnc/xstartup
# Starts a lightweight XFCE4 session for TigerVNC

# Load ~/.Xresources if it exists (optional)
[ -r "$HOME/.Xresources" ] && xrdb "$HOME/.Xresources"

# Enable clipboard integration (optional, can be commented out if not needed)
vncconfig -iconic &

# Start the XFCE4 desktop. Using exec keeps this process as the main one
# so the VNC session does not exit immediately.
exec startxfce4
EOF

  chmod +x "${xstartup_file}"
  chown "${user}:${user}" "${xstartup_file}"
  echo "  • Wrote and made executable: ${xstartup_file}"

  # 2f) Ensure ~/.Xauthority can be created by the user at first VNC launch
  #     (No need to create this file now—xauth will create it automatically
  #      when the user runs vncserver.)
  #     Just make sure the user owns their home dir (done in step 2b).

  echo "  ✅  ${user} is now VNC-ready."
done

echo "==============================="
echo "All ${NUM_USERS} users have been configured for VNC."
echo
echo "Usage (for each user):"
echo "  1) SSH into the server as ahead_userXX."
echo "  2) Run a VNC server instance:
     vncserver :<display_number>
     e.g., vncserver :1"
echo "  3) From your VNC viewer, connect to: <server_IP>:590<display_number>"
echo "     (Password = “workshop” unless changed by the user.)"
echo
echo "Inside the VNC session, you should see an XFCE desktop.  You can then"
echo "open a terminal (Menu → Accessories → Terminal) or run apps like:"
echo "  firefox &"
echo
echo "If you want each user to pick a fixed display number automatically, you can"
echo "modify this script to start vncserver for each user as root, but generally"
echo "it’s better for each user to start their own instance after logging in."
echo
echo "Script complete."