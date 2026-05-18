# Debian Server Post-Installation Script

Automates system configuration, hardening, and tooling setup for Debian servers with intelligent profile-based defaults and VPS-safe security.

**Designed for Debian Server**, but can be used on Ubuntu Server distributions.  
**For Ubuntu Desktop**, see: [github.com/franckferman/ubuntu-post-install](https://github.com/franckferman/ubuntu-post-install)

##  Key Features

- **Profile-Based Configuration** - Smart defaults for different deployment scenarios
- **VPS-Safe Security** - No lockout risk with remote access preservation
- **Granular Network Hardening** - 9 modular network security components with individual flags
- **Multiple Firewall Engines** - UFW, nftables, iptables support
- **Custom Hardening Lists** - Specify exactly which services/packages to harden
- **Zero-Surprise Defaults** - Secure but operational by default
- **Proxmox/Docker Compatible** - Safe defaults for virtualization environments
- **Hybrid Architecture** - APT packages + specialized tool integration

##  Quick Start

```bash
# Basic installation (VPS-safe)
./debian-server-post-install.sh

# Production server with performance focus
./debian-server-post-install.sh --server-profile prod

# Development server with convenience
./debian-server-post-install.sh --server-profile dev

# Maximum security (still VPS-safe)
./debian-server-post-install.sh --server-profile hardened

# Custom Docker engine
./debian-server-post-install.sh --docker-type ce
```

##  Server Profiles

### `--server-profile <profile>`

| Profile | Editor | Firewall | VIM | SSH | Apps | Use Case |
|---------|--------|----------|-----|-----|------|----------|
| **default** | both | ufw + hardened | minimal | VPS-safe | server (37) | General purpose |
| **prod** | both | nftables + hardened | minimal | VPS-safe | server (37) | Production ready |
| **dev** | both | ufw + transparent | full | VPS-safe | full (57) | Development friendly |
| **minimal** | vim | ufw + hardened | minimal | VPS-safe | minimal (5) | Lightweight essential |
| **hardened** | vim | nftables + hardened | bare | VPS-safe | defense (47) | Maximum security |

### Profile Characteristics

#### **default** - Balanced
```bash
+ Both editors (Vim + Neovim/LazyVim)
+ UFW firewall with hardened rules
+ Minimal Vim preset (stable)
+ Monitoring and logging enabled
+ Docker basic installation
+ Network hardening: ICMP/TCP/Source routing protection active
- Network hardening: IPv6/Anti-spoofing/Connection limits commented (safe)
```

#### **prod** - Production Optimized
```bash
+ nftables firewall (performance)
+ SSH hardening enabled
+ Docker + Compose
+ Enhanced monitoring/logging
+ Network hardening disabled for dev (transparent firewall)
+ All other security hardening active
```

#### **dev** - Development Friendly
```bash
+ UFW transparent firewall (no blocking)
+ Full Vim preset (IDE-like)
+ Nerd Fonts for terminal
+ Docker + Compose
+ Complete development stack (Node.js, Go, etc.)
- Monitoring disabled (lighter)
- Network hardening disabled (development transparent)
```

#### **minimal** - Lightweight
```bash
+ Vim only (no Neovim)
+ Essential tools only (5 packages)
- No Docker/monitoring
+ Essential security only
+ Same network hardening as default
```

#### **hardened** - Maximum Security
```bash
+ Bare Vim preset (minimal surface)
+ nftables firewall
+ USBGuard enabled
+ Defense apps profile (security tools)
- No Docker (reduced attack surface)
+ All basic hardening features active
+ Same network hardening as default (conservative)
```

##  Apps-Profile System (Hybrid Architecture)

### `--apps-profile <profile>`

The apps-profile system uses inheritance and specialized functions to minimize redundancy:

```
minimal (5) -> default (29) -> server (37) -> minimal-development (32) -> development (43)
                                           -> security (39) -> defense (47)
                                                           -> offsec (40)
                                                           -> full (57) -> enterprise (67)
```

###  Quick Reference Table

| Profile | Packages | Inherits From | Adds | Primary Use Case |
|---------|----------|---------------|------|------------------|
| **minimal** | 5 | - | Survival only | Containers, ultra-light VPS |
| **default** | 29 | minimal | Comfort + infrastructure tools | Standard server |
| **server** | 37 | default | Server mgmt (monitoring, backup) | Production server |
| **minimal-development** | 32 | server | Light dev tools (python-dev, make) | Light development |
| **development** | 43 | minimal-development | Full stack (node, golang, docker) | Complete development |
| **security** | 39 | server | General security tools (nmap, tcpdump) | Network security basics |
| **defense** | 47 | security | Blue team tools (lynis, wireshark) | Security audit server |
| **offsec** | 40 | security | Red team tools (netcat) | Offensive security |
| **full** | 57 | development + defense | Complete dev + security | Full workstation |
| **enterprise** | 67 | full | Compliance (auditd, tripwire) | Enterprise compliance |

### Package Details by Layer

#### Level 1: minimal (Survival Only - 5 packages)
```bash
git curl vim fail2ban tmux
```
**Philosophy**: Absolute minimum for remote server survival

#### Level 2: default (Comfort + Infrastructure - +24 packages)
```bash
# Ex-minimal comfort tools
wget zsh htop net-tools unzip tree ncdu ss lsof
# Modern comfort tools  
lsd zip unrar p7zip-full
# Infrastructure tools  
build-essential software-properties-common
apt-transport-https ca-certificates gnupg lsb-release
python3 python3-pip python3-venv jq rsync
```

#### Level 3: server (Server Management - +8 packages)
```bash
logrotate psmisc dstat iotop nethogs
backup-manager sudo screen
openssl ca-certificates-utils
cron anacron at rsyslog vnstat
```

#### Level 4A: minimal-development (Light Dev Tools - +5 packages)
```bash
python3-dev make cmake pkg-config
sqlite3 golang-go
```

#### Level 5A: development (Full Development Stack - +11 packages)
```bash
# Modern development stack
nodejs npm golang postgresql-client mysql-client
ansible-core fzf yq ripgrep autotools-dev
# Docker (conditional on --docker-type)
docker.io docker-compose  # if --docker-type io
# HashiCorp tools (via specialized function)
terraform packer vault   # via _install_hashicorp_from_profile
```

#### Level 4B: security (General Security - +2 packages)
```bash
nmap tcpdump
```

#### Level 5B: defense (Blue Team - +8 packages)
```bash
lynis rkhunter chkrootkit
wireshark-common tshark
aide debsecan debsums
```

#### Level 5C: offsec (Red Team - +1 package)
```bash
netcat-openbsd
```

#### Level 6: enterprise (Compliance - +10 packages)
```bash
auditd sysstat acct
logwatch logcheck
rng-tools haveged
```

### Hybrid Architecture Features

#### APT Standard Packages
Most packages are installed via standard APT repositories in step 5.

#### Specialized Functions
Some tools require external repositories and use specialized functions:

**HashiCorp Tools** (terraform, packer, vault):
- Adds HashiCorp repository
- Called by `_install_hashicorp_from_profile()` for development/full/enterprise profiles

**Docker Engine**:
- `--docker-type io`: docker.io from APT (default, stable)
- `--docker-type ce`: docker-ce from official Docker repository

## 🌐 Network Hardening (Granular Control)

### Overview
The script provides 9 modular network security components with individual flags. Each component can be enabled or disabled independently for maximum flexibility.

### Network Hardening Architecture

#### **Safe by Default** (Active)
These protections target obsolete/dangerous protocols with minimal compatibility risk:
```bash
+ ICMP Redirects Protection     # Blocks redirection attacks  
+ Source Routing Protection     # Blocks source routing attacks
+ ICMP Security Protection      # Anti-smurf, bogus errors
+ TCP SYN Flood Protection      # SYN cookies enabled
```

#### **Conservative by Default** (Commented)
These features may impact complex network configurations:
```bash
- IPv6 Configuration           # Safe for Proxmox/Docker
- Martians Packet Logging      # Avoids log verbosity
- Anti-spoofing (rp_filter)    # Safe for VLANs/complex routing
- Connection Limits Tuning     # Safe for high-performance apps
- Modern Security Features     # Safe for forwarding-dependent services
```

### Network Hardening Flags

#### **IPv6 Configuration**
```bash
--disable-ipv6                  # Disable IPv6 completely (default, Proxmox safe)
--no-disable-ipv6              # Enable IPv6 with security hardening
```

#### **ICMP Redirects Protection** 
```bash
--disable-icmp-redirects        # Disable ICMP redirect protection  
--no-disable-icmp-redirects    # Enable ICMP redirect protection (default)
```

#### **Source Routing Protection**
```bash
--disable-source-routing        # Disable source routing protection
--no-disable-source-routing    # Enable source routing protection (default)
```

#### **Martians Packet Logging**
```bash
--disable-martians-logging      # Disable martians packet logging (default)
--no-disable-martians-logging  # Enable martians packet logging
```

#### **ICMP Security Protection**
```bash
--disable-icmp-protection       # Disable ICMP security protection
--no-disable-icmp-protection   # Enable ICMP security protection (default)
```

#### **TCP SYN Flood Protection**
```bash
--disable-tcp-protection        # Disable TCP security protection
--no-disable-tcp-protection    # Enable TCP security protection (default)
```

#### **Anti-spoofing Protection**
```bash
--disable-antispoofing          # Disable anti-spoofing protection (default)
--no-disable-antispoofing      # Enable anti-spoofing protection (rp_filter=1)
```

#### **Connection Limits Tuning**
```bash
--disable-connection-limits     # Disable connection limits tuning (default)
--no-disable-connection-limits # Enable TCP connection limits tuning
```

#### **Modern Security Features**
```bash
--disable-modern-security       # Disable modern security features (default)
--no-disable-modern-security   # Enable modern security features
```

## 🔐 SSH Configuration (VPS-Safe)

### Default SSH Security
```bash
# VPS-SAFE defaults everywhere
SSH_KEY_ONLY=false        # Passwords allowed (no lockout)
DISABLE_ROOT_SSH=false    # Root SSH enabled (remote access safe)
ALLOW_SSH=true           # SSH enabled by default
SSH_PORT=22              # Standard port
```

### SSH Hardening Flags
```bash
--ssh-key-only           # Force keys-only authentication
--disable-root-ssh       # Disable root SSH login
--no-disable-root-ssh    # Keep root SSH enabled (default)
--ssh-port <port>        # Custom SSH port
```

##  Firewall Configuration

### Firewall Engines
```bash
--firewall <engine>
  ufw        # Simple, recommended for most servers
  nftables   # Modern, high-performance
  iptables   # Legacy but widely supported
```

### Firewall Profiles
```bash
--firewall-profile <profile>
  hardened    # Drop all incoming, allow outgoing + established
  transparent # Allow all traffic (development/testing)
```

## 🐳 Docker Configuration

### Docker Engine Types
```bash
--docker-type <type>     # Docker package type (default: io)
  io  # docker.io (Debian/Ubuntu repos, stable)
  ce  # docker-ce (Docker official repos, latest features)
```

**Default Behavior:**
- Apps-profiles install `docker.io` if `--docker-type io` (default)
- Step 8 configures existing docker.io or installs docker-ce
- Both types get identical security configuration

##  Editor Configuration

### Editor Modes
```bash
--editor <mode>
  both     # Vim + Neovim/LazyVim (default most profiles)
  vim      # Vim only (minimal/hardened)
  neovim   # LazyVim only
  none     # Skip editor installation
```

### Vim Presets
```bash
--vim-preset <preset>
  full     # vim-plug + plugins (dev profile)
  minimal  # gruvbox + basic config (default/prod/minimal)
  bare     # basic settings only (hardened)
```

##  Hardening Profiles

### `--hardening-profile <profile>`

| Profile | Root Lock | USB Guard | Services Removed | Packages Removed |
|---------|-----------|-----------|------------------|------------------|
| **server** | - No | - No | 9 services | 9 packages |
| **workstation** | - No | + Yes | 7 services | 9 packages |
| **enterprise** | - No | + Yes | 5 services | 9 packages |

### Service Hardening by Profile
```bash
# server (default for all server profiles)
Removes: avahi-daemon, cups, bluetooth, whoopsie, apport, 
         speech-dispatcher, telnet, rsh-server, tftp

# workstation
Removes: avahi-daemon, cups, whoopsie, apport, 
         telnet, rsh-server, tftp

# enterprise (preserves corporate services)
Removes: whoopsie, apport, telnet, rsh-server, tftp
Keeps: avahi-daemon, cups, bluetooth (corporate compatibility)
```

### Packages Hardening by Profile
```bash
# server/workstation/enterprise (aggressive cleanup)
Removes: xinetd, nis, rsh-client, talk, telnet, tftp,
         rsh-server, telnet-server, tftp-server
```

##  Hardening Control

### Service Hardening
```bash
--harden-services              # Enable service hardening (default)
--no-harden-services           # Skip service hardening
--harden-services-list "a,b,c" # Custom service list (overrides profile)
--skip-services "x,y"          # Remove services from profile list
```

### Package Hardening
```bash
--harden-packages              # Enable package hardening (default)
--no-harden-packages           # Skip package removal
--harden-packages-list "a,b,c" # Custom package list (overrides profile)
--skip-packages "x,y"          # Remove packages from profile list
```

##  Complete Examples

### VPS Production Server (Safe + Secure)
```bash
./debian-server-post-install.sh --server-profile prod --ssh-port 2222
# → All safe network hardening active, IPv6/anti-spoofing commented for compatibility
```

### High Security Server (Expert)
```bash
./debian-server-post-install.sh \
  --server-profile hardened \
  --no-disable-ipv6 \
  --no-disable-antispoofing \
  --no-disable-martians-logging \
  --ssh-key-only --disable-root-ssh
# → Maximum network hardening + SSH hardening
```

### Development Server with Docker CE
```bash
./debian-server-post-install.sh \
  --server-profile dev \
  --docker-type ce \
  --install-nerd-fonts \
  --no-disable-ipv6
# → Full development stack with latest Docker engine
```

### Enterprise Compliance Server
```bash
./debian-server-post-install.sh \
  --server-profile default \
  --apps-profile enterprise \
  --hardening-profile enterprise \
  --install-usbguard \
  --no-disable-antispoofing
# → Full compliance tooling with USB control
```

## ⚠️ Important Compatibility Notes

### Proxmox/Virtualization
- **IPv6**: Commented by default (safe for clustering/VMs)
- **Anti-spoofing**: Commented by default (safe for VLANs/bridges)  
- **Modern Security**: Commented by default (forwarding=0 breaks VMs)
- **All other hardening**: Active and safe

### Docker/Containers
- **Modern Security**: NEVER enable (forwarding=0 breaks containers)
- **Anti-spoofing**: May break complex networking
- **docker.io vs docker-ce**: Both fully supported via --docker-type
- **All other hardening**: Safe and recommended

### VLANs/Complex Networking
- **Anti-spoofing**: Commented by default (rp_filter=1 breaks inter-VLAN routing)
- **Connection Limits**: Commented by default (may limit high-performance routing)

## 📊 Complete Configuration Matrix

### All Server Profiles Configuration

| Setting | default | prod | dev | minimal | hardened |
|---------|---------|------|-----|---------|----------|
| **EDITOR_MODE** | both | both | both | vim | vim |
| **VIM_PRESET** | minimal | minimal | full | minimal | bare |
| **FIREWALL** | ufw | nftables | ufw | ufw | nftables |
| **FIREWALL_PROFILE** | hardened | hardened | transparent | hardened | hardened |
| **APPS_PROFILE** | server | server | full | minimal | defense |
| **DOCKER_TYPE** | io | io | io | io | io |
| **HARDENING_PROFILE** | server | server | server | server | server |
| **HARDEN_NETWORK** | true | true | false | true | true |
| **SSH_KEY_ONLY** | false | false | false | false | false |
| **DISABLE_ROOT_SSH** | false | false | false | false | false |
| **LOCK_ROOT** | false | false | false | false | false |
| **INSTALL_USBGUARD** | false | false | false | false | true |

## 🎮 Advanced Features

### Extra Software
```bash
--extra-repos <extras>     # Additional software repositories
  gh                       # GitHub CLI
  
--install-mullvad          # Mullvad VPN client
--mullvad-source <method>  # Installation method (apt|direct|github)
```

### Nerd Fonts
```bash
--install-nerd-fonts       # Install Nerd Fonts for terminal
--nerd-fonts-profile <p>   # Font selection profile
  minimal                  # FiraCode only
  default                  # FiraCode + JetBrains
  full                     # FiraCode + JetBrains + Hack + SourceCode
```

### Step Control
```bash
--steps <selection>        # Run specific steps only
  --steps 1-5              # Run steps 1 through 5
  --steps 1,3,5            # Run steps 1, 3, and 5
  --steps 2-8              # Run steps 2 through 8
```

## 📞 Support

- **GitHub Issues**: Report bugs and feature requests
- **Security**: All defaults are VPS-safe and tested
- **Primary**: Debian 11/12 Server  
- **Compatible**: Ubuntu Server 20.04/22.04/24.04  
- **Ubuntu Desktop**: Use [ubuntu-post-install](https://github.com/franckferman/ubuntu-post-install) instead

---

**Author**: Franck FERMAN  
**Version**: 2.1.0  
**License**: MIT