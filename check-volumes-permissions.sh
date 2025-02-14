#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root or with sufficient privileges."
    exit 1
fi

# List of directories to check
DIRS=("data" "data/database" "data/logs" "data/certificates" "secrets")
USER_ID=1000

for DIR in "${DIRS[@]}"; do
    # Check if the directory exists
    if [[ -d "$DIR" ]]; then
        echo "Directory '$DIR' exists."
    else
        echo "Directory '$DIR' does not exist. Creating it..."
        mkdir -p "$DIR"
        if [[ $? -ne 0 ]]; then
            echo "Failed to create directory '$DIR'."
            exit 1
        fi
        echo "Directory '$DIR' created successfully."
    fi

    # Check ownership and permissions
    DIR_OWNER_UID=$(stat -c '%u' "$DIR")
    DIR_PERMS=$(stat -c '%a' "$DIR")

    if [[ "$DIR_OWNER_UID" -ne "$USER_ID" || "$DIR_PERMS" -ne 777 ]]; then
        echo "Setting ownership and permissions for '$DIR'..."
        chown -R "$USER_ID" "$DIR"
        if [[ ! $? -eq 0 ]]; then
            echo "Failed to update ownership for '$DIR'."
            exit 1
        fi

        chmod 777 "$DIR"
        if [[ $? -eq 0 ]]; then
            echo "Ownership and permissions updated: User with UID $USER_ID now has full permissions on '$DIR'."
        else
            echo "Failed to update permissions for '$DIR'."
            exit 1
        fi
    else
        echo "User with UID $USER_ID already has correct permissions on '$DIR'."
    fi
done