#!/usr/bin/env bash
# ============================================================
#  SE LAB · FULL INSTALLER · 30+ social engineering tools
#  Focus: TikTok · Instagram · Snapchat + the full SE chain
#  Target: WSL with Ubuntu 24.04 (best) or Kali WSL (extras)
#
#  Run:  bash install.sh
#  Re-running is safe: finished steps are skipped or refreshed.
#  Every tool lands in its own venv or folder, so nothing clashes.
#  The final report tells you exactly what works and what did not.
#  Lab use only: your own accounts, isolated practice, class demos.
# ============================================================
set -uo pipefail

LAB="$HOME/se-lab"
BIN="$LAB/bin"
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
PASS=(); FAIL=()
step(){ echo -e "\n${YELLOW}==> $1${NC}"; }
ok(){ PASS+=("$1"); echo -e "${GREEN}  OK: $1${NC}"; }
bad(){ FAIL+=("$1"); echo -e "${RED}  FAILED: $1 (continuing with the rest)${NC}"; }

mkdir -p "$LAB/osint" "$LAB/phishing" "$BIN" "$LAB/scripts" "$LAB/guide" "$LAB/work"

step "Base system packages"
sudo apt-get update -qq
sudo apt-get install -y -qq git curl wget unzip jq nmap python3 python3-venv \
  python3-pip php-cli build-essential libffi-dev libssl-dev pkg-config > /dev/null \
  && ok "base packages (incl. nmap, php-cli)" || bad "base packages"

PYV=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
echo "  Python: $PYV"
python3 -c 'import sys; exit(0 if sys.version_info >= (3,12) else 1)' || \
  echo "  WARNING: theHarvester needs Python 3.12+. Ubuntu 24.04 is the safe choice."

mkvenv(){ [ -d "$1" ] || python3 -m venv "$1"; "$1/bin/pip" install -q --upgrade pip; }

# pip tool:  pypkg <name> <pip-package> <binary-to-test>
pypkg(){
  local name="$1" pkg="$2" binname="${3:-$1}"
  step "$name"
  mkvenv "$LAB/osint/venv-$name"
  if "$LAB/osint/venv-$name/bin/pip" install -q "$pkg" && [ -x "$LAB/osint/venv-$name/bin/$binname" ]; then
    printf '#!/usr/bin/env bash\nexec %s/osint/venv-%s/bin/%s "$@"\n' "$LAB" "$name" "$binname" > "$BIN/$binname"
    chmod +x "$BIN/$binname"; ok "$name"
  else bad "$name"; fi
}

# ---------------- OSINT: pip tools ----------------
pypkg sherlock   sherlock-project sherlock      # username search, 400+ sites (TikTok, IG, Snapchat checks)
pypkg maigret    maigret          maigret       # username search, 3000+ sites + profile reports
pypkg socialscan socialscan       socialscan    # username + email availability, fast API checks
pypkg nexfil     nexfil           nexfil        # username search, 300+ sites, very fast

step "holehe (email account checker)"
mkvenv "$LAB/osint/venv-holehe"
if "$LAB/osint/venv-holehe/bin/pip" install -q holehe; then
  printf '#!/usr/bin/env bash\nexec env -u NO_PROXY -u no_proxy %s/osint/venv-holehe/bin/holehe "$@"\n' "$LAB" > "$BIN/holehe"
  chmod +x "$BIN/holehe"; ok "holehe"
else bad "holehe"; fi

pypkg h8mail     h8mail           h8mail        # breached-email OSINT
pypkg ghunt      ghunt            ghunt         # Google account OSINT (needs one-time: ghunt login)

# ---------------- Instagram / TikTok / media ----------------
pypkg instaloader instaloader     instaloader   # Instagram profiles, posts, stories metadata
pypkg toutatis    toutatis        toutatis      # Instagram info from a username (email/phone hints)
pypkg ignorant    ignorant        ignorant      # check if an email is registered on Instagram etc.
pypkg yt-dlp      yt-dlp          yt-dlp        # TikTok + Instagram media downloader
pypkg gallery-dl  gallery-dl      gallery-dl    # gallery downloader for IG, TikTok and more

step "TikTokApi (Python library for TikTok data)"
mkvenv "$LAB/osint/venv-tiktokapi"
if "$LAB/osint/venv-tiktokapi/bin/pip" install -q TikTokApi && \
   "$LAB/osint/venv-tiktokapi/bin/python" -c "import TikTokApi"; then
  "$LAB/osint/venv-tiktokapi/bin/python" -m playwright install chromium > /dev/null 2>&1 || \
    echo "  Note: run later if needed: ~/se-lab/osint/venv-tiktokapi/bin/python -m playwright install chromium"
  ok "TikTokApi (library, import verified)"
else bad "TikTokApi"; fi

# ---------------- OSINT: source tools ----------------
# git tool with own venv:  gitpkg <name> <repo-url> <dest-dir-under-lab> <main-file>
gitpkg(){
  local name="$1" url="$2" dest="$3" main="$4"
  step "$name"
  [ -d "$LAB/$dest" ] || git clone --depth 1 -q "$url" "$LAB/$dest"
  mkvenv "$LAB/venv-$name"
  [ -f "$LAB/$dest/requirements.txt" ] && "$LAB/venv-$name/bin/pip" install -q -r "$LAB/$dest/requirements.txt"
  if [ -f "$LAB/$dest/$main" ]; then
    printf '#!/usr/bin/env bash\ncd %s/%s && exec %s/venv-%s/bin/python %s "$@"\n' "$LAB" "$dest" "$LAB" "$name" "$main" > "$BIN/$name"
    chmod +x "$BIN/$name"; ok "$name"
  else bad "$name"; fi
}

step "theHarvester 4.11.1 (built from source, PyPI version is a dead stub)"
[ -d "$LAB/osint/theharvester-src" ] || \
  git clone --depth 1 -q --branch 4.11.1 https://github.com/laramies/theHarvester "$LAB/osint/theharvester-src"
mkvenv "$LAB/osint/venv-harvester"
if "$LAB/osint/venv-harvester/bin/pip" install -q "$LAB/osint/theharvester-src" && [ -x "$LAB/osint/venv-harvester/bin/theHarvester" ]; then
  printf '#!/usr/bin/env bash\nexec %s/osint/venv-harvester/bin/theHarvester "$@"\n' "$LAB" > "$BIN/theharvester"
  chmod +x "$BIN/theharvester"; ok "theHarvester"
else bad "theHarvester"; fi

gitpkg blackbird https://github.com/p1ngul1n0/blackbird osint/blackbird blackbird.py   # username + email, 600+ sites
gitpkg osintgram https://github.com/Datalux/Osintgram  osint/osintgram main.py        # Instagram OSINT shell
gitpkg photon    https://github.com/s0md3v/Photon      osint/photon    photon.py      # web OSINT crawler
gitpkg spiderfoot https://github.com/smicallef/spiderfoot osint/spiderfoot sf.py      # OSINT automation (web UI on 127.0.0.1:5001)

# ---------------- Binaries (no compiling) ----------------
step "Gophish v0.12.1 (phishing simulation platform)"
if [ ! -x "$LAB/phishing/gophish/gophish" ]; then
  curl -sL -o /tmp/gophish.zip https://github.com/gophish/gophish/releases/download/v0.12.1/gophish-v0.12.1-linux-64bit.zip
  mkdir -p "$LAB/phishing/gophish"; unzip -o -q /tmp/gophish.zip -d "$LAB/phishing/gophish"
  chmod +x "$LAB/phishing/gophish/gophish"; rm -f /tmp/gophish.zip
fi
printf '#!/usr/bin/env bash\ncd %s/phishing/gophish && exec ./gophish "$@"\n' "$LAB" > "$BIN/gophish"; chmod +x "$BIN/gophish"
[ -x "$LAB/phishing/gophish/gophish" ] && ok "gophish" || bad "gophish"

step "Evilginx v3.3.0 (AiTM proxy, beats OTP codes)"
if [ ! -x "$LAB/phishing/evilginx/evilginx" ]; then
  curl -sL -o /tmp/evilginx.zip https://github.com/kgretzky/evilginx2/releases/download/v3.3.0/evilginx-v3.3.0-linux-64bit.zip
  mkdir -p "$LAB/phishing/evilginx"; unzip -o -q /tmp/evilginx.zip -d "$LAB/phishing/evilginx"
  chmod +x "$LAB/phishing/evilginx/evilginx"; rm -f /tmp/evilginx.zip
fi
printf '#!/usr/bin/env bash\ncd %s/phishing/evilginx && exec ./evilginx "$@"\n' "$LAB" > "$BIN/evilginx"; chmod +x "$BIN/evilginx"
[ -x "$LAB/phishing/evilginx/evilginx" ] && ok "evilginx" || bad "evilginx"

step "PhoneInfoga v2.11.0 (phone number OSINT)"
if [ ! -x "$LAB/osint/phoneinfoga/phoneinfoga" ]; then
  curl -sL -o /tmp/phoneinfoga.tar.gz https://github.com/sundowndev/phoneinfoga/releases/download/v2.11.0/phoneinfoga_Linux_x86_64.tar.gz
  mkdir -p "$LAB/osint/phoneinfoga"; tar --no-same-owner -xzf /tmp/phoneinfoga.tar.gz -C "$LAB/osint/phoneinfoga" 2>/dev/null
  chmod +x "$LAB/osint/phoneinfoga/phoneinfoga" 2>/dev/null; rm -f /tmp/phoneinfoga.tar.gz
fi
printf '#!/usr/bin/env bash\nexec %s/osint/phoneinfoga/phoneinfoga "$@"\n' "$LAB" > "$BIN/phoneinfoga"; chmod +x "$BIN/phoneinfoga"
[ -x "$LAB/osint/phoneinfoga/phoneinfoga" ] && ok "phoneinfoga" || bad "phoneinfoga"

# ---------------- Phishing frameworks + kits ----------------
step "SET · Social-Engineer Toolkit (official archive + own venv)"
if [ ! -d "$LAB/phishing/set" ]; then
  curl -sL -o /tmp/set.tar.gz https://github.com/trustedsec/social-engineer-toolkit/archive/refs/heads/master.tar.gz
  tar xzf /tmp/set.tar.gz -C /tmp && mv /tmp/social-engineer-toolkit-master "$LAB/phishing/set"; rm -f /tmp/set.tar.gz
fi
mkvenv "$LAB/venv-set"
"$LAB/venv-set/bin/pip" install -q -r "$LAB/phishing/set/requirements.txt"
printf '#!/usr/bin/env bash\ncd %s/phishing/set && exec %s/venv-set/bin/python setoolkit "$@"\n' "$LAB" "$LAB" > "$BIN/setoolkit"; chmod +x "$BIN/setoolkit"
[ -f "$LAB/phishing/set/setoolkit" ] && ok "setoolkit" || bad "setoolkit"

clonesh(){ # clonesh <name> <repo-url> <script-file>
  local name="$1" url="$2" script="$3"
  step "$name"
  [ -d "$LAB/phishing/$name" ] || git clone --depth 1 -q "$url" "$LAB/phishing/$name"
  if [ -f "$LAB/phishing/$name/$script" ]; then
    printf '#!/usr/bin/env bash\ncd %s/phishing/%s && exec bash %s "$@"\n' "$LAB" "$name" "$script" > "$BIN/$name"
    chmod +x "$BIN/$name"; ok "$name"
  else bad "$name"; fi
}
clonesh zphisher https://github.com/htr-tech/zphisher zphisher.sh   # clone pages: Instagram, TikTok + 30 more
clonesh camphish https://github.com/techchipnet/CamPhish camphish.sh # camera-access scam pages

step "seeker (precise location via a link)"
[ -d "$LAB/phishing/seeker" ] || git clone --depth 1 -q https://github.com/thewhiteh4t/seeker "$LAB/phishing/seeker"
mkvenv "$LAB/venv-seeker"
[ -f "$LAB/phishing/seeker/requirements.txt" ] && "$LAB/venv-seeker/bin/pip" install -q -r "$LAB/phishing/seeker/requirements.txt"
if [ -f "$LAB/phishing/seeker/seeker.py" ]; then
  printf '#!/usr/bin/env bash\ncd %s/phishing/seeker && exec %s/venv-seeker/bin/python seeker.py "$@"\n' "$LAB" "$LAB" > "$BIN/seeker"
  chmod +x "$BIN/seeker"; ok "seeker"
else bad "seeker"; fi

step "cupp (password profiler: builds wordlists from a person's public info)"
[ -d "$LAB/phishing/cupp" ] || git clone --depth 1 -q https://github.com/Mebus/cupp "$LAB/phishing/cupp"
if [ -f "$LAB/phishing/cupp/cupp.py" ]; then
  printf '#!/usr/bin/env bash\ncd %s/phishing/cupp && exec python3 cupp.py "$@"\n' "$LAB" > "$BIN/cupp"
  chmod +x "$BIN/cupp"; ok "cupp"
else bad "cupp"; fi

step "maskphish (disguises a link behind a trusted-looking URL)"
[ -d "$LAB/phishing/maskphish" ] || git clone --depth 1 -q https://github.com/jaykali/maskphish "$LAB/phishing/maskphish"
if [ -f "$LAB/phishing/maskphish/maskphish.sh" ]; then
  printf '#!/usr/bin/env bash\ncd %s/phishing/maskphish && exec bash maskphish.sh "$@"\n' "$LAB" > "$BIN/maskphish"
  chmod +x "$BIN/maskphish"; ok "maskphish"
else bad "maskphish"; fi

step "Modlishka (optional AiTM proxy, built from source with Go)"
if [ ! -x "$BIN/modlishka" ]; then
  sudo apt-get install -y -qq golang-go > /dev/null 2>&1
  [ -d /tmp/modlishka-src ] || git clone --depth 1 -q https://github.com/drk1wi/Modlishka /tmp/modlishka-src
  (cd /tmp/modlishka-src && go build -o "$BIN/modlishka" . > /dev/null 2>&1)
fi
[ -x "$BIN/modlishka" ] && ok "modlishka (optional)" || echo "  SKIPPED: modlishka build did not complete (optional, Evilginx already covers AiTM)"

# ---------------- Kali WSL extras ----------------
if grep -qi kali /etc/os-release 2>/dev/null; then
  step "Kali extras (recon-ng, beef-xss)"
  sudo apt-get install -y -qq recon-ng beef-xss > /dev/null 2>&1 && ok "recon-ng + beef-xss (Kali)" || bad "Kali extras"
  echo "  Optional heavyweight: sudo apt install metasploit-framework"
fi

grep -q 'se-lab/bin' "$HOME/.bashrc" 2>/dev/null || echo 'export PATH="$HOME/se-lab/bin:$PATH"' >> "$HOME/.bashrc"
export PATH="$BIN:$PATH"

# ---------------- Final report ----------------
echo -e "\n============================================================"
echo -e "${GREEN}SE LAB INSTALL REPORT${NC}"
echo "============================================================"
echo "Tools ready (${#PASS[@]}):"
for t in "${PASS[@]}"; do echo "  ✓ $t"; done
if [ ${#FAIL[@]} -gt 0 ]; then
  echo -e "${RED}Needs attention (${#FAIL[@]}):${NC}"
  for t in "${FAIL[@]}"; do echo "  ✗ $t"; done
  echo "Re-run the script to retry only the missing pieces."
fi
echo
echo "Launchers live in $BIN (open a new terminal, or: source ~/.bashrc)"
echo
echo "First moves:"
echo "  sherlock --site Instagram --site TikTok YOUR_DEMO_HANDLE"
echo "  maigret YOUR_DEMO_HANDLE"
echo "  holehe your@demo-mail.com"
echo "  zphisher            # pick 02 Instagram or 10 TikTok, localhost tunnel"
echo "  gophish             # then open https://localhost:3333 (admin password in terminal)"
echo "  evilginx            # the AiTM boss level, see the guides"
echo "  ghunt login         # one-time setup for GHunt"
echo
echo "Guides: ~/se-lab/guide/ after you copy the repo's guide folder, or read them on GitHub."
echo "Lab rules: isolated practice, your own demo accounts, never real people."
