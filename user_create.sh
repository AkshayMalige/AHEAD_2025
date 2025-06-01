#!/bin/bash

NUM_USERS=15
PASSWORD="AHEADworkshop"

for i in $(seq -w 0 $((NUM_USERS - 1))); do
    username="ahead_user$i"
    echo "Creating or updating user: $username"

    # Create the user with /bin/bash as the login shell if it doesn't exist
    if id "$username" &>/dev/null; then
        echo "User $username already exists. Updating shell to /bin/bash..."
        sudo chsh -s /bin/bash "$username"
    else
        sudo useradd -m -s /bin/bash "$username"
    fi

    echo "$username:$PASSWORD" | sudo chpasswd

    # Setup basic VNC environment and login shell config
    sudo -u "$username" bash -c '
        mkdir -p ~/.vnc

        # Minimal Xresources (optional but removes warning)
        echo "# Xresources" > ~/.Xresources

        # Set up the VNC xstartup script
        cat <<EOF > ~/.vnc/xstartup
#!/bin/sh
xrdb \$HOME/.Xresources
xsetroot -solid grey
x-terminal-emulator &
exec /usr/bin/startxfce4
EOF

        chmod +x ~/.vnc/xstartup
    '
done

echo "✅ All users created/updated successfully."
