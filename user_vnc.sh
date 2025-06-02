#!/bin/bash

START=0
END=19
PASSWORD="AHEADworkshop"

for i in $(seq -f "%02g" $START $END); do
    username="ahead_user$i"
    user_home="/home/$username"
    vnc_dir="$user_home/.vnc"
    xstartup="$vnc_dir/xstartup"

    echo "Setting up VNC for $username"

    # Create .vnc directory if not present
    sudo -u $username mkdir -p $vnc_dir

    # Set VNC password
    echo "$PASSWORD" | vncpasswd -f | sudo tee "$vnc_dir/passwd" > /dev/null
    sudo chown $username:$username "$vnc_dir/passwd"
    sudo chmod 600 "$vnc_dir/passwd"

    # Create custom xstartup script
    sudo tee "$xstartup" > /dev/null << EOF
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=XFCE
export XDG_RUNTIME_DIR=/tmp/runtime-\$USER

# Optional: kill locker if it spawns
(sleep 5 && pkill -9 light-locker) &

# Start XFCE session
startxfce4 &
EOF

    # Fix permissions
    sudo chown $username:$username "$xstartup"
    sudo chmod +x "$xstartup"

    # Ensure .Xauthority exists to prevent auth issues
    sudo -u $username touch "$user_home/.Xauthority"
    sudo chown $username:$username "$user_home/.Xauthority"
done