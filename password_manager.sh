#!/bin/bash

# Basic Bash Password Manager with Change Master Password
# Uses AES-256 encryption with OpenSSL
# Educational project

VAULT_PLAIN="vault.txt"
VAULT_ENC="vault.enc"
MASTER_HASH=".master.hash"
MAX_TRIES=3

# Function to hash passwords
hash_password() {
    echo -n "$1" | sha256sum | awk '{print $1}'
}

# Function to encrypt the vault
encrypt_vault() {
    openssl enc -aes-256-cbc -salt -pbkdf2 \
        -in "$VAULT_PLAIN" -out "$VAULT_ENC" \
        -pass pass:"$1"
    rm -f "$VAULT_PLAIN"
}

# Function to decrypt the vault
decrypt_vault() {
    openssl enc -aes-256-cbc -d -pbkdf2 \
        -in "$VAULT_ENC" -out "$VAULT_PLAIN" \
        -pass pass:"$1"
}

# ---------- First-time master password setup ----------
if [ ! -f "$MASTER_HASH" ]; then
    echo "First-time setup"
    read -s -p "Create master password: " MP1
    echo
    read -s -p "Confirm master password: " MP2
    echo

    if [ "$MP1" != "$MP2" ]; then
        echo "Passwords do not match"
        exit 1
    fi

    hash_password "$MP1" > "$MASTER_HASH"
    echo "Master password created"
fi

# ---------- Login with limited attempts ----------
TRIES=0
while [ $TRIES -lt $MAX_TRIES ]; do
    read -s -p "Enter master password: " INPUT
    echo

    if [ "$(hash_password "$INPUT")" = "$(cat "$MASTER_HASH")" ]; then
        MASTER_PASS="$INPUT"
        break
    else
        echo "Incorrect password"
        ((TRIES++))
    fi
done

if [ $TRIES -eq $MAX_TRIES ]; then
    echo "Invalid attempts. Access denied."
    exit 1
fi

# ---------- Decrypt or create vault ----------
if [ -f "$VAULT_ENC" ]; then
    decrypt_vault "$MASTER_PASS" || exit 1
else
    touch "$VAULT_PLAIN"
fi

# ---------- Menu ----------
while true; do
    echo
    echo "1. Add password"
    echo "2. View passwords"
    echo "3. Change master password"
    echo "4. Exit"
    read -p "Select option: " CHOICE

    case $CHOICE in
        1)
            read -p "Service: " SERVICE
            read -p "Username: " USERNAME
            read -s -p "Password: " PASSWORD
            echo
            echo "$SERVICE | $USERNAME | $PASSWORD" >> "$VAULT_PLAIN"
            ;;
        2)
            cat "$VAULT_PLAIN"
            ;;
        3)
            # Change master password
            read -s -p "Enter current master password: " OLD
            echo
            if [ "$(hash_password "$OLD")" != "$(cat "$MASTER_HASH")" ]; then
                echo "Incorrect current password"
            else
                read -s -p "Enter new master password: " NEW1
                echo
                read -s -p "Confirm new master password: " NEW2
                echo
                if [ "$NEW1" != "$NEW2" ]; then
                    echo "Passwords do not match"
                else
                    hash_password "$NEW1" > "$MASTER_HASH"
                    MASTER_PASS="$NEW1"
                    echo "Master password updated"
                fi
            fi
            ;;
        4)
            encrypt_vault "$MASTER_PASS"
            exit 0
            ;;
        *)
            echo "Invalid option"
            ;;
    esac
done
