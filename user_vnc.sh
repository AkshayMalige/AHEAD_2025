#!/bin/bash

START=0
END=19
PASSWORD="AHEADworkshop"

# Ensure XFCE is installed
sudo apt-get update
sudo apt-get install -y xfce4 xfce4-goodies

for i in $(seq -f "%02g" $START $END); do
    username="ahead_user$i"
    user_home="/home/$username"
    vnc_dir="$user_home/.vnc"
    xstartup="$vnc_dir/xstartup"

    echo "Setting up VNC for $username"

    # Skip nonexistent users
    if ! id "$username" &>/dev/null; then
        echo "User $username does not exist. Skipping..."
        continue
    fi

    # Create .vnc directory
    sudo -u $username mkdir -p "$vnc_dir"

    # Set VNC password
    echo "$PASSWORD" | vncpasswd -f | sudo tee "$vnc_dir/passwd" > /dev/null
    sudo chown $username:$username "$vnc_dir/passwd"
    sudo chmod 600 "$vnc_dir/passwd"

    # Create working xstartup for XFCE
    sudo tee "$xstartup" > /dev/null << 'EOF'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=XFCE

xrdb $HOME/.Xresources
startxfce4 &
EOF

    sudo chown $username:$username "$xstartup"
    sudo chmod +x "$xstartup"

    # Touch .Xauthority to avoid permission errors
    sudo -u $username touch "$user_home/.Xauthority"
    sudo chown $username:$username "$user_home/.Xauthority"
    sudo chmod 600 "$user_home/.Xauthority"

done