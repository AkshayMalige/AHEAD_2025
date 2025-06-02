#!/bin/bash
#
# user_vnc.sh
#   Set up a VNC password + minimal XFCE session for ahead_user00…ahead_user19,
#   WITHOUT creating any ~/.Xresources file.  Fixes the “invalid preprocessing directive”
#   error and keeps the VNC session alive.
#

START=0
END=19
VNC_PASS="workshop"

# 1) Make sure XFCE is installed system-wide (so each user can run startxfce4)
sudo apt-get update
sudo apt-get install -y xfce4 xfce4-goodies >/dev/null

for i in $(seq -f "%02g" $START $END); do
    username="ahead_user$i"
    home_dir="/home/$username"
    vnc_dir="$home_dir/.vnc"
    xstartup="$vnc_dir/xstartup"

    echo "Configuring VNC for: $username"

    # If the user does not exist, skip
    if ! id "$username" &>/dev/null; then
        echo "  → User $username does not exist; skipping."
        continue
    fi

    # 2) Create ~/.vnc directory
    sudo -u $username mkdir -p "$vnc_dir"
    sudo chown $username:$username "$vnc_dir"

    # 3) Write the VNC password file
    echo "$VNC_PASS" | vncpasswd -f | sudo tee "$vnc_dir/passwd" >/dev/null
    sudo chown $username:$username "$vnc_dir/passwd"
    sudo chmod 600 "$vnc_dir/passwd"

    # 4) Create a minimal ~/.vnc/xstartup that does NOT call xrdb or load ~/.Xresources
    sudo tee "$xstartup" >/dev/null << 'EOF'
#!/bin/sh
#
# Minimal xstartup for XFCE (no Xresources, no lock-screen)
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=XFCE

# Kill any stray light-locker (just in case)
(sleep 5 && pkill -9 light-locker) &

# Launch XFCE
startxfce4 &
EOF

    sudo chown $username:$username "$xstartup"
    sudo chmod +x "$xstartup"

    # 5) Ensure ~/.Xauthority exists (avoid “no authority file” errors)
    sudo -u $username touch "$home_dir/.Xauthority"
    sudo chown $username:$username "$home_dir/.Xauthority"
    sudo chmod 600 "$home_dir/.Xauthority"

    echo "  → Done."
done

echo "All users have been configured. Each user can now run: vncserver :1"