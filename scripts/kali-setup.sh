#!/usr/bin/env bash
# ============================================================
#  SOCIAL ENGINEERING LAB - ONE-SHOT SETUP (Kali Linux)
#  For classroom demonstration only: isolated VM, demo accounts.
#  Installs the OSINT + phishing-simulation stack and verifies
#  every tool at the end. Run as your normal user; sudo is used
#  where needed.
# ============================================================
set -u
LAB="$HOME/se-lab"
mkdir -p "$LAB"/{osint,phishing}
PASS=0; FAIL=0
ok()   { echo "  [OK]   $1"; PASS=$((PASS+1)); }
bad()  { echo "  [FAIL] $1"; FAIL=$((FAIL+1)); }
have() { command -v "$1" >/dev/null 2>&1; }

echo "==> Updating package lists"
sudo apt-get update -qq

echo "==> Base packages"
sudo apt-get install -y -qq git curl wget unzip python3 python3-pip python3-venv pipx golang-go php-cli openssh-client > /dev/null 2>&1

# ------------------------------------------------------------
echo "==> OSINT stack"
# Sherlock: username search across 400+ sites (incl. TikTok, Instagram)
sudo apt-get install -y -qq sherlock > /dev/null 2>&1 || pipx install sherlock-project 2>/dev/null || pip3 install --user sherlock-project
# Maigret: username search across 3000+ sites with deep reports
sudo apt-get install -y -qq maigret > /dev/null 2>&1 || pipx install maigret 2>/dev/null || pip3 install --user maigret
# theHarvester: emails, subdomains, hosts from public sources
sudo apt-get install -y -qq theharvester > /dev/null 2>&1 || pipx install theHarvester 2>/dev/null || pip3 install --user theHarvester
# Holehe: check if an email is registered on 120+ sites
pipx install holehe 2>/dev/null || pip3 install --user holehe

# ------------------------------------------------------------
echo "==> Phishing simulation stack"
# Gophish: professional phishing simulation platform (web UI on :3333)
if ! have gophish; then
  cd "$LAB/phishing"
  curl -sL -o gophish.zip https://github.com/gophish/gophish/releases/download/v0.12.1/gophish-v0.12.1-linux-64bit.zip
  unzip -o -q gophish.zip -d gophish && chmod +x gophish/gophish && rm gophish.zip
fi
# SET: Social-Engineer Toolkit (ships as a standard Kali package)
sudo apt-get install -y -qq set > /dev/null 2>&1
# Evilginx: adversary-in-the-middle framework (MFA bypass demos)
if ! have evilginx; then
  cd "$LAB/phishing"
  curl -sL -o evilginx.zip https://github.com/kgretzky/evilginx2/releases/download/v3.3.0/evilginx-v3.3.0-linux-64bit.zip
  unzip -o -q evilginx.zip -d evilginx && chmod +x evilginx/evilginx && rm evilginx.zip
fi
# Cloudflared: tunnel used to expose demo pages (also abused by real kits)
have cloudflared || {
  curl -sL -o /tmp/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
  chmod +x /tmp/cloudflared && sudo mv /tmp/cloudflared /usr/local/bin/cloudflared; }

# ------------------------------------------------------------
echo ""
echo "==> Verification"
have sherlock    && ok "sherlock"    || bad "sherlock"
have maigret     && ok "maigret"     || bad "maigret"
have theHarvester && ok "theHarvester" || bad "theHarvester"
have holehe      && ok "holehe"      || bad "holehe"
{ have gophish || [ -x "$LAB/phishing/gophish/gophish" ]; } && ok "gophish" || bad "gophish"
have setoolkit   && ok "set (setoolkit)" || bad "set (setoolkit)"
{ have evilginx || [ -x "$LAB/phishing/evilginx/evilginx" ]; } && ok "evilginx" || bad "evilginx"
have cloudflared && ok "cloudflared" || bad "cloudflared"
echo ""
echo "Done: $PASS ok, $FAIL failed. Lab folder: $LAB"
echo "Reminder: host-only / NAT network in VMware, demo accounts only."
