#!/bin/bash

# Range of users to configure (adjust as needed)
START=0
END=14

# VNC password
VNC_PASS="workshop"

for i in $(seq -f "%02g" $START $END); do
    username="ahead_user$i"
    home_dir="/home/$username"

    echo "Setting up VNC for: $username"

    # Skip if user doesn't exist
    if ! id "$username" &>/dev/null; then
        echo "User $username does not exist. Skipping..."
        continue
    fi

    # Ensure .vnc directory exists
    mkdir -p "$home_dir/.vnc"
    chown -R $username:$username "$home_dir/.vnc"

    # Set VNC password
    echo "$VNC_PASS" | vncpasswd -f > "$home_dir/.vnc/passwd"
    chmod 600 "$home_dir/.vnc/passwd"
    chown $username:$username "$home_dir/.vnc/passwd"

    # Ensure .Xauthority exists
    touch "$home_dir/.Xauthority"
    chown $username:$username "$home_dir/.Xauthority"
    chmod 600 "$home_dir/.Xauthority"

    # Create minimal xstartup file
    cat << 'EOF' > "$home_dir/.vnc/xstartup"
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
[ -x /etc/X11/xinit/xinitrc ] && exec /etc/X11/xinit/xinitrc
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
xterm &
EOF

    chmod +x "$home_dir/.vnc/xstartup"
    chown $username:$username "$home_dir/.vnc/xstartup"

    echo "✔ VNC configured for $username"
done
