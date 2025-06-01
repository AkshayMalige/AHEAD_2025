#!/bin/bash

NUM_USERS=15

for i in $(seq -w 0 $((NUM_USERS - 1))); do
    username="ahead_user$i"
    echo "Deleting user: $username"
    sudo userdel -r "$username"
done
