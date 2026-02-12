#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "[1/5] Installing wget and curl with apt..."
apt update -y
apt install -y wget curl unzip

echo "[2/5] Fetching latest pacman bootstrap release URL..."
BOOTSTRAP_URL=$(curl -s https://api.github.com/repos/termux-pacman/termux-packages/releases/latest \
  | grep browser_download_url \
  | grep bootstrap-aarch64.zip \
  | cut -d '"' -f 4)

if [ -z "$BOOTSTRAP_URL" ]; then
  echo "Failed to fetch latest bootstrap URL."
  exit 1
fi

echo "Latest bootstrap found:"
echo "$BOOTSTRAP_URL"

echo "[3/5] Downloading bootstrap..."
wget -O bootstrap-aarch64.zip "$BOOTSTRAP_URL"

PREFIX_DIR="$(dirname "$PREFIX")"
USR_DIR="$PREFIX"
USR_N_DIR="$PREFIX_DIR/usr-n"

echo "[4/5] Creating usr-n directory..."
mkdir -p "$USR_N_DIR"

echo "Moving archive to usr-n..."
mv bootstrap-aarch64.zip "$USR_N_DIR/"

cd "$USR_N_DIR"

echo "Unzipping bootstrap..."
unzip -o bootstrap-aarch64.zip

echo "[5/5] Creating symbolic links..."
cat SYMLINKS.txt | awk -F "←" '{system("ln -s '\''"$1"'\'' '\''"$2"'\''")}'

echo "Bootstrap installation complete."

