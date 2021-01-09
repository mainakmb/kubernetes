#!/bin/bash

# Enable ssh password authentication
echo "[TASK 1] Enable SSH password authentication"
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl reload sshd

# Set root password
echo "[TASK 2] Set root password"
echo -e "superuser\nsuperuser" | passwd root >/dev/null 2>&1
