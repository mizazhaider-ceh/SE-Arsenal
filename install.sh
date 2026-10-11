#!/usr/bin/env bash
# ============================================================
#  SE-ARSENAL · installer v1.0.0
#  30+ social engineering tools, one command, zero dependency wars.
#  Focus: TikTok · Instagram · Snapchat + the full SE chain:
#  recon, profiling, phishing infrastructure, AiTM session theft.
#
#  Target: WSL · Ubuntu 24.04 (recommended) or Kali (extra tools)
#  Usage:  bash install.sh [--help]
#  Re-running is safe: completed steps are skipped or refreshed.
#  For authorized security research, red team work and education.
# ============================================================
set -uo pipefail

VERSION="1.0.2"
ARSENAL="$HOME/se-arsenal"
BIN="$ARSENAL/bin"
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'
PASS=(); FAIL=()

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  echo "SE-Arsenal installer v$VERSION"
  echo "Installs 30+ social engineering tools into $ARSENAL"
  echo "Usage: bash install.sh    (safe to re-run; finishes with a full status report)"
  exit 0
fi

echo -e "${CYAN}SE-ARSENAL v$VERSION${NC} · social engineering arsenal installer"
echo "Target: $ARSENAL"

step(){ echo -e "\n${YELLOW}==> $1${NC}"; }
ok(){ PASS+=("$1"); echo -e "${GREEN}  OK: $1${NC}"; }
bad(){ FAIL+=("$1"); echo -e "${RED}  FAILED: $1 (continuing with the rest)${NC}"; }

mkdir -p "$ARSENAL/osint" "$ARSENAL/phishing" "$BIN" "$ARSENAL/work"

step "Base system packages"
sudo apt-get update -qq
sudo apt-get install -y -qq git curl wget unzip jq nmap python3 python3-venv \
  python3-pip php-cli build-essential libffi-dev libssl-dev pkg-config > /dev/null \
  && ok "base packages (incl. nmap, php-cli)" || bad "base packages"

PYV=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
echo "  Python: $PYV"
python3 -c 'import sys; exit(0 if sys.version_info >= (3,12) else 1)' || \
  echo "  WARNING: theHarvester needs Python 3.12+. Ubuntu 24.04 is the safe choice."

mkvenv(){ [ -d "$1" ] || python3 -m venv "$1"; "$1/bin/pip" install -q --prefer-binary --upgrade pip; }

# pip tool:  pypkg <name> <pip-package> <binary>
pypkg(){
  local name="$1" pkg="$2" binname="${3:-$1}"
  step "$name"
  mkvenv "$ARSENAL/osint/venv-$name"
  if "$ARSENAL/osint/venv-$name/bin/pip" install -q --prefer-binary "$pkg" && [ -x "$ARSENAL/osint/venv-$name/bin/$binname" ]; then
    printf '#!/usr/bin/env bash\nexec %s/osint/venv-%s/bin/%s "$@"\n' "$ARSENAL" "$name" "$binname" > "$BIN/$binname"
    chmod +x "$BIN/$binname"; ok "$name"
  else bad "$name"; fi
}

# ---------------- Recon: usernames and emails ----------------
pypkg sherlock   sherlock-project sherlock      # username search, 400+ sites (TikTok, IG, Snapchat checks)
pypkg maigret    maigret          maigret       # username search, 3000+ sites + extracted profile reports
pypkg socialscan socialscan       socialscan    # username + email availability, fast API checks
pypkg nexfil     nexfil           nexfil        # username search, 300+ sites, very fast

step "holehe (email account checker)"
mkvenv "$ARSENAL/osint/venv-holehe"
if "$ARSENAL/osint/venv-holehe/bin/pip" install -q --prefer-binary holehe; then
  printf '#!/usr/bin/env bash\nexec env -u NO_PROXY -u no_proxy %s/osint/venv-holehe/bin/holehe "$@"\n' "$ARSENAL" > "$BIN/holehe"
  chmod +x "$BIN/holehe"; ok "holehe"
else bad "holehe"; fi

pypkg h8mail     h8mail           h8mail        # breached-email OSINT
step "ghunt (Google account OSINT, one-time setup afterwards: ghunt login)"
# GHunt pins Pillow <11. Pillow 10.x ships no wheels for Python 3.13+ and its
# C code cannot build there, so on modern Pythons GHunt gets a dedicated
# Python 3.12 environment, fetched by uv. On Python 3.12 systems it installs
# the normal way.
GV="$ARSENAL/osint/venv-ghunt"
if python3 -c 'import sys; exit(0 if sys.version_info >= (3,13) else 1)'; then
  export PATH="$HOME/.local/bin:$PATH"
  command -v uv > /dev/null 2>&1 || curl -sSf https://astral.sh/uv/install.sh | sh > /dev/null 2>&1
  rm -rf "$GV"
  if command -v uv > /dev/null 2>&1 && uv venv --python 3.12 "$GV" > /dev/null 2>&1 && \
     uv pip install -q --python "$GV/bin/python" ghunt && [ -x "$GV/bin/ghunt" ]; then
    printf '#!/usr/bin/env bash\nexec %s/osint/venv-ghunt/bin/ghunt "$@"\n' "$ARSENAL" > "$BIN/ghunt"
    chmod +x "$BIN/ghunt"; ok "ghunt (dedicated Python 3.12 env)"
  else bad "ghunt"; fi
else
  mkvenv "$GV"
  if "$GV/bin/pip" install -q --prefer-binary ghunt && [ -x "$GV/bin/ghunt" ]; then
    printf '#!/usr/bin/env bash\nexec %s/osint/venv-ghunt/bin/ghunt "$@"\n' "$ARSENAL" > "$BIN/ghunt"
    chmod +x "$BIN/ghunt"; ok "ghunt"
  else bad "ghunt"; fi
fi

# ---------------- Instagram, TikTok, media ----------------
pypkg instaloader instaloader     instaloader   # Instagram profiles, posts, stories metadata
pypkg toutatis    toutatis        toutatis      # Instagram account info from a username
pypkg ignorant    ignorant        ignorant      # is this email registered on Instagram and more
pypkg yt-dlp      yt-dlp          yt-dlp        # TikTok + Instagram media downloader
pypkg gallery-dl  gallery-dl      gallery-dl    # gallery downloader for IG, TikTok and more

step "TikTokApi (Python library for TikTok data)"
mkvenv "$ARSENAL/osint/venv-tiktokapi"
if "$ARSENAL/osint/venv-tiktokapi/bin/pip" install -q --prefer-binary TikTokApi && \
   "$ARSENAL/osint/venv-tiktokapi/bin/python" -c "import TikTokApi"; then
  "$ARSENAL/osint/venv-tiktokapi/bin/python" -m playwright install chromium > /dev/null 2>&1 || \
    echo "  Note: if needed later: ~/se-arsenal/osint/venv-tiktokapi/bin/python -m playwright install chromium"
  ok "TikTokApi (library, import verified)"
else bad "TikTokApi"; fi

# ---------------- Recon: source-built tools ----------------
gitpkg(){ # gitpkg <name> <repo-url> <dest-under-arsenal> <main-file>
  local name="$1" url="$2" dest="$3" main="$4"
  step "$name"
  [ -d "$ARSENAL/$dest" ] || git clone --depth 1 -q "$url" "$ARSENAL/$dest"
  mkvenv "$ARSENAL/venv-$name"
  [ -f "$ARSENAL/$dest/requirements.txt" ] && "$ARSENAL/venv-$name/bin/pip" install -q --prefer-binary -r "$ARSENAL/$dest/requirements.txt"
  if [ -f "$ARSENAL/$dest/$main" ]; then
    printf '#!/usr/bin/env bash\ncd %s/%s && exec %s/venv-%s/bin/python %s "$@"\n' "$ARSENAL" "$dest" "$ARSENAL" "$name" "$main" > "$BIN/$name"
    chmod +x "$BIN/$name"; ok "$name"
  else bad "$name"; fi
}

step "theHarvester 4.11.1 (source build; the PyPI package is a dead stub)"
[ -d "$ARSENAL/osint/theharvester-src" ] || \
  git clone --depth 1 -q --branch 4.11.1 https://github.com/laramies/theHarvester "$ARSENAL/osint/theharvester-src"
mkvenv "$ARSENAL/osint/venv-harvester"
if "$ARSENAL/osint/venv-harvester/bin/pip" install -q --prefer-binary "$ARSENAL/osint/theharvester-src" && [ -x "$ARSENAL/osint/venv-harvester/bin/theHarvester" ]; then
  printf '#!/usr/bin/env bash\nexec %s/osint/venv-harvester/bin/theHarvester "$@"\n' "$ARSENAL" > "$BIN/theharvester"
  chmod +x "$BIN/theharvester"; ok "theHarvester"
else bad "theHarvester"; fi

gitpkg blackbird https://github.com/p1ngul1n0/blackbird osint/blackbird blackbird.py     # username + email, 600+ sites
gitpkg osintgram https://github.com/Datalux/Osintgram  osint/osintgram main.py          # Instagram OSINT shell
gitpkg photon    https://github.com/s0md3v/Photon      osint/photon    photon.py        # web OSINT crawler
gitpkg spiderfoot https://github.com/smicallef/spiderfoot osint/spiderfoot sf.py       # OSINT automation, web UI on 127.0.0.1:5001

# ---------------- Prebuilt binaries ----------------
step "Gophish v0.12.1 (phishing campaign platform)"
if [ ! -x "$ARSENAL/phishing/gophish/gophish" ]; then
  curl -sL -o /tmp/gophish.zip https://github.com/gophish/gophish/releases/download/v0.12.1/gophish-v0.12.1-linux-64bit.zip
  mkdir -p "$ARSENAL/phishing/gophish"; unzip -o -q /tmp/gophish.zip -d "$ARSENAL/phishing/gophish"
  chmod +x "$ARSENAL/phishing/gophish/gophish"; rm -f /tmp/gophish.zip
fi
printf '#!/usr/bin/env bash\ncd %s/phishing/gophish && exec ./gophish "$@"\n' "$ARSENAL" > "$BIN/gophish"; chmod +x "$BIN/gophish"
[ -x "$ARSENAL/phishing/gophish/gophish" ] && ok "gophish" || bad "gophish"

step "Evilginx v3.3.0 (AiTM proxy, defeats OTP codes by stealing the session)"
if [ ! -x "$ARSENAL/phishing/evilginx/evilginx" ]; then
  curl -sL -o /tmp/evilginx.zip https://github.com/kgretzky/evilginx2/releases/download/v3.3.0/evilginx-v3.3.0-linux-64bit.zip
  mkdir -p "$ARSENAL/phishing/evilginx"; unzip -o -q /tmp/evilginx.zip -d "$ARSENAL/phishing/evilginx"
  chmod +x "$ARSENAL/phishing/evilginx/evilginx"; rm -f /tmp/evilginx.zip
fi
printf '#!/usr/bin/env bash\ncd %s/phishing/evilginx && exec ./evilginx "$@"\n' "$ARSENAL" > "$BIN/evilginx"; chmod +x "$BIN/evilginx"
[ -x "$ARSENAL/phishing/evilginx/evilginx" ] && ok "evilginx" || bad "evilginx"

step "PhoneInfoga v2.11.0 (phone number OSINT)"
if [ ! -x "$ARSENAL/osint/phoneinfoga/phoneinfoga" ]; then
  curl -sL -o /tmp/phoneinfoga.tar.gz https://github.com/sundowndev/phoneinfoga/releases/download/v2.11.0/phoneinfoga_Linux_x86_64.tar.gz
  mkdir -p "$ARSENAL/osint/phoneinfoga"; tar --no-same-owner -xzf /tmp/phoneinfoga.tar.gz -C "$ARSENAL/osint/phoneinfoga" 2>/dev/null
  chmod +x "$ARSENAL/osint/phoneinfoga/phoneinfoga" 2>/dev/null; rm -f /tmp/phoneinfoga.tar.gz
fi
printf '#!/usr/bin/env bash\nexec %s/osint/phoneinfoga/phoneinfoga "$@"\n' "$ARSENAL" > "$BIN/phoneinfoga"; chmod +x "$BIN/phoneinfoga"
[ -x "$ARSENAL/osint/phoneinfoga/phoneinfoga" ] && ok "phoneinfoga" || bad "phoneinfoga"

# ---------------- Phishing frameworks and kits ----------------
step "SET · Social-Engineer Toolkit (official archive + own venv)"
if [ ! -d "$ARSENAL/phishing/set" ]; then
  curl -sL -o /tmp/set.tar.gz https://github.com/trustedsec/social-engineer-toolkit/archive/refs/heads/master.tar.gz
  tar xzf /tmp/set.tar.gz -C /tmp && mv /tmp/social-engineer-toolkit-master "$ARSENAL/phishing/set"; rm -f /tmp/set.tar.gz
fi
mkvenv "$ARSENAL/venv-set"
"$ARSENAL/venv-set/bin/pip" install -q --prefer-binary -r "$ARSENAL/phishing/set/requirements.txt"
printf '#!/usr/bin/env bash\ncd %s/phishing/set && exec %s/venv-set/bin/python setoolkit "$@"\n' "$ARSENAL" "$ARSENAL" > "$BIN/setoolkit"; chmod +x "$BIN/setoolkit"
[ -f "$ARSENAL/phishing/set/setoolkit" ] && ok "setoolkit" || bad "setoolkit"

clonesh(){ # clonesh <name> <repo-url> <script-file>
  local name="$1" url="$2" script="$3"
  step "$name"
  [ -d "$ARSENAL/phishing/$name" ] || git clone --depth 1 -q "$url" "$ARSENAL/phishing/$name"
  if [ -f "$ARSENAL/phishing/$name/$script" ]; then
    printf '#!/usr/bin/env bash\ncd %s/phishing/%s && exec bash %s "$@"\n' "$ARSENAL" "$name" "$script" > "$BIN/$name"
    chmod +x "$BIN/$name"; ok "$name"
  else bad "$name"; fi
}
clonesh zphisher https://github.com/htr-tech/zphisher zphisher.sh     # clone-page kit: Instagram, TikTok + 30 more templates
clonesh camphish https://github.com/techchipnet/CamPhish camphish.sh  # camera-access lure pages

step "seeker (precise location harvesting via a link)"
[ -d "$ARSENAL/phishing/seeker" ] || git clone --depth 1 -q https://github.com/thewhiteh4t/seeker "$ARSENAL/phishing/seeker"
mkvenv "$ARSENAL/venv-seeker"
[ -f "$ARSENAL/phishing/seeker/requirements.txt" ] && "$ARSENAL/venv-seeker/bin/pip" install -q --prefer-binary -r "$ARSENAL/phishing/seeker/requirements.txt"
if [ -f "$ARSENAL/phishing/seeker/seeker.py" ]; then
  printf '#!/usr/bin/env bash\ncd %s/phishing/seeker && exec %s/venv-seeker/bin/python seeker.py "$@"\n' "$ARSENAL" "$ARSENAL" > "$BIN/seeker"
  chmod +x "$BIN/seeker"; ok "seeker"
else bad "seeker"; fi

step "cupp (password profiler: wordlists from a target's public info)"
[ -d "$ARSENAL/phishing/cupp" ] || git clone --depth 1 -q https://github.com/Mebus/cupp "$ARSENAL/phishing/cupp"
if [ -f "$ARSENAL/phishing/cupp/cupp.py" ]; then
  printf '#!/usr/bin/env bash\ncd %s/phishing/cupp && exec python3 cupp.py "$@"\n' "$ARSENAL" > "$BIN/cupp"
  chmod +x "$BIN/cupp"; ok "cupp"
else bad "cupp"; fi

step "maskphish (link disguising behind trusted-looking URLs)"
[ -d "$ARSENAL/phishing/maskphish" ] || git clone --depth 1 -q https://github.com/jaykali/maskphish "$ARSENAL/phishing/maskphish"
if [ -f "$ARSENAL/phishing/maskphish/maskphish.sh" ]; then
  printf '#!/usr/bin/env bash\ncd %s/phishing/maskphish && exec bash maskphish.sh "$@"\n' "$ARSENAL" > "$BIN/maskphish"
  chmod +x "$BIN/maskphish"; ok "maskphish"
else bad "maskphish"; fi

step "Modlishka (optional AiTM proxy, built from source with Go)"
if [ ! -x "$BIN/modlishka" ]; then
  sudo apt-get install -y -qq golang-go > /dev/null 2>&1
  [ -d /tmp/modlishka-src ] || git clone --depth 1 -q https://github.com/drk1wi/Modlishka /tmp/modlishka-src
  (cd /tmp/modlishka-src && go build -o "$BIN/modlishka" . > /dev/null 2>&1)
fi
[ -x "$BIN/modlishka" ] && ok "modlishka (optional)" || echo "  SKIPPED: modlishka build did not complete (optional; Evilginx already covers AiTM)"

if grep -qi kali /etc/os-release 2>/dev/null; then
  step "Kali extras (recon-ng, beef-xss)"
  sudo apt-get install -y -qq recon-ng beef-xss > /dev/null 2>&1 && ok "recon-ng + beef-xss (Kali)" || bad "Kali extras"
  echo "  Optional heavyweight: sudo apt install metasploit-framework"
fi

# ---------------- The se-arsenal command ----------------
step "Installing the se-arsenal command"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
printf 'REPO_DIR=%s\nVERSION=%s\n' "$REPO_DIR" "$VERSION" > "$ARSENAL/.se-arsenal.conf"

cat > "$BIN/se-arsenal" <<'CLIEOF'
#!/usr/bin/env bash
# SE-Arsenal command: manage your installed arsenal.
ARSENAL="$HOME/se-arsenal"; BIN="$ARSENAL/bin"
CONF="$ARSENAL/.se-arsenal.conf"; [ -f "$CONF" ] && . "$CONF"
TOOLS="sherlock maigret socialscan nexfil holehe theharvester h8mail ghunt blackbird osintgram photon spiderfoot phoneinfoga instaloader toutatis ignorant yt-dlp gallery-dl gophish evilginx setoolkit zphisher camphish seeker cupp maskphish"
case "${1:-help}" in
  list)
    echo "SE-ARSENAL · installed launchers in $BIN"
    echo "Recon:      sherlock maigret blackbird socialscan nexfil holehe theharvester h8mail ghunt phoneinfoga"
    echo "Instagram:  osintgram toutatis ignorant instaloader"
    echo "TikTok:     TikTokApi (library) via ~/se-arsenal/osint/venv-tiktokapi, plus yt-dlp and gallery-dl"
    echo "Phishing:   gophish setoolkit zphisher camphish seeker maskphish"
    echo "AiTM:       evilginx modlishka (if built)"
    echo "Profiling:  cupp spiderfoot photon"
    ;;
  check)
    ready=0; missing=0
    for t in $TOOLS; do
      if [ -x "$BIN/$t" ]; then ready=$((ready+1)); else missing=$((missing+1)); echo "  missing: $t"; fi
    done
    [ -x "$BIN/modlishka" ] && ready=$((ready+1)) || echo "  optional not built: modlishka"
    echo "SE-Arsenal check: $ready ready, $missing missing. Re-run install.sh to repair."
    ;;
  update)
    if [ -n "${REPO_DIR:-}" ] && [ -d "$REPO_DIR/.git" ]; then
      git -C "$REPO_DIR" pull -q && bash "$REPO_DIR/install.sh"
    else
      echo "Clone location unknown. Re-clone SE-Arsenal and run install.sh from the clone."
    fi
    ;;
  remove)
    read -r -p "Remove SE-Arsenal completely from $ARSENAL? [y/N] " ans
    if [ "$ans" = "y" ] || [ "$ans" = "Y" ]; then
      sed -i '/se-arsenal\/bin/d' "$HOME/.bashrc" "$HOME/.zshrc" 2>/dev/null
      rm -rf "$ARSENAL"; echo "SE-Arsenal removed. Open a new terminal to refresh your PATH."
    else echo "Cancelled."; fi
    ;;
  *)
    echo "se-arsenal · v${VERSION:-1.0.2}"
    echo "Usage: se-arsenal <list|check|update|remove>"
    ;;
esac
CLIEOF
chmod +x "$BIN/se-arsenal"
ok "se-arsenal command"

# Kali's default shell is zsh, Ubuntu's is bash: register the PATH in both
# startup files so new terminals of either shell find the launchers.
for RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
  grep -q 'se-arsenal/bin' "$RC" 2>/dev/null || echo 'export PATH="$HOME/se-arsenal/bin:$PATH"' >> "$RC"
done
export PATH="$BIN:$PATH"

# ---------------- Final report ----------------
echo -e "\n============================================================"
echo -e "${GREEN}SE-ARSENAL v$VERSION · INSTALL REPORT${NC}"
echo "============================================================"
echo "Ready (${#PASS[@]}):"
for t in "${PASS[@]}"; do echo "  ✓ $t"; done
if [ ${#FAIL[@]} -gt 0 ]; then
  echo -e "${RED}Needs attention (${#FAIL[@]}):${NC}"
  for t in "${FAIL[@]}"; do echo "  ✗ $t"; done
  echo "Re-run install.sh to retry only the missing pieces."
fi
echo
echo "Manage everything with:  se-arsenal list | check | update | remove"
echo "In THIS terminal, activate the launchers once with:"
echo "  export PATH=\"$BIN:\$PATH\""
echo "Every new terminal picks them up automatically."
echo "First moves:"
echo "  sherlock --site Instagram --site TikTok <handle>"
echo "  maigret <handle>"
echo "  holehe <email>"
echo "  zphisher            # 02 Instagram, 10 TikTok, localhost for a safe first run"
echo "  gophish             # then https://localhost:3333, admin password prints in the terminal"
echo "  evilginx            # AiTM console"
echo "  ghunt login         # one-time GHunt setup"
echo
echo "For authorized security research, red team work and education only."
