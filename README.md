# 🎭 SE Lab · Social Engineering Arsenal

**One script installs 30+ social engineering tools on WSL**, focused on **TikTok, Instagram and Snapchat**, plus the full attack chain around them: recon, profiling, phishing kits, and the AiTM frameworks that beat two-factor codes.

Built for classroom demonstration and isolated lab practice: how hackers use these tools, how they work, and how to stop them.

![Platform](https://img.shields.io/badge/platform-WSL%20%7C%20Ubuntu%2024.04%20%7C%20Kali-blue)
![Tools](https://img.shields.io/badge/tools-30%2B-red)
![Use](https://img.shields.io/badge/use-lab%20%2F%20class%20demo%20only-green)

## 🚀 Install (one command, does everything itself)

```bash
git clone https://github.com/mizazhaider-ceh/se-lab.git
cd se-lab && bash install.sh
```

Use **Ubuntu 24.04** WSL (it ships Python 3.12, which theHarvester needs). Kali WSL also works and unlocks 2 extra tools. The script builds a clean lab at `~/se-lab`, gives every tool its own venv, adds one-command launchers to your PATH, and ends with a pass/fail report. Re-running it is safe.

## 🏆 The best tool per job (start here)

| Job | Use this | Why it wins |
|---|---|---|
| Username hunt | **Maigret** | 3000+ sites, extracts profile data and interests, writes reports |
| Fast username check | **Blackbird** | 600+ sites, username and email, very quick |
| Instagram deep dive | **Osintgram** + **Toutatis** | Interactive IG OSINT shell plus account info from a username |
| Instagram downloads | **Instaloader** | The maintained standard, profiles, posts, metadata |
| TikTok data | **TikTokApi** + **yt-dlp** | Library for profiles and videos, yt-dlp for bulletproof downloads |
| Email footprint | **Holehe** | Shows where an email is registered, via forgot-password flows |
| Phishing simulation | **Gophish** | The professional platform, campaigns, tracking, dashboards |
| Clone-page scams | **Zphisher** | The real-world kit behind "free followers" scams, IG + TikTok templates |
| Beating 2FA codes | **Evilginx** | AiTM proxy steals the session cookie after the real login |
| Location demo | **Seeker** | Shows how one link click leaks precise GPS location |

## 📱 Platform coverage

- **TikTok:** Sherlock, Maigret, Blackbird, SocialScan and Nexfil check usernames. TikTokApi pulls profile and video data. yt-dlp and gallery-dl download. Zphisher has the TikTok clone templates used in real scams.
- **Instagram:** the richest target set. Osintgram, Toutatis, Ignorant, Instaloader, Holehe, plus every username tool and the Zphisher / CamPhish kits.
- **Snapchat:** honest truth, Snapchat is a closed platform, so no serious open-source Snapchat OSINT tool exists. What does work: username existence checks in Maigret, Blackbird, Sherlock and SocialScan, which is exactly how attackers test whether a handle is taken there too.

## 🧰 Full tool list

**Recon and OSINT (19):** Sherlock · Maigret · Blackbird · SocialScan · Nexfil · Holehe · theHarvester · h8mail · GHunt · Osintgram · Toutatis · Ignorant · Instaloader · TikTokApi · yt-dlp · gallery-dl · Photon · SpiderFoot · PhoneInfoga

**Phishing and capture (8):** Gophish · SET (Social-Engineer Toolkit) · Zphisher · Evilginx · Modlishka (optional build) · CamPhish · Seeker · MaskPhish

**Profiling and support (3):** Cupp (password profiler) · Nmap · Kali extras on Kali WSL: Recon-ng and BeEF

## 📂 What gets built on your machine

```
~/se-lab/
├── bin/          one-command launchers for every tool
├── osint/        recon tools, one venv each
├── phishing/     gophish, evilginx, set, zphisher, camphish, seeker
├── scripts/      installer copy and helpers
├── guide/        the HTML guides
└── work/         your demo outputs and reports
```

## 📖 Guides (in the `guide` folder)

- **wsl-setup-guide.html**: the setup explained step by step, folder logic, the five install traps and their fixes
- **class-demo-guide.html**: the 50-minute class demo, per tool how hackers use it, how it works, and the prevention for each, plus a link-reading masterclass and prevention checklist

## ⚠️ Lab rules

Demo accounts you own. Isolated practice. Never real people. The same tools aimed at strangers are a crime; the defence half of every demo matters as much as the attack half.

*Built by The PenTrix · versions verified live on 2026-10-12: Sherlock 0.16.2, Maigret 0.6.6, theHarvester 4.11.1, Gophish 0.12.1, Evilginx 3.3.0, SocialScan 2.0.1, Toutatis 1.31, TikTokApi 7.3.3, Instaloader 4.15.3 and the rest pinned in `install.sh`.*
