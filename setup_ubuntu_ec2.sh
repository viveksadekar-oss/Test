#!/usr/bin/env bash
# Instructor preparation for a NEW dedicated AWS Ubuntu training VM.
# Review before executing. Not for production servers.
set -euo pipefail

if ! command -v apt-get >/dev/null 2>&1; then
  echo 'This script requires Ubuntu/Debian with apt-get.' >&2
  exit 1
fi

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  git python3 zip unzip curl wget ca-certificates fontconfig nginx openjdk-21-jre
sudo install -d -m 755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
printf '%s\n' \
  'deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/' \
  | sudo tee /etc/apt/sources.list.d/jenkins.list >/dev/null
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y jenkins
sudo systemctl daemon-reload
sudo systemctl enable --now jenkins
sudo systemctl enable --now nginx
sudo install -d -o jenkins -g jenkins -m 755 /var/www/html/devops-demo

echo 'Services:'
sudo systemctl --no-pager --full status jenkins nginx | head -40 || true
echo 'Jenkins initial admin password (handle securely):'
echo '  sudo cat /var/lib/jenkins/secrets/initialAdminPassword'
echo 'Deployment path: /var/www/html/devops-demo'
