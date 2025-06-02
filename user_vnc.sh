#!/bin/bash
#
# user_vnc.sh
#
# For each ahead_userXX (00…19), this script:
#   • Creates ~/.vnc directory (mode 700)
#   • Writes a VNC password (default = "workshop") into ~/.vnc/passwd
#   • Creates ~/.vnc/xstartup with "export XAUTHORITY=…; exec startxfce4"
#
# Run this script ONCE as root (or via sudo), **after** you have run user_create.sh.

set -euo pipefail

NUM_USERS=20
USER_PREFIX="ahead_user"

# 1) Ensure the script is run as root
if [[ "$(id -u)" -ne 0 ]]; then
  echo "ERROR: This script must be run as root (sudo)." >&2
  exit 1
fi

echo
echo "============================================"
echo "  STEP 3: Configure VNC for each user"
echo "============================================"
echo

for i in $(seq -w 0 $((NUM_USERS - 1))); do
  user="${USER_PREFIX}${i}"
  home="/home/${user}"
  VNC_DIR="${home}/.vnc"

  echo "--------------------------------------------"
  echo "Setting up VNC for: ${user}"
  echo "--------------------------------------------"

  # 3a) Make sure the user’s home exists
  if [[ ! -d "${home}" ]]; then
    echo "  ERROR: Home directory ${home} not found. Did you run user_create.sh?" >&2
    exit 1
  fi

  # 3b) Create ~/.vnc (mode 700, owned by user)
  mkdir -p "${VNC_DIR}"
  chown "${user}:${user}" "${VNC_DIR}"
  chmod 700                  "${VNC_DIR}"
  echo "  • Created ${VNC_DIR} (owned by ${user}, mode 700)."

  # 3c) Create (or overwrite) ~/.vnc/passwd (default = "workshop")
  echo "workshop" | sudo -u "${user}" vncpasswd -f > "${VNC_DIR}/passwd"
  chmod 600 "${VNC_DIR}/passwd"
  chown "${user}:${user}" "${VNC_DIR}/passwd"
  echo "  • Wrote VNC password file at ${VNC_DIR}/passwd (password = 'workshop')."

  # 3d) Create ~/.vnc/xstartup
  cat << 'EOF' > "${VNC_DIR}/xstartup"
#!/bin/sh
#
# ~/.vnc/xstartup
# Starts a minimal XFCE desktop under TigerVNC.
#
# 1) Export XAUTHORITY so X11 apps can find ~/.Xauthority automatically.
# 2) Load ~/.Xresources if it exists (optional).
# 3) Run vncconfig (clipboard support, optional).
# 4) exec startxfce4 → keeps XFCE in the foreground so VNC session does not exit.

# 1) Point to the user’s Xauthority file
export XAUTHORITY="$HOME/.Xauthority"

# 2) Load any X resources (optional, no harm if file doesn’t exist)
[ -r "$HOME/.Xresources" ] && xrdb "$HOME/.Xresources"

# 3) Clipboard integration (optional; comment out if not needed)
vncconfig -iconic &

# 4) Start XFCE. 'exec' makes XFCE the top-level process, so VNC stays alive.
exec startxfce4
EOF

  chmod +x "${VNC_DIR}/xstartup"
  chown "${user}:${user}" "${VNC_DIR}/xstartup"
  echo "  • Created and made executable: ${VNC_DIR}/xstartup"

  echo "  ✅ ${user} is VNC-ready."
  echo
done

echo "============================================"
echo "All ${NUM_USERS} users can now run:  vncserver :<display_number>"
echo "Example (as ahead_user00):"
echo "  su - ahead_user00"
echo "  vncserver :1      # → port 5901"
echo
echo "Then connect your VNC viewer to <server_IP>:5901, password = 'workshop' (unless changed)."
echo "Inside XFCE, you can open Terminal (Menu → Accessories → Terminal) or:"
echo "  firefox &"
echo "============================================"