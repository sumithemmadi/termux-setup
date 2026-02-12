# Termux Setup

This repo helps you set up Termux with custom configurations.

## Steps

### 1. Set pacman Bootstrap Script

```bash
curl -sSL https://raw.githubusercontent.com/sumithemmadi/termux-setup/main/setup_bootstrap.sh | bash
exit
```

### 2. Replace `usr/` with `usr-n/`

1. Enter failsafe mode (instructions below).
2. Run these commands:

```bash
cd ..
rm -fr usr/
mv usr-n/ usr/
exit
```

### 3. Set up Pacman (Optional)

If you're switching to Pacman:

```bash
pacman-key --init
pacman-key --populate
```

### 4. Setup Zsh

```bash
curl https://raw.githubusercontent.com/sumithemmadi/termux-setup/main/setup_zsh.sh | bash
exit
```

Use `sudo zsh` every time you access root if you want to use Zsh in the root shell.

