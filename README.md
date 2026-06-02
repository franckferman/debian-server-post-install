# Debian Server Post-Installation Script

Automates system configuration, hardening, and tooling setup for Debian servers with profile-based defaults and safe security configurations.

Designed for Debian Server, but compatible with Ubuntu Server distributions.  
For Ubuntu Desktop, see: [github.com/franckferman/ubuntu-post-install](https://github.com/franckferman/ubuntu-post-install)

## Features

- Profile-based configuration for different deployment scenarios
- VPS-safe security hardening to prevent remote lockouts
- Modular network hardening with 9 configurable components
- Multiple firewall engines: UFW, nftables, iptables
- Customizable service and package hardening
- Secure defaults that preserve functionality
- Proxmox and Docker compatibility
- APT packages with specialized tool integration

## Quick Start

### Download and Run
```bash
# Download script
curl -O https://raw.githubusercontent.com/franckferman/debian-server-post-install/stable/debian-server-post-install.sh
chmod +x debian-server-post-install.sh

# Or direct execution (basic profile only - review first!)
curl -fsSL https://raw.githubusercontent.com/franckferman/debian-server-post-install/stable/debian-server-post-install.sh | bash

# For root users (add --allow-root)
./debian-server-post-install.sh --allow-root

# Direct with arguments (download first)
curl -fsSL https://raw.githubusercontent.com/franckferman/debian-server-post-install/stable/debian-server-post-install.sh | bash -s -- --server-profile dev
```

### Profile Examples
```bash
# Basic installation (VPS-safe, no Docker)
./debian-server-post-install.sh

# Production server with Docker
./debian-server-post-install.sh --server-profile prod

# Development server with full stack
./debian-server-post-install.sh --server-profile dev

# Maximum security (still VPS-safe)
./debian-server-post-install.sh --server-profile hardened

# Default + Docker installation
./debian-server-post-install.sh --install-docker        # docker.io (default)
./debian-server-post-install.sh --docker-type io        # docker.io (explicit)
./debian-server-post-install.sh --docker-type ce        # docker-ce (official)

# Examples with different types
./debian-server-post-install.sh --server-profile default --docker-type ce
./debian-server-post-install.sh --server-profile default --install-docker
```

## Server Profiles

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
- No Docker (use --docker-type to install)
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

## Apps-Profile System

### `--apps-profile <profile>`

The apps-profile system uses inheritance and specialized functions to minimize redundancy:

```
minimal (5) -> default (29) -> server (37) -> minimal-development (32) -> development (43)
                                           -> security (39) -> defense (47)
                                                           -> offsec (40)
                                                           -> full (57) -> enterprise (67)
```

### Quick Reference Table

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

#### Level 1: minimal (5 packages)
```bash
git curl vim fail2ban tmux
```
Essential packages for remote server management.

#### Level 2: default (+24 packages)
```bash
# Essential tools
wget zsh htop net-tools unzip tree ncdu ss lsof
# Archive tools
lsd zip unrar p7zip-full
# Infrastructure tools
build-essential software-properties-common
apt-transport-https ca-certificates gnupg lsb-release
python3 python3-pip python3-venv jq rsync
```

#### Level 3: server (+8 packages)
```bash
logrotate psmisc dstat iotop nethogs
backup-manager sudo screen
openssl ca-certificates-utils
cron anacron at rsyslog vnstat
```

#### Level 4A: minimal-development (+5 packages)
```bash
python3-dev make cmake pkg-config
sqlite3 golang-go
```

#### Level 5A: development (+11 packages)
```bash
# Development stack
nodejs npm golang postgresql-client mysql-client
ansible-core fzf yq ripgrep autotools-dev
# Docker (conditional on --docker-type)
docker.io docker-compose  # if --docker-type io
# HashiCorp tools (via specialized function)
terraform packer vault   # via _install_hashicorp_from_profile
```

#### Level 4B: security (+2 packages)
```bash
nmap tcpdump
```

#### Level 5B: defense (+8 packages)
```bash
lynis rkhunter chkrootkit
wireshark-common tshark
aide debsecan debsums
```

#### Level 5C: offsec (+1 package)
```bash
netcat-openbsd
```

#### Level 6: enterprise (+10 packages)
```bash
auditd sysstat acct
logwatch logcheck
rng-tools haveged
```

### Installation Methods

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

## Network Hardening

The script provides 9 modular network security components with individual flags. Each component can be enabled or disabled independently.

### Network Security Components

#### Safe by Default (Enabled)
These protections target obsolete or dangerous protocols with minimal compatibility risk:
```bash
+ ICMP Redirects Protection     # Prevents redirection attacks  
+ Source Routing Protection     # Prevents source routing attacks
+ ICMP Security Protection      # Prevents smurf attacks and bogus errors
+ TCP SYN Flood Protection      # Enables SYN cookies
```

#### Conservative by Default (Disabled)
These features may impact complex network configurations:
```bash
- IPv6 Configuration           # Safe for Proxmox/Docker
- Martians Packet Logging      # Reduces log verbosity
- Anti-spoofing (rp_filter)    # Safe for VLANs/complex routing
- Connection Limits Tuning     # Safe for high-performance applications
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

#### **Kexec System Call**
```bash
--disable-kexec                # Allow kexec system call (specialized environments)
--no-disable-kexec             # Disable kexec system call (default, security hardening)
```

## SSH Configuration

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
# Basic SSH Configuration
--allow-ssh                  # Open SSH port (default: enabled for servers)
--ssh-port <port>            # SSH port number (default: 22)
--no-ssh-hardening           # Disable SSH hardening completely

# Authentication Control
--ssh-key-only               # Disable password authentication, keys only
--disable-root-ssh           # Disable root SSH login
--no-disable-root-ssh        # Allow root SSH login (default: enabled for remote access safety)

# IPv4/IPv6 Protocol Control
--ssh-enable-ipv6            # Explicitly enable IPv6 (default: enabled)
--ssh-disable-ipv6           # Force SSH to IPv4 only (AddressFamily inet)
--ssh-enable-ipv4            # Explicitly enable IPv4 (default: enabled)  
--ssh-disable-ipv4           # Force SSH to IPv6 only (AddressFamily inet6)
--ssh-listen-address <ip>    # Bind SSH to specific IP address (can be used multiple times)

# Legacy/Modern Compatibility
--ssh-modern-only            # Remove legacy SSH options (Protocol 2, etc.)
--no-ssh-modern-only         # Keep legacy SSH compatibility (default: enabled)
--ssh-rsa                    # Enable RSA host key for legacy compatibility (default: enabled)
--no-ssh-rsa                 # Disable RSA host key for modern clients only
```

## Firewall Configuration

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

## Docker Configuration

### Docker Installation
```bash
--install-docker         # Force Docker installation (docker.io by default)
--docker-type <type>     # Docker type (auto-enables installation)
  io  # docker.io (Debian/Ubuntu repos, stable)
  ce  # docker-ce (Docker official repos, latest features)
--no-docker              # Skip Docker installation
```

**Installation Logic:**
- **default/minimal/hardened**: No Docker by default
- **prod/dev**: Docker installed automatically  
- **Any profile**: Use `--install-docker`, `--extras docker`, or `--docker-type` to force installation
- **--docker-type**: Automatically enables Docker installation with specified type
- **--extras docker**: Works with `--docker-type` to specify engine type

**Examples:**
```bash
# Default profile + Docker CE
./script.sh --server-profile default --docker-type ce
./script.sh --server-profile default --extras docker --docker-type ce

# Default profile + Docker IO  
./script.sh --server-profile default --install-docker
./script.sh --server-profile default --extras docker
```
- Both types get identical security configuration

## Editor Configuration

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

## Kernel Security Hardening

### Standards and Sources

The kernel hardening parameters are based on industry-standard security frameworks:

**Primary Sources:**
- **CIS Benchmarks** - Center for Internet Security Linux hardening guidelines
- **ANSSI** - French National Agency for Information Systems Security
- **NIST SP 800-53** - National Institute of Standards and Technology controls
- **KSPP** - Linux Kernel Self-Protection Project recommendations

**Applied Protections:**
```bash
# Information Disclosure Prevention (CIS 1.6.1 + ANSSI R12)
kernel.dmesg_restrict = 1              # Prevent unprivileged kernel log access
kernel.kptr_restrict = 2               # Hide kernel pointers (anti-KASLR bypass)
kernel.yama.ptrace_scope = 1           # Restrict process debugging

# Kernel Exploit Mitigation (KSPP + CIS)
kernel.kexec_load_disabled = 1         # Disable kexec (anti-rootkit)
kernel.unprivileged_bpf_disabled = 1   # Disable unprivileged eBPF
net.core.bpf_jit_harden = 2           # Harden BPF JIT compiler

# File System Security (CIS 1.6.4 + NIST)
fs.suid_dumpable = 0                   # Disable SUID core dumps
fs.protected_hardlinks = 1             # Prevent hardlink attacks
fs.protected_symlinks = 1              # Prevent symlink attacks
fs.protected_fifos = 2                 # Prevent FIFO attacks
fs.protected_regular = 2               # Prevent file attacks

# ASLR Enhancement (CIS 1.6.2 + KSPP)
kernel.randomize_va_space = 2          # Full address space randomization
vm.mmap_rnd_bits = 32                  # Maximum mmap entropy (64-bit)
vm.mmap_rnd_compat_bits = 16          # Maximum mmap entropy (32-bit)
```

## Hardening Profiles

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

## Hardening Control

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

## Complete Examples

### VPS Production Server (Safe + Secure)
```bash
./debian-server-post-install.sh --server-profile prod --ssh-port 2222
# → Safe network hardening enabled, IPv6/anti-spoofing disabled for compatibility
```

### High Security Server (Expert)
```bash
./debian-server-post-install.sh \
  --server-profile hardened \
  --no-disable-ipv6 \
  --no-disable-antispoofing \
  --no-disable-martians-logging \
  --ssh-key-only --disable-root-ssh
# → Maximum network and SSH hardening
```

### Development Server with Docker CE
```bash
./debian-server-post-install.sh \
  --server-profile dev \
  --docker-type ce \
  --install-nerd-fonts \
  --no-disable-ipv6
# → Full development stack with Docker CE
```

### Enterprise Compliance Server
```bash
./debian-server-post-install.sh \
  --server-profile default \
  --apps-profile enterprise \
  --hardening-profile enterprise \
  --install-usbguard \
  --no-disable-antispoofing
# → Enterprise compliance tooling with USB security
```

## Compatibility Notes

### Proxmox/Virtualization
- **IPv6**: Disabled by default (safe for clustering/VMs)
- **Anti-spoofing**: Disabled by default (safe for VLANs/bridges)  
- **Modern Security**: Disabled by default (forwarding=0 breaks VMs)
- **All other hardening**: Enabled and safe

### Docker/Containers
- **Modern Security**: NEVER enable (forwarding=0 breaks containers)
- **Anti-spoofing**: May break complex networking
- **docker.io vs docker-ce**: Both supported via --docker-type
- **All other hardening**: Safe and recommended

### VLANs/Complex Networking
- **Anti-spoofing**: Disabled by default (rp_filter=1 breaks inter-VLAN routing)
- **Connection Limits**: Disabled by default (may limit high-performance routing)

## Configuration Matrix

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

## Advanced Features

### Extra Software
```bash
--extras <list>            # Comma-separated extras to install
  docker                   # Enable Docker installation (use with --docker-type)
  gh                       # GitHub CLI with official repository
  hashicorp                # Redirects to apps-profile development+
  monitoring               # Handled by existing monitoring steps
  mullvad                  # Use --install-mullvad flag instead

--extra-packages <list>    # Comma-separated APT packages to add
  htop,bat,exa,fd-find     # Example: modern CLI tools

--install-mullvad          # Mullvad VPN client
--mullvad-source <method>  # Installation method (apt|direct|github)
```

**Examples:**
```bash
# Docker via extras (docker.io by default)
./script.sh --server-profile default --extras docker

# Docker CE via extras + type specification
./script.sh --server-profile default --extras docker --docker-type ce

# GitHub CLI + custom packages
./script.sh --server-profile default --extras gh --extra-packages kubectl,helm

# Development with Docker CE + GitHub CLI
./script.sh --server-profile dev --docker-type ce --extras gh
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

## Support

- **GitHub Issues**: Report bugs and feature requests
- **Security**: All defaults are VPS-safe and tested
- **Primary**: Debian 11/12 Server  
- **Compatible**: Ubuntu Server 20.04/22.04/24.04  
- **Ubuntu Desktop**: Use [ubuntu-post-install](https://github.com/franckferman/ubuntu-post-install) instead

---

**Author**: Franck FERMAN  
**Version**: 2.1.0  
**License**: MIT