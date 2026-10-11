<div align="center">

# 🎭 SE-ARSENAL

### The social engineering arsenal that installs itself

**30+ battle-tested tools for TikTok, Instagram and Snapchat research, phishing infrastructure and AiTM session attacks. One command. Zero dependency wars.**

![Tools](https://img.shields.io/badge/tools-30%2B-red?style=for-the-badge)
![Platform](https://img.shields.io/badge/platform-WSL%20·%20Ubuntu%2024.04%20·%20Kali-blue?style=for-the-badge)
![Version](https://img.shields.io/badge/version-1.0.2-green?style=for-the-badge)
![License](https://img.shields.io/badge/license-MIT-yellow?style=for-the-badge)

</div>

---

## ⚡ Quick start

```bash
git clone https://github.com/mizazhaider-ceh/SE-Arsenal.git
cd SE-Arsenal && bash install.sh
```

That is the whole setup. The installer builds everything into `~/se-arsenal`, gives every tool its own isolated environment, puts a launcher for each tool on your PATH, installs the `se-arsenal` manager command, and finishes with a full status report. Re-running it is safe: finished steps are skipped, broken ones are retried.

Then open a new terminal and go:

```bash
se-arsenal list        # see your arsenal
sherlock --site Instagram --site TikTok <handle>
maigret <handle>
zphisher
evilginx
```

## 🔥 Why SE-Arsenal

- **It actually finishes.** Every tool source was verified live before being pinned here, and the famous traps are already disarmed: the dead PyPI theHarvester stub, the Python version cliff, the Holehe startup crash, the missing PHP runtime, and the GHunt Pillow pin that cannot build on Python 3.14 (GHunt automatically gets a dedicated Python 3.12 environment on modern systems).
- **Zero dependency wars.** Each Python tool lives in its own venv. Tools can never break each other, and `se-arsenal remove` wipes the slate clean.
- **Curated, not dumped.** 30+ tools chosen because they are the best at their job right now, organized by the real attack chain: recon, profiling, lure, capture, session theft.
- **Platform-first.** The deepest coverage goes where the attacks actually happen: TikTok, Instagram and Snapchat.

## 🏆 Best in class

| Mission | Tool | Why it wins |
|---|---|---|
| Username hunting | **Maigret** | 3000+ sites, extracts profile data, interests and linked accounts, writes reports |
| Rapid username sweep | **Blackbird** | 600+ sites, username and email, extremely fast |
| Instagram intelligence | **Osintgram** + **Toutatis** | Interactive OSINT shell plus account intel from a bare username |
| Instagram archiving | **Instaloader** | The maintained standard for profiles, posts and metadata |
| TikTok data | **TikTokApi** + **yt-dlp** | Full profile and video data library, bulletproof downloading |
| Email footprinting | **Holehe** | Reveals where an email is registered, straight from forgot-password flows |
| Phishing campaigns | **Gophish** | The professional platform: sending profiles, tracking, live dashboards |
| Clone-page kits | **Zphisher** | The kit behind real "free followers" scams, 30+ templates incl. Instagram and TikTok |
| Defeating OTP codes | **Evilginx** | AiTM reverse proxy: the victim logs in for real, you keep the session cookie |
| Location harvesting | **Seeker** | One clicked link returns precise GPS coordinates |

## 📱 Platform focus

**TikTok** · Username checks across Sherlock, Maigret, Blackbird, SocialScan and Nexfil. TikTokApi for profile and video intelligence. yt-dlp and gallery-dl for archiving. Zphisher carries the TikTok lure templates seen in live scams.

**Instagram** · The richest target set: Osintgram, Toutatis, Ignorant, Instaloader and Holehe, every username engine, and the Zphisher and CamPhish lure kits.

**Snapchat** · Straight talk: Snapchat is a closed platform and no serious dedicated Snapchat OSINT tool exists. What works, and what this arsenal ships, is username existence checking through Maigret, Blackbird, Sherlock and SocialScan, the same first step real operators use to map a target's cross-platform identity.

## 🧰 The full arsenal

**Recon and OSINT (19)** · Sherlock · Maigret · Blackbird · SocialScan · Nexfil · Holehe · theHarvester · h8mail · GHunt · Osintgram · Toutatis · Ignorant · Instaloader · TikTokApi · yt-dlp · gallery-dl · Photon · SpiderFoot · PhoneInfoga

**Phishing and capture (8)** · Gophish · SET · Zphisher · Evilginx · Modlishka (optional source build) · CamPhish · Seeker · MaskPhish

**Profiling and support (3+)** · Cupp · Nmap · Kali systems get Recon-ng and BeEF automatically

## 🕹️ The se-arsenal command

```bash
se-arsenal list     # every installed tool, grouped by mission
se-arsenal check    # health check: what is ready, what is missing
se-arsenal update   # pull the newest SE-Arsenal and rebuild
se-arsenal remove   # clean uninstall, PATH entry included
```

## 📂 Layout on your machine

```
~/se-arsenal/
├── bin/          one-command launcher for every tool + the se-arsenal manager
├── osint/        recon tools, one isolated venv each
├── phishing/     gophish · evilginx · set · zphisher · camphish · seeker
└── work/         your outputs, reports and captures
```

## 📋 Requirements

- Windows with **WSL2**, running **Ubuntu 24.04** (recommended, ships Python 3.12) or **Kali**
- A few GB of free space, an internet connection, and sudo rights inside WSL
- Kali systems unlock the two extra tools automatically

## ⚖️ Responsible use

SE-Arsenal is a professional toolkit for **authorized security research, red team operations and education**. Every capability in it is dual-use. Only ever point it at systems and accounts you own or are explicitly authorized to test. Unauthorized use is illegal in most jurisdictions, including Belgium and the EU.

## 👤 Author

Built and maintained by **Muhammad Izaz Haider**, The PenTrix · penetration tester and offensive security researcher.

*Pinned versions, verified live on 2026-10-12: Sherlock 0.16.2 · Maigret 0.6.6 · theHarvester 4.11.1 · Gophish 0.12.1 · Evilginx 3.3.0 · SocialScan 2.0.1 · Toutatis 1.31 · Ignorant 1.2 · TikTokApi 7.3.3 · Instaloader 4.15.3 · PhoneInfoga 2.11.0 · GHunt 2.3.4 · h8mail 2.5.6*
