# bash_password_manager_26
A basic Bash password manager master password and AES encryption.


This is a beginner-friendly password manager written in Bash for Linux (Works on Ubuntu, Debian, Fedora, Arch, Manjaro, etc.).  
It uses a master password, stores credentials in an encrypted file (AES-256), and allows up to 3 login attempts.  
Designed for learning Bash scripting, file handling, and basic encryption.


## Features
- Master password authentication
- Maximum of **3 login attempts**
- Password storage using **AES-256 encryption**
- Uses OpenSSL for encryption and decryption
- Plaintext file is removed after encryption

## Tools Used
- Bash scripting
- OpenSSL (AES-256-CBC)
- SHA-256 hashing
- Kali Linux

## How It Works
1. User creates a master password on first run
2. Master password is stored as a SHA-256 hash
3. Passwords are stored temporarily in a text file
4. File is encrypted using AES before exit
5. After 3 failed login attempts, the program terminates

## Disclaimer
This project is for educational purposes only.
