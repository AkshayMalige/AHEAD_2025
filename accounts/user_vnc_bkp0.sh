#!/bin/bash

NUM_USERS=15

for i in $(seq -w 0 $((NUM_USERS - 1))); do
    username="ahead_user$i"
    echo "Setting up VNC password for: $username"

    # Generate VNC password file with 'AHEADworkshop' as password
    sudo mkdir -p /home/$username/.vnc
    echo "AHEADworkshop" | vncpasswd -f | sudo tee /home/$username/.vnc/passwd > /dev/null
    sudo chmod 600 /home/$username/.vnc/passwd
    sudo chown $username:$username /home/$username/.vnc/passwd
done
