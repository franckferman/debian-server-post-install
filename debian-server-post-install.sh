#!/bin/bash

: '
Debian Server Post-Installation Script

Automates system configuration, hardening, and tooling setup for Debian servers with profile-based defaults and safe security configurations.
Designed for Debian Server, but can be used on Debian and Ubuntu Server distributions.
For Ubuntu Desktop, see: github.com/franckferman/ubuntu-post-install

Author  : Franck FERMAN
Created : 16/05/2026
Updated : 16/05/2026
Version : 1.0.0
'


# ----------------------------------------------
# URLs
# ----------------------------------------------
URL_OHMYZSH="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
URL_VIM_PLUG="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
URL_POWERLEVEL10K="https://github.com/romkatv/powerlevel10k.git"
URL_PLUGIN_AUTOSUGGESTIONS="https://github.com/zsh-users/zsh-autosuggestions"
URL_PLUGIN_SYNTAX_HIGHLIGHTING="https://github.com/zsh-users/zsh-syntax-highlighting"
URL_PLUGIN_COMPLETIONS="https://github.com/zsh-users/zsh-completions"
URL_LAZYVIM="https://github.com/LazyVim/starter"
URL_NERD_FONTS_API="https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest"
URL_DOCKER_GPG="https://download.docker.com/linux/debian/gpg"
URL_HASHICORP_GPG="https://apt.releases.hashicorp.com/gpg"
URL_MULLVAD="https://mullvad.net/download/app/deb/latest"
URL_MULLVAD_KEYRING="https://repository.mullvad.net/deb/mullvad-keyring.asc"
URL_MULLVAD_REPO="https://repository.mullvad.net/deb/stable"
URL_MULLVAD_GITHUB_API="https://api.github.com/repos/mullvad/mullvadvpn-app/releases/latest"

# ----------------------------------------------
# Output Symbols
# ----------------------------------------------
USE_EMOJIS=true
ICON_INFO=""
ICON_OK=""
ICON_SKIP=""
ICON_WARN=""
ICON_ERR=""
SEPARATOR="-----------------------------"
SELECTED_STEPS=""
SERVER_PROFILE="default"
EDITOR_MODE="both"
VIM_PRESET="full"
COLOR_SCHEME="dark"
VIM_COLORSCHEME="desert"
FIREWALL="ufw"
FIREWALL_PROFILE="hardened"
ALLOW_SSH=true
HARDENING_PROFILE="server"
KEEP_AVAHI=false
KEEP_CUPS=false
LOCK_ROOT=false
INSTALL_FAIL2BAN=true
INSTALL_USBGUARD=false
HARDEN_SERVICES=true
HARDEN_PACKAGES=true
HARDEN_NETWORK=true
DISABLE_IPV6=true
DISABLE_ICMP_REDIRECTS=false
DISABLE_SOURCE_ROUTING=false
DISABLE_MARTIANS_LOGGING=true
DISABLE_ICMP_PROTECTION=false
DISABLE_TCP_PROTECTION=false
DISABLE_ANTISPOOFING=true
DISABLE_CONNECTION_LIMITS=true
DISABLE_MODERN_SECURITY=true
DISABLE_KEXEC=false
SKIP_SERVICES=""
SKIP_PACKAGES=""
CUSTOM_SERVICES_LIST=""
CUSTOM_PACKAGES_LIST=""
_LOCK_ROOT_EXPLICIT=false
_USBGUARD_EXPLICIT=false
_EDITOR_MODE_EXPLICIT=false
_FIREWALL_EXPLICIT=false
_FIREWALL_PROFILE_EXPLICIT=false
_VIM_PRESET_EXPLICIT=false
_HARDEN_NETWORK_EXPLICIT=false
APPS_PROFILE="default"
EXTRA_PACKAGES=""
SKIP_APT_PACKAGES=""
INSTALL_DOCKER=false
DOCKER_COMPOSE=true
DOCKER_TYPE="io"
INSTALL_MONITORING=true
ENABLE_LOGGING=true
CLEAR_BASH_HISTORY=true
ZSH_PLUGINS_PROFILE="default"
P10K_PRESET="classic"
P10K_CUSTOM=true
P10K_SEGMENTS=false
INSTALL_MULLVAD=false
MULLVAD_SOURCE="apt"
_MULLVAD_SOURCE_EXPLICIT=false
INSTALL_NERD_FONTS=false
NERD_FONTS_PROFILE="default"
EXTRA_REPOS=""
SKIP_EXTRAS=""
ENABLE_SSH_HARDENING=true
ALLOW_ROOT=false
SSH_PORT=22
SSH_KEY_ONLY=false
DISABLE_ROOT_SSH=false
SSH_IPV6_ENABLED=true
SSH_IPV4_ENABLED=true
SSH_LISTEN_ADDRESSES=""
SSH_MODERN_ONLY=false
SSH_RSA_DISABLED=false

log_section() {
    echo "$SEPARATOR"
    echo "${ICON_INFO} $1"
    echo "$SEPARATOR"
}

_init_symbols() {
    if $USE_EMOJIS; then
        ICON_INFO="ℹ️ "
        ICON_OK="✅"
        ICON_SKIP="➡️ "
        ICON_WARN="⚠️ "
        ICON_ERR="❌"
    else
        ICON_INFO="[*]"
        ICON_OK="[+]"
        ICON_SKIP="[=]"
        ICON_WARN="[!]"
        ICON_ERR="[x]"
    fi
}

show_help() {
    # Print usage information and exit.
    cat << EOF
Debian Server Post-Installation Script v1.0.0
Automates system configuration, hardening, and tooling setup for Debian servers with profile-based defaults and safe security configurations.

Supported distributions:
  - Debian (11/12/testing)
  - Ubuntu Server (20.04/22.04/24.04)
  - Other Debian derivatives

Usage:
  $(basename "$0") [options]

Options:
  -h, --help           Show this help message and exit.
  --no-emojis          Use plain text prefixes instead of emoji output symbols.
  --steps <spec>       Run only the specified steps (default: all).
                       Accepts numbers, ranges, and combinations:
                         --steps 1           Run step 1 only.
                         --steps 1,2,4       Run steps 1, 2, and 4.
                         --steps 2-8         Run steps 2 through 8.
                         --steps 1,3-12      Run step 1 and steps 3 through 12.
  --server-profile <p> Server deployment profile (default: default).
                       Sets intelligent defaults for editor, firewall, and hardening:
                         default   Balanced configuration for general use
                         prod      Production-ready with performance focus
                         dev       Development-friendly with convenience
                         minimal   Lightweight, essential tools only
                         hardened  Maximum security, minimal attack surface
  --editor <mode>      Select which editor(s) to install (default: both).
                         both    Install Vim config and LazyVim (Neovim).
                         vim     Install Vim config only.
                         neovim  Install LazyVim only.
                         none    Skip editor installation entirely.
  --firewall <engine>    Firewall engine to configure (default: ufw).
                         ufw          UFW — simple, recommended for servers.
                         nftables     Native nftables — modern kernel-level firewall.
                         iptables     Legacy iptables — widely known, still supported.
  --firewall-profile <p> Firewall ruleset profile (default: hardened).
                         hardened     Drop all incoming, allow outgoing + established.
                         transparent  Allow all traffic — for testing or trusted networks.
  --allow-root           Allow script execution as root user (typical for VPS fresh install).
  --allow-ssh            Open SSH port (default: enabled for servers).
                         Configurable with --ssh-port.
  --ssh-port <port>      SSH port number (default: 22).
  --ssh-key-only         Disable password authentication, keys only.
  --disable-root-ssh     Disable root SSH login.
  --no-disable-root-ssh  Allow root SSH login (default: enabled for remote access safety).
  --ssh-disable-ipv6     Force SSH to IPv4 only (AddressFamily inet).
  --ssh-disable-ipv4     Force SSH to IPv6 only (AddressFamily inet6).
  --ssh-enable-ipv6      Explicitly enable IPv6 (default: enabled).
  --ssh-enable-ipv4      Explicitly enable IPv4 (default: enabled).
  --ssh-listen-address <ip> Bind SSH to specific IP address (can be used multiple times).
  --ssh-modern-only      Remove legacy SSH options (Protocol 2, etc.).
  --no-ssh-modern-only   Keep legacy SSH compatibility (default: enabled).
  --ssh-rsa              Enable RSA host key for legacy compatibility (default: enabled).
  --no-ssh-rsa           Disable RSA host key for modern clients only.
  --vim-preset <preset>  Vim configuration depth (default: varies by profile).
                         full    vim-plug + gruvbox + NERDTree + airline + extras.
                         minimal gruvbox (native packages) + settings only.
                         bare    Settings only, built-in colorscheme.
  --vim-colorscheme <name>  Built-in vim colorscheme for bare preset (default: desert).
                         Available: blue, darkblue, default, delek, desert, elflord,
                         evening, industry, koehler, morning, murphy, pablo, peachpuff,
                         ron, shine, slate, torte, zellner.
  --hardening-profile <p> Hardening baseline (default: server).
                         server      Server-oriented hardening. Preserves: apache2, bind9,
                                     nginx, postfix, mysql, postgresql. Root lock disabled.
                         workstation Maximum hardening. All non-essential services disabled.
                         enterprise  Conservative. Preserves corporate services. USB controlled.
  --lock-root            Lock the root account (disable password login).
  --no-lock-root         Keep root account unlocked (default: enabled for operational safety).
  --install-usbguard     Install USBGuard (disabled by default for servers).
  --no-install-usbguard  Skip USBGuard installation (default for servers).
  --harden-services      Stop and mask risky services (default: enabled).
  --no-harden-services   Skip stopping and masking risky services.
  --harden-services-list <services> Custom list of services to harden (comma-separated).
                         Overrides profile defaults. Example: --harden-services-list "cups,bluetooth"
  --harden-packages      Remove legacy/insecure packages (default: enabled).
  --no-harden-packages   Skip removing legacy/insecure packages.
  --harden-packages-list <packages> Custom list of packages to remove (comma-separated).
                         Overrides profile defaults. Example: --harden-packages-list "telnet,tftp"
  --no-harden-network    Skip network hardening (sysctl tweaks).
  --disable-ipv6         Disable IPv6 completely (default).
  --no-disable-ipv6      Keep IPv6 enabled with security hardening.
  --disable-icmp-redirects       Disable ICMP redirect protection.
  --no-disable-icmp-redirects    Enable ICMP redirect protection (default).
  --disable-source-routing       Disable source routing protection.
  --no-disable-source-routing    Enable source routing protection (default).
  --disable-martians-logging     Disable martians packet logging (default).
  --no-disable-martians-logging  Enable martians packet logging.
  --disable-icmp-protection      Disable ICMP security protection.
  --no-disable-icmp-protection   Enable ICMP security protection (default).
  --disable-tcp-protection       Disable TCP security protection.
  --no-disable-tcp-protection    Enable TCP security protection (default).
  --disable-antispoofing         Disable anti-spoofing protection (default).
  --no-disable-antispoofing      Enable anti-spoofing protection.
  --disable-connection-limits    Disable connection limits tuning (default).
  --no-disable-connection-limits Enable TCP connection limits tuning.
  --disable-modern-security      Disable modern security features (default).
  --no-disable-modern-security   Enable modern security features.
  --disable-kexec                Allow kexec system call (specialized environments).
  --no-disable-kexec             Disable kexec system call (default, security hardening).
  --skip-services <list> Comma-separated services to keep when hardening.
  --skip-packages <list> Comma-separated packages to keep when hardening.
  --apps-profile <p>     APT package selection profile (default: default).
                         minimal             Survival only: git, curl, vim, fail2ban, tmux (5 pkg).
                         default             Minimal + comfort + infrastructure: wget, zsh, build-essential (26 pkg).
                         server              Default + server mgmt: logrotate, backup, monitoring (35 pkg).
                         minimal-development Server + light dev: python3-dev, make, golang-go (32 pkg).
                         development         Minimal-dev + full stack: nodejs, golang, docker (43 pkg).
                         security            Server + network security: nmap, tcpdump (37 pkg).
                         defense             Security + blue team: lynis, wireshark, aide (45 pkg).
                         offsec              Security + red team: netcat-openbsd (38 pkg).
                         full                Development + Defense + Offsec (55 pkg).
                         enterprise          Full + compliance: auditd, tripwire, ossec (65 pkg).
  --extra-packages <l>   Comma-separated APT packages to add to profile.
  --skip-apt-packages <l> Comma-separated APT packages to remove from profile.
  --install-docker       Force Docker installation.
  --no-docker            Skip Docker installation.
  --no-docker-compose    Skip Docker Compose installation.
  --docker-type <type>   Docker package type (default: io).
                         io  - docker.io (Debian/Ubuntu repos, stable)
                         ce  - docker-ce (Docker official repos, latest)
  --no-monitoring        Skip monitoring tools installation.
  --no-logging           Skip enhanced logging setup.
  --install-mullvad      Install Mullvad VPN client.
  --mullvad-source <m>   Mullvad install method (default: apt with auto-fallback).
                         apt       Official APT repository (most secure).
                         direct    Direct .deb from mullvad.net.
                         github    GitHub releases (third-party CDN).
  --no-mullvad           Skip Mullvad VPN installation.
  --install-nerd-fonts   Install Nerd Fonts for terminal enhancement.
  --nerd-fonts-profile <p> Nerd Fonts selection (default: default).
                         default   FiraCode and JetBrains Mono.
                         minimal   FiraCode only.
                         full      Multiple popular fonts.
  --no-fail2ban          Skip Fail2ban installation.
  --no-ssh-hardening     Skip SSH hardening configuration.
  --extras <l>           Comma-separated extras to install.
                         Available: docker, gh, hashicorp, monitoring, red-team.
  --skip-extras <l>      Extras to exclude from installation.

Steps executed:
  1.  System update          (apt update, full-upgrade, autoclean, autoremove)
  2.  Network & Firewall     (firewall config + network hardening)
  3.  SSH hardening          (secure SSH configuration + key management)
  4.  System hardening       (CIS compliance, sysctl, service hardening)
  5.  Core server packages   (essential server tools)
  6.  Security monitoring    (fail2ban, lynis, intrusion detection)
  7.  Logging & monitoring   (rsyslog, logrotate, monitoring tools)
  8.  Container runtime      (Docker + Docker Compose)
  9.  Vim configuration      (vim-plug + themes + plugins)
  10. Zsh & terminal         (Oh My Zsh + Powerlevel10k + plugins)
  11. Extra software         (additional repos + packages, Mullvad VPN)

Author : Franck FERMAN
EOF
    exit 0
}

parse_step_selection() {
    # Expand a step specification (e.g. "1,3-5,8") into a sorted list of unique integers.
    # Args:    $1 = step spec string.
    # Returns: space-separated list of step numbers, or exits with code 1 on invalid input.

    local input="$1"
    local -a result=()

    IFS=',' read -ra parts <<< "$input"
    for part in "${parts[@]}"; do
        if [[ "$part" =~ ^([0-9]+)-([0-9]+)$ ]]; then
            local start="${BASH_REMATCH[1]}"
            local end="${BASH_REMATCH[2]}"
            if (( start > end )); then
                echo "Invalid range: $part (start must be <= end)."
                exit 1
            fi
            for (( i=start; i<=end; i++ )); do
                result+=("$i")
            done
        elif [[ "$part" =~ ^[0-9]+$ ]]; then
            result+=("$part")
        else
            echo "Invalid step specification: '$part'."
            echo "Run '$(basename "$0") --help' for usage."
            exit 1
        fi
    done

    # Sort and deduplicate
    printf '%s\n' "${result[@]}" | sort -nu | tr '\n' ' '
}

detect_distribution() {
    # Detect the current Debian-based distribution
    # Returns: distribution name and version

    if [[ ! -f /etc/os-release ]]; then
        echo "${ICON_ERR} Cannot detect distribution: /etc/os-release not found."
        exit 1
    fi

    source /etc/os-release

    case "$ID" in
        debian)
            DISTRO="debian"
            DISTRO_VERSION="$VERSION_ID"
            DISTRO_CODENAME="$VERSION_CODENAME"
            ;;
        ubuntu)
            DISTRO="ubuntu"
            DISTRO_VERSION="$VERSION_ID"
            DISTRO_CODENAME="$UBUNTU_CODENAME"
            ;;
        *)
            if [[ "$ID_LIKE" == *"debian"* ]]; then
                DISTRO="debian-like"
                DISTRO_VERSION="$VERSION_ID"
                DISTRO_CODENAME="$VERSION_CODENAME"
                echo "${ICON_WARN} Detected Debian-like distribution: $PRETTY_NAME"
                echo "${ICON_WARN} Proceeding with Debian compatibility mode."
            else
                echo "${ICON_ERR} Unsupported distribution: $PRETTY_NAME"
                echo "${ICON_ERR} This script supports Debian and Ubuntu Server only."
                exit 1
            fi
            ;;
    esac

    echo "${ICON_OK} Detected: $PRETTY_NAME"
}

check_root() {
    # Check if script is run as root (not allowed unless --allow-root)
    if [[ $EUID -eq 0 ]] && ! $ALLOW_ROOT; then
        echo "${ICON_ERR} This script should not be run as root."
        echo "${ICON_ERR} Please run as a regular user with sudo privileges."
        echo "${ICON_ERR} Or use --allow-root flag if you know what you're doing."
        exit 1
    elif [[ $EUID -eq 0 ]] && $ALLOW_ROOT; then
        echo "${ICON_OK} Running as root with --allow-root flag."
    fi
}

check_sudo() {
    # Check if user has sudo privileges
    if ! sudo -n true 2>/dev/null; then
        echo "${ICON_ERR} This script requires sudo privileges."
        echo "${ICON_ERR} Please ensure your user can run sudo commands."
        exit 1
    fi
}

show_banner() {
    # Print ASCII art banner at script startup.

    # Colors for terminal (if supported)
    local RED='\033[0;31m'
    local NC='\033[0m' # No Color

    # Check if terminal supports colors (allow colors in most environments)
    if [[ "${TERM:-}" != "dumb" ]] && command -v tput >/dev/null 2>&1 && [[ $(tput colors 2>/dev/null || echo 0) -ge 8 ]]; then
        # ---[ Display Debian-themed ASCII art banner in red ]---
        echo -e "${RED}                                  _,met\$\$\$\$\$gg.
                               ,g\$\$\$\$\$\$\$\$\$\$\$\$\$\$\$P.
                             ,g\$\$P\"\"       \"\"\"Y\$\$.\".
                            ,\$\$P'              \`\$\$\$.
                          ',\$\$P       ,ggs.     \`\$\$b:
                          \`d\$\$'     ,\$P\"'   .    \$\$\$
                           \$\$P      d\$'     ,    \$\$P
                           \$\$:      \$\$.   -    ,d\$\$'
                           \$\$;      Y\$b._   _,d\$P'
                           Y\$\$.    \`.\`\"Y\$\$\$\$P\"'
                           \`\$\$b      \"-.__
                            \`Y\$\$b
                             \`Y\$\$.
                               \`\$\$b.
                                 \`Y\$\$b.
                                   \`\"Y\$b._
                                       \`\"\"\"\"${NC}

    Debian Server Post-Installation Script v1.0.0
    Security-focused server configuration for Debian-based systems
"
    else
        # Fallback: plain ASCII without colors
        cat << "EOF"
                                  _,met$$$$$gg.
                               ,g$$$$$$$$$$$$$$$P.
                             ,g$$P""       """Y$$.".
                            ,$$P'              `$$$.
                          ',$$P       ,ggs.     `$$b:
                          `d$$'     ,$P"'   .    $$$
                           $$P      d$'     ,    $$P
                           $$:      $$.   -    ,d$$'
                           $$;      Y$b._   _,d$P'
                           Y$$.    `.`"Y$$$$P"'
                           `$$b      "-.__
                            `Y$$b
                             `Y$$.
                               `$$b.
                                 `Y$$b.
                                   `"Y$b._
                                       `""""

    Debian Server Post-Installation Script v1.0.0
    Security-focused server configuration for Debian-based systems

EOF
    fi
}

check_internet_connectivity() {
    # Check internet connectivity by pinging a host (default: 1.1.1.1).
    # Args:    $1 (optional) — host to ping.
    # Returns: 0 if reachable, 1 otherwise.

    local host="${1:-1.1.1.1}"
    ping -c 2 -W 5 "$host" > /dev/null 2>&1
    return $?
}

# Initialize symbols based on emoji preference
_init_symbols

# Exit codes
readonly EXIT_SUCCESS=0
readonly EXIT_ERROR=1
readonly EXIT_INTERRUPT=130

parse_args() {
    # Parse script arguments and set global variables

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                ;;
            --no-emojis)
                USE_EMOJIS=false
                ;;
            --steps)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --steps requires a value (e.g. --steps 1,3-5)."
                    exit 1
                fi
                SELECTED_STEPS="$2"
                shift
                ;;
            --server-profile)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --server-profile requires a value."
                    exit 1
                fi
                case "$2" in
                    default|prod|dev|minimal|hardened) SERVER_PROFILE="$2" ;;
                    *)
                        echo "Error: Invalid server profile '$2'."
                        echo "       Valid profiles:"
                        echo "         default   - Balanced configuration for general use"
                        echo "         prod      - Production-ready with performance focus"
                        echo "         dev       - Development-friendly with convenience"
                        echo "         minimal   - Lightweight, essential tools only"
                        echo "         hardened  - Maximum security, minimal attack surface"
                        exit 1
                        ;;
                esac
                shift
                ;;
            --editor)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --editor requires a value."
                    exit 1
                fi
                case "$2" in
                    both|vim|neovim|none) EDITOR_MODE="$2" ;;
                    *) echo "Error: Invalid editor mode '$2'." ; exit 1 ;;
                esac
                _EDITOR_MODE_EXPLICIT=true
                shift
                ;;
            --vim-preset)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --vim-preset requires a value."
                    exit 1
                fi
                case "$2" in
                    full|minimal|bare) VIM_PRESET="$2" ;;
                    *) echo "Error: Invalid vim preset '$2'." ; exit 1 ;;
                esac
                _VIM_PRESET_EXPLICIT=true
                shift
                ;;
            --vim-colorscheme)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --vim-colorscheme requires a value."
                    exit 1
                fi
                VIM_COLORSCHEME="$2"
                shift
                ;;
            --firewall)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --firewall requires a value."
                    exit 1
                fi
                case "$2" in
                    ufw|nftables|iptables) FIREWALL="$2" ;;
                    *) echo "Error: Invalid firewall engine '$2'." ; exit 1 ;;
                esac
                _FIREWALL_EXPLICIT=true
                shift
                ;;
            --firewall-profile)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --firewall-profile requires a value."
                    exit 1
                fi
                case "$2" in
                    hardened|transparent) FIREWALL_PROFILE="$2" ;;
                    *) echo "Error: Invalid firewall profile '$2'." ; exit 1 ;;
                esac
                _FIREWALL_PROFILE_EXPLICIT=true
                shift
                ;;
            --allow-ssh)
                ALLOW_SSH=true
                ;;
            --allow-root)
                ALLOW_ROOT=true
                ;;
            --ssh-port)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --ssh-port requires a value (e.g. --ssh-port 2222)."
                    exit 1
                fi
                if [[ ! "$2" =~ ^[0-9]+$ ]]; then
                    echo "Error: invalid SSH port '$2'. Expected an integer between 1 and 65535."
                    echo "       Examples: --ssh-port 22, --ssh-port 2222"
                    exit 1
                fi
                if (( $2 < 1 || $2 > 65535 )); then
                    echo "Error: SSH port '$2' is out of valid range."
                    echo "       Expected: integer between 1 and 65535."
                    echo "       Common secure ports: 2222, 2200, 22000"
                    exit 1
                fi
                if (( $2 < 1024 )) && [[ $2 != "22" ]]; then
                    echo "Warning: Port '$2' is in privileged range (< 1024)."
                    echo "         Consider using a port > 1024 for better security."
                fi
                SSH_PORT="$2"
                shift
                ;;
            --ssh-key-only)
                SSH_KEY_ONLY=true
                ;;
            --disable-root-ssh)
                DISABLE_ROOT_SSH=true
                ;;
            --no-disable-root-ssh)
                DISABLE_ROOT_SSH=false
                ;;
            --ssh-disable-ipv6)
                SSH_IPV6_ENABLED=false
                ;;
            --ssh-disable-ipv4)
                SSH_IPV4_ENABLED=false
                ;;
            --ssh-enable-ipv6)
                SSH_IPV6_ENABLED=true
                ;;
            --ssh-enable-ipv4)
                SSH_IPV4_ENABLED=true
                ;;
            --ssh-listen-address)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --ssh-listen-address requires an IP address."
                    exit 1
                fi
                SSH_LISTEN_ADDRESSES="$SSH_LISTEN_ADDRESSES $2"
                shift
                ;;
            --ssh-modern-only)
                SSH_MODERN_ONLY=true
                ;;
            --no-ssh-modern-only)
                SSH_MODERN_ONLY=false
                ;;
            --ssh-rsa)
                SSH_RSA_DISABLED=false
                ;;
            --no-ssh-rsa)
                SSH_RSA_DISABLED=true
                ;;
            --hardening-profile)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --hardening-profile requires a value (server|workstation|enterprise)."
                    exit 1
                fi
                case "$2" in
                    server|workstation|enterprise) HARDENING_PROFILE="$2" ;;
                    *)
                        echo "Error: invalid --hardening-profile value '$2'."
                        echo "       Valid profiles:"
                        echo "         server      - Server-optimized hardening (default)"
                        echo "         workstation - Maximum hardening for desktops"
                        echo "         enterprise  - Conservative hardening for corporate"
                        exit 1
                        ;;
                esac
                shift
                ;;
            --lock-root)
                LOCK_ROOT=true
                _LOCK_ROOT_EXPLICIT=true
                ;;
            --no-lock-root)
                LOCK_ROOT=false
                _LOCK_ROOT_EXPLICIT=true
                ;;
            --install-usbguard)
                INSTALL_USBGUARD=true
                _USBGUARD_EXPLICIT=true
                ;;
            --no-install-usbguard)
                INSTALL_USBGUARD=false
                _USBGUARD_EXPLICIT=true
                ;;
            --harden-services)
                HARDEN_SERVICES=true
                ;;
            --no-harden-services)
                HARDEN_SERVICES=false
                CUSTOM_SERVICES_LIST=""  # Clear custom list if user says NO
                ;;
            --harden-services-list)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --harden-services-list requires a value (comma-separated services)."
                    exit 1
                fi
                CUSTOM_SERVICES_LIST="$2"
                HARDEN_SERVICES=true  # Force enable hardening with custom list
                shift
                ;;
            --harden-packages)
                HARDEN_PACKAGES=true
                ;;
            --no-harden-packages)
                HARDEN_PACKAGES=false
                CUSTOM_PACKAGES_LIST=""  # Clear custom list if user says NO
                ;;
            --harden-packages-list)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --harden-packages-list requires a value (comma-separated packages)."
                    exit 1
                fi
                CUSTOM_PACKAGES_LIST="$2"
                HARDEN_PACKAGES=true  # Force enable hardening with custom list
                shift
                ;;
            --no-harden-network)
                HARDEN_NETWORK=false
                _HARDEN_NETWORK_EXPLICIT=true
                ;;
            --disable-ipv6)
                DISABLE_IPV6=true
                ;;
            --no-disable-ipv6)
                DISABLE_IPV6=false
                ;;
            --disable-icmp-redirects)
                DISABLE_ICMP_REDIRECTS=true
                ;;
            --no-disable-icmp-redirects)
                DISABLE_ICMP_REDIRECTS=false
                ;;
            --disable-source-routing)
                DISABLE_SOURCE_ROUTING=true
                ;;
            --no-disable-source-routing)
                DISABLE_SOURCE_ROUTING=false
                ;;
            --disable-martians-logging)
                DISABLE_MARTIANS_LOGGING=true
                ;;
            --no-disable-martians-logging)
                DISABLE_MARTIANS_LOGGING=false
                ;;
            --disable-icmp-protection)
                DISABLE_ICMP_PROTECTION=true
                ;;
            --no-disable-icmp-protection)
                DISABLE_ICMP_PROTECTION=false
                ;;
            --disable-tcp-protection)
                DISABLE_TCP_PROTECTION=true
                ;;
            --no-disable-tcp-protection)
                DISABLE_TCP_PROTECTION=false
                ;;
            --disable-antispoofing)
                DISABLE_ANTISPOOFING=true
                ;;
            --no-disable-antispoofing)
                DISABLE_ANTISPOOFING=false
                ;;
            --disable-connection-limits)
                DISABLE_CONNECTION_LIMITS=true
                ;;
            --no-disable-connection-limits)
                DISABLE_CONNECTION_LIMITS=false
                ;;
            --disable-modern-security)
                DISABLE_MODERN_SECURITY=true
                ;;
            --no-disable-modern-security)
                DISABLE_MODERN_SECURITY=false
                ;;
            --disable-kexec)
                DISABLE_KEXEC=true
                ;;
            --no-disable-kexec)
                DISABLE_KEXEC=false
                ;;
            --skip-services)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --skip-services requires a value."
                    exit 1
                fi
                SKIP_SERVICES="$2"
                shift
                ;;
            --skip-packages)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --skip-packages requires a value."
                    exit 1
                fi
                SKIP_PACKAGES="$2"
                shift
                ;;
            --apps-profile)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --apps-profile requires a value."
                    exit 1
                fi
                case "$2" in
                    minimal|default|server|minimal-development|development|security|defense|offsec|full|enterprise) APPS_PROFILE="$2" ;;
                    *)
                        echo "Error: invalid --apps-profile value '$2'."
                        echo "       Valid profiles:"
                        echo "         minimal             - Essential tools only (git, vim, curl, tmux)"
                        echo "         default             - Minimal + infrastructure tools (python, build)"
                        echo "         server              - Default + server management tools"
                        echo "         minimal-development - Server + light dev tools (python-dev, make)"
                        echo "         development         - Minimal-dev + full stack (node, golang, docker)"
                        echo "         security            - Server + general security tools (nmap, tcpdump)"
                        echo "         defense             - Security + blue team tools (lynis, wireshark)"
                        echo "         offsec              - Security + red team tools (netcat, etc.)"
                        echo "         full                - Development + Defense + Offsec (everything)"
                        echo "         enterprise          - Full + enterprise tools (compliance, audit)"
                        exit 1
                        ;;
                esac
                shift
                ;;
            --extra-packages)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --extra-packages requires a comma-separated list of package names."
                    echo "       Example: --extra-packages htop,ncdu,jq,bat"
                    exit 1
                fi
                # Validate package names (basic check)
                if [[ ! "$2" =~ ^[a-zA-Z0-9._+-]+(,[a-zA-Z0-9._+-]+)*$ ]]; then
                    echo "Error: invalid package names in '$2'."
                    echo "       Package names should contain only letters, numbers, dots, hyphens, plus signs."
                    echo "       Example: --extra-packages htop,ncdu,jq"
                    exit 1
                fi
                EXTRA_PACKAGES="$2"
                shift
                ;;
            --skip-apt-packages)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --skip-apt-packages requires a comma-separated list of package names."
                    echo "       Example: --skip-apt-packages taskwarrior,rssguard"
                    exit 1
                fi
                # Validate package names
                if [[ ! "$2" =~ ^[a-zA-Z0-9._+-]+(,[a-zA-Z0-9._+-]+)*$ ]]; then
                    echo "Error: invalid package names in '$2'."
                    echo "       Package names should contain only letters, numbers, dots, hyphens, plus signs."
                    exit 1
                fi
                SKIP_APT_PACKAGES="$2"
                shift
                ;;
            --install-docker)
                INSTALL_DOCKER=true
                ;;
            --no-docker)
                INSTALL_DOCKER=false
                ;;
            --no-docker-compose)
                DOCKER_COMPOSE=false
                ;;
            --docker-type)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --docker-type requires a value."
                    exit 1
                fi
                case "$2" in
                    io|ce)
                        DOCKER_TYPE="$2"
                        INSTALL_DOCKER=true  # Auto-enable Docker when type specified
                        ;;
                    *)
                        echo "Error: Invalid docker type '$2'."
                        echo "       Valid types:"
                        echo "         io  - docker.io (Debian/Ubuntu repos, stable)"
                        echo "         ce  - docker-ce (Docker official repos, latest)"
                        exit 1
                        ;;
                esac
                shift
                ;;
            --no-monitoring)
                INSTALL_MONITORING=false
                ;;
            --no-logging)
                ENABLE_LOGGING=false
                ;;
            --no-fail2ban)
                INSTALL_FAIL2BAN=false
                ;;
            --no-ssh-hardening)
                ENABLE_SSH_HARDENING=false
                ;;
            --install-mullvad)
                INSTALL_MULLVAD=true
                ;;
            --mullvad-source)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --mullvad-source requires a value (apt|direct|github)."
                    exit 1
                fi
                case "$2" in
                    apt|direct|github)
                        MULLVAD_SOURCE="$2"
                        _MULLVAD_SOURCE_EXPLICIT=true
                        ;;
                    *)
                        echo "Error: invalid --mullvad-source value '$2'."
                        echo "       Valid sources:"
                        echo "         apt     - Official APT repository (most secure)"
                        echo "         direct  - Direct .deb download from mullvad.net"
                        echo "         github  - GitHub releases (third-party CDN)"
                        exit 1
                        ;;
                esac
                shift
                ;;
            --no-mullvad)
                INSTALL_MULLVAD=false
                ;;
            --install-nerd-fonts)
                INSTALL_NERD_FONTS=true
                ;;
            --nerd-fonts-profile)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --nerd-fonts-profile requires a value (default|minimal|full)."
                    exit 1
                fi
                case "$2" in
                    default|minimal|full) NERD_FONTS_PROFILE="$2" ;;
                    *)
                        echo "Error: invalid --nerd-fonts-profile value '$2'."
                        echo "       Valid profiles:"
                        echo "         default  - FiraCode and JetBrains Mono"
                        echo "         minimal  - FiraCode only"
                        echo "         full     - Multiple popular fonts"
                        exit 1
                        ;;
                esac
                shift
                ;;
            --extras)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --extras requires a comma-separated list."
                    echo "       Example: --extras gh,hashicorp,monitoring"
                    exit 1
                fi
                EXTRA_REPOS="$2"
                shift
                ;;
            --skip-extras)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --skip-extras requires a comma-separated list."
                    echo "       Example: --skip-extras podman,azurecli"
                    exit 1
                fi
                SKIP_EXTRAS="$2"
                shift
                ;;
            *)
                echo "Error: Unknown option '$1'."
                echo "Run '$(basename "$0") --help' for usage."
                exit 1
                ;;
        esac
        shift
    done
}

# ==============================================
# STEP FUNCTIONS
# ==============================================

step_01_system_update() {
    # Step 1: System update
    log_section "Step 1: System update process initiated."

    if check_internet_connectivity; then
        echo "${ICON_OK} Internet connectivity confirmed. Proceeding with system updates..."

        echo "${ICON_OK} Updating package lists (apt update)..."
        sudo apt update

        echo "${ICON_OK} Configuring debconf for non-interactive installation..."
        echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections
        sudo dpkg-reconfigure -f noninteractive debconf

        echo "${ICON_OK} Upgrading all packages (apt full-upgrade)..."
        DEBIAN_FRONTEND=noninteractive sudo apt full-upgrade -y

        echo "${ICON_OK} Cleaning up package cache (apt autoclean)..."
        sudo apt autoclean -y

        echo "${ICON_OK} Removing unused packages (apt autoremove)..."
        sudo apt autoremove -y

        echo "${ICON_OK} System update process completed successfully."
    else
        echo "${ICON_WARN} Skipping system update: No internet connection detected."
    fi
}

step_02_network_firewall() {
    # Step 2: Network & Firewall configuration
    log_section "Step 2: Network & Firewall hardening."

    # Disable all firewalls first for clean state
    _fw_disable_all

    case "$FIREWALL" in
        ufw)
            _fw_configure_ufw
            ;;
        nftables)
            _fw_configure_nftables
            ;;
        iptables)
            _fw_configure_iptables
            ;;
    esac

    if $HARDEN_NETWORK; then
        _configure_network_hardening
    fi

    echo "${ICON_OK} Network and firewall configuration completed."
}

step_03_ssh_hardening() {
    # Step 3: SSH hardening
    log_section "Step 3: SSH hardening and configuration."

    if ! $ENABLE_SSH_HARDENING; then
        echo "${ICON_SKIP} Skipping SSH hardening (disabled by user)."
        return
    fi

    # Backup original SSH config
    if [[ ! -f /etc/ssh/sshd_config.backup ]]; then
        echo "${ICON_OK} Backing up original SSH configuration..."
        sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
    fi

    echo "${ICON_OK} Applying SSH hardening configuration..."

    # Determine AddressFamily based on IPv4/IPv6 settings
    if $SSH_IPV4_ENABLED && $SSH_IPV6_ENABLED; then
        ADDRESS_FAMILY="any"
    elif $SSH_IPV4_ENABLED && ! $SSH_IPV6_ENABLED; then
        ADDRESS_FAMILY="inet"
    elif ! $SSH_IPV4_ENABLED && $SSH_IPV6_ENABLED; then
        ADDRESS_FAMILY="inet6"
    else
        echo "${ICON_ERR} Error: At least IPv4 or IPv6 must be enabled for SSH."
        exit 1
    fi

    # Create hardened SSH config
    sudo tee /etc/ssh/sshd_config.d/99-hardening.conf << EOF
# SSH Hardening Configuration
# Generated by debian-server-post-install.sh

# Network settings
Port $SSH_PORT
AddressFamily $ADDRESS_FAMILY
$(if [[ -n "$SSH_LISTEN_ADDRESSES" ]]; then
    for addr in $SSH_LISTEN_ADDRESSES; do
        echo "ListenAddress $addr"
    done
else
    case $ADDRESS_FAMILY in
        "any")
            echo "# ListenAddress 0.0.0.0    # All IPv4 interfaces (default)"
            echo "# ListenAddress ::          # All IPv6 interfaces (default)"
            ;;
        "inet")
            echo "ListenAddress 0.0.0.0      # All IPv4 interfaces"
            ;;
        "inet6")
            echo "ListenAddress ::            # All IPv6 interfaces"
            ;;
    esac
fi)

# Security settings
$(if ! $SSH_MODERN_ONLY; then
    echo "# Protocol 2 - Legacy compatibility (OpenSSH ignores if not supported)"
    echo "# Kept for compatibility with very old SSH clients and explicit security intent"
    echo "Protocol 2"
    echo ""
fi)
# Host keys in preference order (best to legacy)
HostKey /etc/ssh/ssh_host_ed25519_key  # Modern, fast, recommended
HostKey /etc/ssh/ssh_host_ecdsa_key    # Good compromise, widely supported
$(if ! $SSH_RSA_DISABLED; then
    echo "HostKey /etc/ssh/ssh_host_rsa_key      # Legacy fallback for old clients"
fi)

# Authentication - VPS-safe defaults to prevent lockout
PermitRootLogin $(if $DISABLE_ROOT_SSH; then echo "no"; else echo "yes"; fi)  # Emergency access for VPS
PasswordAuthentication $(if $SSH_KEY_ONLY; then echo "no"; else echo "yes"; fi)  # Flexible auth methods
PubkeyAuthentication yes                   # Preferred authentication method
AuthorizedKeysFile .ssh/authorized_keys   # Standard key location
PermitEmptyPasswords no                    # Security: never allow empty passwords
KbdInteractiveAuthentication no            # Disable interactive prompts (was ChallengeResponseAuthentication)
UsePAM yes                                 # Enable PAM for system integration

# Session settings - hardened for server environments
X11Forwarding no                           # Security: prevent X11 GUI forwarding (servers don't need GUI)
PrintMotd no                               # Disable message-of-day (handled by system, avoid info leak)
TCPKeepAlive yes                           # Enable TCP keepalive to detect broken network connections
ClientAliveInterval 300                    # Send keepalive packets every 5 minutes to detect dead clients
ClientAliveCountMax 2                      # Allow 2 missed keepalives = 10 min timeout for unresponsive clients

# Security limits - protect against brute force attacks and resource exhaustion
MaxAuthTries 3                             # Max 3 auth attempts per connection (prevent password brute force)
MaxSessions 2                              # Max 2 concurrent sessions per TCP connection (prevent session flooding)
MaxStartups 10:30:100                      # Connection rate limiting: 10 unauthenticated, start dropping at 30, max 100
LoginGraceTime 30                          # Max 30 seconds to complete authentication (prevent connection hanging)

# Disable unused features - reduce attack surface for server environments
AllowAgentForwarding no                    # Security: disable SSH agent forwarding (prevent key theft)
AllowTcpForwarding no                      # Security: disable port forwarding/tunneling (prevent pivot attacks)
GatewayPorts no                            # Security: disable remote port forwarding binding (prevent exposure)
PermitTunnel no                            # Security: disable tun/tap device forwarding (prevent VPN bypass)
PermitUserEnvironment no                   # Security: ignore user environment files (prevent privilege escalation)
EOF

    # Generate new SSH host keys if needed
    echo "${ICON_OK} Generating fresh SSH host keys..."
    sudo ssh-keygen -A

    # Test SSH configuration
    if sudo sshd -t; then
        echo "${ICON_OK} SSH configuration test passed."
        sudo systemctl restart ssh
        echo "${ICON_OK} SSH service restarted with hardened configuration."

        if [[ $SSH_PORT != "22" ]]; then
            echo "${ICON_WARN} SSH is now running on port $SSH_PORT"
            echo "${ICON_WARN} Update your firewall and connections accordingly."
        fi
    else
        echo "${ICON_ERR} SSH configuration test failed!"
        sudo cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config
        sudo systemctl restart ssh
        echo "${ICON_ERR} Restored original SSH configuration."
    fi
}

step_04_system_hardening() {
    # Step 4: System hardening
    log_section "Step 4: System hardening (CIS compliance)."

    # Apply hardening profile defaults
    _apply_hardening_profile

    # Lock root account if requested
    if $LOCK_ROOT; then
        echo "${ICON_OK} Locking root account..."
        sudo passwd -l root
    else
        echo "${ICON_SKIP} Keeping root account unlocked (server profile default)."
    fi

    # Install USBGuard if requested
    if $INSTALL_USBGUARD; then
        echo "${ICON_OK} Installing USBGuard..."
        DEBIAN_FRONTEND=noninteractive sudo apt install -y usbguard usbguard-applet-qt
        sudo usbguard generate-policy | sudo tee /etc/usbguard/rules.conf > /dev/null
        sudo systemctl enable usbguard
        sudo systemctl start usbguard
    else
        echo "${ICON_SKIP} Skipping USBGuard installation."
    fi

    # Harden services
    if $HARDEN_SERVICES; then
        _harden_services
    fi

    # Remove insecure packages
    if $HARDEN_PACKAGES; then
        _harden_packages
    fi

    # Apply sysctl hardening
    _apply_sysctl_hardening

    echo "${ICON_OK} System hardening completed."
}

# ==============================================
# FIREWALL HELPER FUNCTIONS
# ==============================================

_fw_disable_all() {
    # Disable all firewalls for clean state
    echo "${ICON_OK} Disabling existing firewall configurations..."

    if command -v ufw &>/dev/null; then
        sudo ufw --force disable 2>/dev/null || true
    fi

    if systemctl is-active --quiet nftables 2>/dev/null; then
        sudo systemctl stop nftables
        sudo systemctl disable nftables
    fi

    if command -v iptables &>/dev/null; then
        sudo iptables -F
        sudo iptables -X
        sudo iptables -Z
        sudo iptables -P INPUT ACCEPT
        sudo iptables -P FORWARD ACCEPT
        sudo iptables -P OUTPUT ACCEPT
    fi

    if command -v ip6tables &>/dev/null; then
        sudo ip6tables -F
        sudo ip6tables -X
        sudo ip6tables -Z
        sudo ip6tables -P INPUT ACCEPT
        sudo ip6tables -P FORWARD ACCEPT
        sudo ip6tables -P OUTPUT ACCEPT
    fi
}

_fw_configure_ufw() {
    # Configure UFW firewall
    echo "${ICON_OK} Configuring UFW firewall..."

    if ! command -v ufw &>/dev/null; then
        echo "${ICON_OK} Installing UFW..."
        DEBIAN_FRONTEND=noninteractive sudo apt install -y ufw
    fi

    case "$FIREWALL_PROFILE" in
        hardened)
            sudo ufw --force reset
            sudo ufw default deny incoming
            sudo ufw default allow outgoing

            if $ALLOW_SSH; then
                sudo ufw allow $SSH_PORT/tcp comment 'SSH'
                echo "${ICON_OK} SSH port $SSH_PORT allowed."
            fi
            ;;
        transparent)
            sudo ufw --force reset
            sudo ufw default allow incoming
            sudo ufw default allow outgoing
            echo "${ICON_OK} UFW configured in transparent mode."
            ;;
    esac

    sudo ufw --force enable
    sudo systemctl enable ufw
    echo "${ICON_OK} UFW enabled and configured."
}

_fw_configure_nftables() {
    # Configure nftables firewall
    echo "${ICON_OK} Configuring nftables firewall..."

    if ! command -v nft &>/dev/null; then
        echo "${ICON_OK} Installing nftables..."
        DEBIAN_FRONTEND=noninteractive sudo apt install -y nftables
    fi

    case "$FIREWALL_PROFILE" in
        hardened)
            sudo tee /etc/nftables.conf > /dev/null << EOF
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;

        # Allow loopback
        iif lo accept

        # Allow established and related connections
        ct state established,related accept

        # Allow SSH if enabled
$(if $ALLOW_SSH; then echo "        tcp dport $SSH_PORT accept"; fi)

        # Drop everything else
        drop
    }

    chain forward {
        type filter hook forward priority 0; policy drop;
    }

    chain output {
        type filter hook output priority 0; policy accept;
    }
}
EOF
            ;;
        transparent)
            sudo tee /etc/nftables.conf > /dev/null << EOF
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0; policy accept;
    }

    chain forward {
        type filter hook forward priority 0; policy accept;
    }

    chain output {
        type filter hook output priority 0; policy accept;
    }
}
EOF
            ;;
    esac

    sudo systemctl enable nftables
    sudo systemctl start nftables
    echo "${ICON_OK} nftables enabled and configured."
}

_fw_configure_iptables() {
    # Configure iptables firewall
    echo "${ICON_OK} Configuring iptables firewall..."

    if ! command -v iptables &>/dev/null; then
        echo "${ICON_OK} Installing iptables..."
        DEBIAN_FRONTEND=noninteractive sudo apt install -y iptables iptables-persistent
    fi

    case "$FIREWALL_PROFILE" in
        hardened)
            # Flush existing rules
            sudo iptables -F
            sudo iptables -X
            sudo iptables -Z

            # Default policies
            sudo iptables -P INPUT DROP
            sudo iptables -P FORWARD DROP
            sudo iptables -P OUTPUT ACCEPT

            # Allow loopback
            sudo iptables -A INPUT -i lo -j ACCEPT

            # Allow established and related connections
            sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

            # Allow SSH if enabled
            if $ALLOW_SSH; then
                sudo iptables -A INPUT -p tcp --dport $SSH_PORT -j ACCEPT
            fi

            # IPv6 rules
            sudo ip6tables -P INPUT DROP
            sudo ip6tables -P FORWARD DROP
            sudo ip6tables -P OUTPUT ACCEPT
            sudo ip6tables -A INPUT -i lo -j ACCEPT
            sudo ip6tables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

            if $ALLOW_SSH; then
                sudo ip6tables -A INPUT -p tcp --dport $SSH_PORT -j ACCEPT
            fi
            ;;
        transparent)
            sudo iptables -P INPUT ACCEPT
            sudo iptables -P FORWARD ACCEPT
            sudo iptables -P OUTPUT ACCEPT
            sudo ip6tables -P INPUT ACCEPT
            sudo ip6tables -P FORWARD ACCEPT
            sudo ip6tables -P OUTPUT ACCEPT
            ;;
    esac

    # Save rules
    sudo netfilter-persistent save
    sudo systemctl enable netfilter-persistent
    echo "${ICON_OK} iptables configured and rules saved."
}

# ==============================================
# HARDENING HELPER FUNCTIONS
# ==============================================

_apply_server_profile() {
    # Apply server profile defaults (can be overridden by command line flags)
    echo "${ICON_OK} Applying server profile: $SERVER_PROFILE"

    case "$SERVER_PROFILE" in
        default)
            # Balanced configuration for general use
            if ! $_EDITOR_MODE_EXPLICIT; then EDITOR_MODE="both"; fi
            if ! $_FIREWALL_EXPLICIT; then FIREWALL="ufw"; fi
            if ! $_FIREWALL_PROFILE_EXPLICIT; then FIREWALL_PROFILE="hardened"; fi
            if ! $_VIM_PRESET_EXPLICIT; then VIM_PRESET="minimal"; fi
            INSTALL_MONITORING=true
            ENABLE_LOGGING=true
            INSTALL_DOCKER=false
            INSTALL_FAIL2BAN=true
            APPS_PROFILE="server"
            ;;
        prod)
            # Production-ready with performance focus
            if ! $_EDITOR_MODE_EXPLICIT; then EDITOR_MODE="both"; fi
            if ! $_FIREWALL_EXPLICIT; then FIREWALL="nftables"; fi
            if ! $_FIREWALL_PROFILE_EXPLICIT; then FIREWALL_PROFILE="hardened"; fi
            if ! $_VIM_PRESET_EXPLICIT; then VIM_PRESET="minimal"; fi
            INSTALL_MONITORING=true
            ENABLE_LOGGING=true
            INSTALL_DOCKER=true
            DOCKER_COMPOSE=true
            INSTALL_FAIL2BAN=true
            ENABLE_SSH_HARDENING=true
            APPS_PROFILE="server"
            ;;
        dev)
            # Development-friendly with convenience
            if ! $_EDITOR_MODE_EXPLICIT; then EDITOR_MODE="both"; fi
            if ! $_FIREWALL_EXPLICIT; then FIREWALL="ufw"; fi
            if ! $_FIREWALL_PROFILE_EXPLICIT; then FIREWALL_PROFILE="transparent"; fi
            if ! $_VIM_PRESET_EXPLICIT; then VIM_PRESET="full"; fi
            if ! $_HARDEN_NETWORK_EXPLICIT; then HARDEN_NETWORK=false; fi
            INSTALL_MONITORING=false
            ENABLE_LOGGING=false
            INSTALL_DOCKER=true
            DOCKER_COMPOSE=true
            INSTALL_FAIL2BAN=true
            INSTALL_NERD_FONTS=true
            APPS_PROFILE="full"
            ;;
        minimal)
            # Lightweight, essential tools only
            if ! $_EDITOR_MODE_EXPLICIT; then EDITOR_MODE="vim"; fi
            if ! $_FIREWALL_EXPLICIT; then FIREWALL="ufw"; fi
            if ! $_FIREWALL_PROFILE_EXPLICIT; then FIREWALL_PROFILE="hardened"; fi
            if ! $_VIM_PRESET_EXPLICIT; then VIM_PRESET="minimal"; fi
            INSTALL_MONITORING=false
            ENABLE_LOGGING=false
            INSTALL_DOCKER=false
            DOCKER_COMPOSE=false
            INSTALL_FAIL2BAN=true
            INSTALL_NERD_FONTS=false
            APPS_PROFILE="minimal"
            ;;
        hardened)
            # Maximum security, minimal attack surface
            if ! $_EDITOR_MODE_EXPLICIT; then EDITOR_MODE="vim"; fi
            if ! $_FIREWALL_EXPLICIT; then FIREWALL="nftables"; fi
            if ! $_FIREWALL_PROFILE_EXPLICIT; then FIREWALL_PROFILE="hardened"; fi
            if ! $_VIM_PRESET_EXPLICIT; then VIM_PRESET="bare"; fi
            if ! $_LOCK_ROOT_EXPLICIT; then LOCK_ROOT=true; fi
            if ! $_USBGUARD_EXPLICIT; then INSTALL_USBGUARD=true; fi

            # SSH stays VPS-safe even in hardened mode
            # Use --ssh-key-only and --disable-root-ssh flags for explicit hardening
            INSTALL_MONITORING=true
            ENABLE_LOGGING=true
            INSTALL_DOCKER=false
            INSTALL_FAIL2BAN=true
            HARDEN_SERVICES=true
            HARDEN_PACKAGES=true
            HARDENING_PROFILE="server"
            APPS_PROFILE="defense"
            ;;
    esac
}

_apply_hardening_profile() {
    # Apply hardening profile-specific settings
    echo "${ICON_OK} Applying hardening profile: $HARDENING_PROFILE"

    case "$HARDENING_PROFILE" in
        server)
            # Server profile: preserve essential server services
            if ! $_LOCK_ROOT_EXPLICIT; then LOCK_ROOT=false; fi
            if ! $_USBGUARD_EXPLICIT; then INSTALL_USBGUARD=false; fi
            if ! $_HARDEN_NETWORK_EXPLICIT; then HARDEN_NETWORK=true; fi
            ;;
        workstation)
            # Workstation profile: maximum hardening
            # Note: LOCK_ROOT stays false by default for operational safety
            # Use --lock-root flag to explicitly lock root account
            if ! $_USBGUARD_EXPLICIT; then INSTALL_USBGUARD=true; fi
            if ! $_HARDEN_NETWORK_EXPLICIT; then HARDEN_NETWORK=true; fi
            ;;
        enterprise)
            # Enterprise profile: conservative hardening
            if ! $_LOCK_ROOT_EXPLICIT; then LOCK_ROOT=false; fi
            if ! $_USBGUARD_EXPLICIT; then INSTALL_USBGUARD=true; fi
            if ! $_HARDEN_NETWORK_EXPLICIT; then HARDEN_NETWORK=true; fi
            ;;
    esac
}

_configure_network_hardening() {
    # Apply network-level hardening
    echo "${ICON_OK} Applying network hardening..."

    # IPv6 configuration - commented by default for safety
    if $DISABLE_IPV6; then
        # Default: All IPv6 settings commented (safe, no changes)
        echo "# IPv6 configuration (use --no-disable-ipv6 to enable hardening)" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "# To disable IPv6 completely, uncomment these lines:" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "# net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "# net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
    else
        # Explicit activation: IPv6 hardening enabled
        echo "# IPv6 security hardening (enabled with --no-disable-ipv6)" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "net.ipv6.conf.all.accept_redirects = 0" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "net.ipv6.conf.default.accept_redirects = 0" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "net.ipv6.conf.all.accept_ra = 0" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "net.ipv6.conf.default.accept_ra = 0" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
    fi

    # ICMP Redirects protection (active by default)
    if $DISABLE_ICMP_REDIRECTS; then
        # Disabled: ICMP redirect protection commented
        echo "# ICMP redirects protection (disabled with --disable-icmp-redirects)" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "# net.ipv4.conf.all.send_redirects = 0" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "# net.ipv4.conf.default.send_redirects = 0" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "# net.ipv4.conf.all.accept_redirects = 0" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "# net.ipv4.conf.default.accept_redirects = 0" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
    else
        # Default: ICMP redirect protection enabled
        echo "# ICMP redirects protection (default enabled)" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "net.ipv4.conf.all.send_redirects = 0" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "net.ipv4.conf.default.send_redirects = 0" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "net.ipv4.conf.all.accept_redirects = 0" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "net.ipv4.conf.default.accept_redirects = 0" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
    fi

    # Source routing protection (active by default)
    if $DISABLE_SOURCE_ROUTING; then
        # Disabled: Source routing protection commented
        echo "# Source routing protection (disabled with --disable-source-routing)" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "# net.ipv4.conf.all.accept_source_route = 0" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "# net.ipv4.conf.default.accept_source_route = 0" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
    else
        # Default: Source routing protection enabled
        echo "# Source routing protection (default enabled)" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "net.ipv4.conf.all.accept_source_route = 0" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "net.ipv4.conf.default.accept_source_route = 0" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
    fi

    # Martians logging (commented by default)
    if $DISABLE_MARTIANS_LOGGING; then
        # Default: Martians logging commented (avoid log verbosity)
        echo "# Martians logging (use --no-disable-martians-logging to activate)" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "# net.ipv4.conf.all.log_martians = 1" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "# net.ipv4.conf.default.log_martians = 1" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
    else
        # Enabled: Martians logging active
        echo "# Martians logging (enabled with --no-disable-martians-logging)" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "net.ipv4.conf.all.log_martians = 1" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "net.ipv4.conf.default.log_martians = 1" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
    fi

    # ICMP protection (active by default)
    if $DISABLE_ICMP_PROTECTION; then
        # Disabled: ICMP protection commented
        echo "# ICMP protection (disabled with --disable-icmp-protection)" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "# net.ipv4.icmp_ignore_bogus_error_responses = 1" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "# net.ipv4.icmp_echo_ignore_broadcasts = 1" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
    else
        # Default: ICMP protection enabled
        echo "# ICMP protection (default enabled)" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "net.ipv4.icmp_ignore_bogus_error_responses = 1" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
    fi

    # TCP protection (active by default)
    if $DISABLE_TCP_PROTECTION; then
        # Disabled: TCP protection commented
        echo "# TCP protection (disabled with --disable-tcp-protection)" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "# net.ipv4.tcp_syncookies = 1" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
    else
        # Default: TCP protection enabled
        echo "# TCP protection (default enabled)" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "net.ipv4.tcp_syncookies = 1" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
    fi

    # Anti-spoofing protection (commented by default)
    if $DISABLE_ANTISPOOFING; then
        # Default: Anti-spoofing commented (VLAN/complex network safe)
        echo "# Anti-spoofing protection (use --no-disable-antispoofing to activate)" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "# net.ipv4.conf.all.rp_filter = 1" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "# net.ipv4.conf.default.rp_filter = 1" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
    else
        # Enabled: Anti-spoofing protection active
        echo "# Anti-spoofing protection (enabled with --no-disable-antispoofing)" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "net.ipv4.conf.all.rp_filter = 1" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "net.ipv4.conf.default.rp_filter = 1" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
    fi

    # Connection limits tuning (commented by default)
    if $DISABLE_CONNECTION_LIMITS; then
        # Default: Connection limits commented (performance safe)
        echo "# Connection limits tuning (use --no-disable-connection-limits to activate)" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "# net.core.somaxconn = 1024" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "# net.ipv4.tcp_max_syn_backlog = 2048" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
    else
        # Enabled: Connection limits tuning active
        echo "# Connection limits tuning (enabled with --no-disable-connection-limits)" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "net.core.somaxconn = 1024" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "net.ipv4.tcp_max_syn_backlog = 2048" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
    fi

    # Modern security features (commented by default)
    if $DISABLE_MODERN_SECURITY; then
        # Default: Modern security commented (Proxmox/Docker safe)
        echo "# Modern security features (use --no-disable-modern-security to activate)" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "# WARNING: forwarding=0 breaks Proxmox VMs and Docker containers!" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "# net.ipv4.tcp_timestamps = 0" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "# net.ipv4.conf.all.forwarding = 0" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
    else
        # Enabled: Modern security features active
        echo "# Modern security features (enabled with --no-disable-modern-security)" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "# WARNING: This may break Proxmox VMs and Docker containers!" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "net.ipv4.tcp_timestamps = 0" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "net.ipv4.conf.all.forwarding = 0" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
        echo "" | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
    fi

    # Network security (always active)
    cat << EOF | sudo tee -a /etc/sysctl.d/99-network-hardening.conf
# Network hardening (always active - safe settings)
EOF

    sudo sysctl -p /etc/sysctl.d/99-network-hardening.conf >/dev/null
}

_harden_services() {
    # Stop and mask risky services
    echo "${ICON_OK} Hardening system services..."

    # Define services to harden based on profile or custom list
    local services_to_disable=()

    if [[ -n "$CUSTOM_SERVICES_LIST" ]]; then
        # Use custom services list (ignore profile)
        echo "${ICON_OK} Using custom services list: $CUSTOM_SERVICES_LIST"
        IFS=',' read -ra services_to_disable <<< "$CUSTOM_SERVICES_LIST"
    else
        # Use profile-based services list
        case "$HARDENING_PROFILE" in
        server)
            services_to_disable+=(
                avahi-daemon
                cups
                bluetooth
                whoopsie
                apport
                speech-dispatcher
                telnet
                rsh-server
                tftp
            )
            ;;
        workstation)
            services_to_disable+=(
                avahi-daemon
                cups
                whoopsie
                apport
                telnet
                rsh-server
                tftp
            )
            ;;
        enterprise)
            services_to_disable+=(
                whoopsie
                apport
                telnet
                rsh-server
                tftp
            )
            ;;
        esac
    fi

    # Remove services from skip list
    if [[ -n "$SKIP_SERVICES" ]]; then
        IFS=',' read -ra skip_array <<< "$SKIP_SERVICES"
        for skip in "${skip_array[@]}"; do
            services_to_disable=("${services_to_disable[@]/$skip}")
        done
    fi

    # Stop and mask services
    for service in "${services_to_disable[@]}"; do
        if [[ -n "$service" ]] && systemctl list-unit-files "$service.service" &>/dev/null; then
            echo "${ICON_OK} Stopping and masking $service..."
            sudo systemctl stop "$service" 2>/dev/null || true
            sudo systemctl disable "$service" 2>/dev/null || true
            sudo systemctl mask "$service" 2>/dev/null || true
        fi
    done
}

_harden_packages() {
    # Remove insecure/legacy packages
    echo "${ICON_OK} Removing insecure packages..."

    local packages_to_remove=()

    if [[ -n "$CUSTOM_PACKAGES_LIST" ]]; then
        # Use custom packages list (ignore profile)
        echo "${ICON_OK} Using custom packages list: $CUSTOM_PACKAGES_LIST"
        IFS=',' read -ra packages_to_remove <<< "$CUSTOM_PACKAGES_LIST"
    else
        # Use profile-based packages list
        case "$HARDENING_PROFILE" in
        server)
            packages_to_remove+=(
                xinetd
                nis
                rsh-client
                talk
                telnet
                tftp
                rsh-server
                telnet-server
                tftp-server
            )
            ;;
        workstation)
            packages_to_remove+=(
                xinetd
                nis
                rsh-client
                talk
                telnet
                tftp
                rsh-server
                telnet-server
                tftp-server
            )
            ;;
        enterprise)
            packages_to_remove+=(
                xinetd
                nis
                rsh-client
                talk
                telnet
                tftp
                rsh-server
                telnet-server
                tftp-server
            )
            ;;
        esac
    fi

    # Remove packages from skip list
    if [[ -n "$SKIP_PACKAGES" ]]; then
        IFS=',' read -ra skip_array <<< "$SKIP_PACKAGES"
        for skip in "${skip_array[@]}"; do
            packages_to_remove=("${packages_to_remove[@]/$skip}")
        done
    fi

    # Remove packages
    for package in "${packages_to_remove[@]}"; do
        if [[ -n "$package" ]] && dpkg -l "$package" &>/dev/null; then
            echo "${ICON_OK} Removing $package..."
            sudo apt remove --purge -y "$package" 2>/dev/null || true
        fi
    done
}

_apply_sysctl_hardening() {
    # Apply kernel hardening via sysctl (CIS + ANSSI + NIST + KSPP standards)
    echo "${ICON_OK} Applying kernel hardening..."

    # Prevent duplicate application
    if [[ -f /etc/sysctl.d/99-security-hardening.conf ]]; then
        echo "${ICON_SKIP} Kernel hardening already applied, updating configuration..."
    fi

    cat << EOF | sudo tee /etc/sysctl.d/99-security-hardening.conf
# Security hardening configuration
# Generated by debian-server-post-install.sh
# Sources: CIS Benchmarks, ANSSI, NIST SP 800-53, Kernel Self-Protection Project (KSPP)

# === KERNEL INFORMATION DISCLOSURE PROTECTION ===
# CIS 1.6.1 + ANSSI R12: Prevent information leakage attacks
kernel.dmesg_restrict = 1              # CIS: Prevent unprivileged access to kernel logs
kernel.kptr_restrict = 2               # ANSSI R12: Hide kernel pointers (anti-KASLR bypass)
kernel.yama.ptrace_scope = 1           # ANSSI R11: Restrict ptrace to parent processes only

# === KERNEL EXPLOIT MITIGATION ===
# KSPP + CIS: Modern kernel security features
kernel.unprivileged_bpf_disabled = 1   # KSPP: Disable unprivileged BPF (prevents eBPF exploits)
net.core.bpf_jit_harden = 2           # KSPP: Harden BPF JIT compiler (anti-JIT spraying)

# === FILE SYSTEM SECURITY ===
# CIS 1.6.4 + NIST SP 800-53: File system attack prevention
fs.suid_dumpable = 0                   # CIS 1.6.4: Disable core dumps for SUID programs
fs.protected_hardlinks = 1             # NIST: Prevent hardlink attacks in world-writable dirs
fs.protected_symlinks = 1              # NIST: Prevent symlink attacks in world-writable dirs
fs.protected_fifos = 2                 # NIST: Prevent FIFO attacks (strict mode)
fs.protected_regular = 2               # NIST: Prevent regular file attacks (strict mode)

# === MEMORY LAYOUT RANDOMIZATION (ASLR ENHANCEMENT) ===
# CIS 1.6.2 + KSPP: Address Space Layout Randomization hardening
kernel.randomize_va_space = 2          # CIS 1.6.2: Full ASLR (stack, heap, mmap, VDSO, ET_EXEC)
vm.mmap_rnd_bits = 32                  # KSPP: Maximum entropy for 64-bit mmap ASLR (2^32 possibilities)
vm.mmap_rnd_compat_bits = 16          # KSPP: Maximum entropy for 32-bit compat mmap ASLR
EOF

    # Conditional kexec hardening (disabled by default for compatibility)
    if $DISABLE_KEXEC; then
        # Disabled: Allow kexec system call (specialized environments)
        echo "# Kexec system call (use --no-disable-kexec to disable for security)" | sudo tee -a /etc/sysctl.d/99-security-hardening.conf
        echo "# kernel.kexec_load_disabled = 1" | sudo tee -a /etc/sysctl.d/99-security-hardening.conf
        echo "" | sudo tee -a /etc/sysctl.d/99-security-hardening.conf
    else
        # Enabled: Disable kexec for security hardening
        echo "# Kexec system call hardening (enabled with --no-disable-kexec)" | sudo tee -a /etc/sysctl.d/99-security-hardening.conf
        echo "kernel.kexec_load_disabled = 1       # KSPP: Disable kexec system call (anti-rootkit)" | sudo tee -a /etc/sysctl.d/99-security-hardening.conf
        echo "" | sudo tee -a /etc/sysctl.d/99-security-hardening.conf
    fi

    sudo sysctl -p /etc/sysctl.d/99-security-hardening.conf >/dev/null
}

# ==============================================
# STEPS 5-8
# ==============================================

step_05_core_packages() {
    # Step 5: Core server packages
    log_section "Step 5: Installing core server packages."

    local packages=()

    # Apps-Profile Inheritance Architecture:
    # minimal -> default -> server -> minimal-development -> development -> full
    #                   -> server -> security -> full -> enterprise

    # Level 1: minimal (survival only - 5 packages)
    packages+=(
        git curl vim fail2ban tmux
    )

    # Level 2: default (comfort + infrastructure tools)
    case "$APPS_PROFILE" in
        default|server|minimal-development|development|security|defense|offsec|full|enterprise)
            packages+=(
                # Ex-minimal comfort tools
                wget zsh htop net-tools unzip tree ncdu lsof
                # Network tools (try both variants for compatibility)
                iproute2
                # Modern comfort tools
                lsd zip unrar p7zip-full
                # Infrastructure tools
                build-essential apt-transport-https ca-certificates gnupg lsb-release
                python3 python3-pip python3-venv jq rsync
                # systemd-resolved systemd-timesyncd  # Usually present, avoid conflicts
            )

    # Add distribution-specific packages for compatibility
    if [[ "$DISTRO" == "ubuntu" ]]; then
        packages+=(software-properties-common ca-certificates-utils)
    fi

    # Add ss command (try iproute2-ss or separate ss package if needed)
    if ! command -v ss >/dev/null 2>&1; then
        packages+=(iproute2)
    fi
            ;;
    esac

    # Level 3: server (server management)
    case "$APPS_PROFILE" in
        server|minimal-development|development|security|defense|offsec|full|enterprise)
            packages+=(
                logrotate psmisc dstat iotop nethogs
                backup-manager sudo screen
                openssl ca-certificates whois
                cron anacron at
                rsyslog vnstat
            )

    # Add Ubuntu-specific packages for server profile
    if [[ "$DISTRO" == "ubuntu" ]]; then
        packages+=(ca-certificates-utils)
    fi
            ;;
    esac

    # Level 4A: minimal-development (light dev tools)
    case "$APPS_PROFILE" in
        minimal-development|development|full|enterprise)
            packages+=(
                python3-dev make cmake pkg-config
                sqlite3 golang-go
            )
            ;;
    esac

    # Level 5A: development (full development stack)
    case "$APPS_PROFILE" in
        development|full|enterprise)
            packages+=(
                nodejs npm golang
                postgresql-client mysql-client
                ansible-core fzf yq ripgrep autotools-dev
            )
            # Add Docker packages based on type
            if [[ "$DOCKER_TYPE" == "io" ]]; then
                packages+=(docker.io docker-compose)
            fi
            ;;
    esac

    # Level 4B: security (general network security tools)
    case "$APPS_PROFILE" in
        security|defense|offsec|full|enterprise)
            packages+=(
                nmap tcpdump
            )
            ;;
    esac

    # Level 5B: defense (blue team / defensive security)
    case "$APPS_PROFILE" in
        defense|full|enterprise)
            packages+=(
                lynis rkhunter chkrootkit
                wireshark-common tshark
                aide debsecan debsums
                # tiger           # Heavy audit tool, commented (resource intensive)
                # apparmor-utils  # AppArmor security tools
            )
            ;;
    esac

    # Level 5C: offsec (red team / offensive security)
    case "$APPS_PROFILE" in
        offsec|full|enterprise)
            packages+=(
                netcat-openbsd
                # Future: additional offensive tools
            )
            ;;
    esac

    # Level 6: enterprise (compliance and advanced audit)
    case "$APPS_PROFILE" in
        enterprise)
            packages+=(
                auditd sysstat acct
                logwatch logcheck
                rng-tools haveged
                # aide-common      # Redundant with aide from defense
                # tiger-otheros    # Extensions without main tiger package
                # tripwire         # Heavy integrity checker
                # samhain          # Heavy file integrity system
                # ossec-hids-agent # Heavy HIDS agent
            )
            ;;
    esac

    # Add extra packages
    if [[ -n "$EXTRA_PACKAGES" ]]; then
        IFS=',' read -ra extra_array <<< "$EXTRA_PACKAGES"
        packages+=("${extra_array[@]}")
    fi

    # Remove skipped packages
    if [[ -n "$SKIP_APT_PACKAGES" ]]; then
        IFS=',' read -ra skip_array <<< "$SKIP_APT_PACKAGES"
        for skip in "${skip_array[@]}"; do
            packages=("${packages[@]/$skip}")
        done
    fi

    # Pre-configure packages that might show interactive prompts
    if [[ " ${packages[*]} " =~ " backup-manager " ]]; then
        echo "${ICON_OK} Pre-configuring backup-manager to avoid interactive prompts..."
        echo 'backup-manager backup-manager/backup-repository select none' | sudo debconf-set-selections
        echo 'backup-manager backup-manager/name string ""' | sudo debconf-set-selections
        echo 'backup-manager backup-manager/directories string ""' | sudo debconf-set-selections
    fi

    echo "${ICON_OK} Installing core packages..."
    echo "Installing (${#packages[@]} packages): ${packages[*]}"
    echo ""
    DEBIAN_FRONTEND=noninteractive sudo apt install -y "${packages[@]}"
    echo "${ICON_OK} Core packages installation completed."

    # Install specialized tools via functions (not APT)
    case "$APPS_PROFILE" in
        development|full|enterprise)
            _install_hashicorp_from_profile
            ;;
    esac
}

step_06_security_monitoring() {
    # Step 6: Security monitoring tools
    log_section "Step 6: Configuring security monitoring tools."

    # Fail2ban: check if installed, install if missing, then configure
    if ! dpkg -l | grep -q "^ii  fail2ban"; then
        echo "${ICON_OK} Installing fail2ban..."
        DEBIAN_FRONTEND=noninteractive sudo apt install -y fail2ban
    fi

    echo "${ICON_OK} Configuring Fail2ban..."
    # Configure Fail2ban
    sudo tee /etc/fail2ban/jail.local > /dev/null << EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3
backend = systemd

[sshd]
enabled = true
port = $SSH_PORT
filter = sshd
logpath = /var/log/auth.log
maxretry = 3

[nginx-http-auth]
enabled = false

[apache-auth]
enabled = false
EOF

    sudo systemctl enable fail2ban
    sudo systemctl start fail2ban
    echo "${ICON_OK} Fail2ban configured and started."

    # AIDE: if installed, configure it, otherwise skip
    if dpkg -l | grep -q "^ii  aide"; then
        echo "${ICON_OK} Configuring AIDE (Advanced Intrusion Detection Environment)..."
        sudo aideinit --config-check
        sudo aideinit --init || true
        echo "${ICON_OK} AIDE configured."
    fi

    # auditd: if installed, configure it, otherwise skip
    if dpkg -l | grep -q "^ii  auditd"; then
        echo "${ICON_OK} Configuring auditd..."
        sudo systemctl enable auditd
        sudo systemctl start auditd
        echo "${ICON_OK} auditd configured."
    fi

    echo "${ICON_OK} Security monitoring tools configuration completed."
}

step_07_logging_monitoring() {
    # Step 7: Enhanced logging and monitoring
    log_section "Step 7: Configuring enhanced logging and monitoring."

    if ! $ENABLE_LOGGING; then
        echo "${ICON_SKIP} Skipping enhanced logging setup."
        return
    fi

    # Configure rsyslog if available
    if command -v rsyslogd >/dev/null 2>&1; then
        echo "${ICON_OK} Configuring enhanced logging..."

        # Create custom rsyslog config for security events
        sudo tee /etc/rsyslog.d/99-security.conf > /dev/null << EOF
# Security event logging
auth,authpriv.* /var/log/auth.log
*.warn /var/log/security.log
local0.* /var/log/fail2ban.log
EOF

        sudo systemctl restart rsyslog
        echo "${ICON_OK} rsyslog configured."
    fi

    # Configure logrotate if available
    if command -v logrotate >/dev/null 2>&1; then
        echo "${ICON_OK} Configuring log rotation..."

        # Configure logrotate for custom logs
        sudo tee /etc/logrotate.d/security-logs > /dev/null << EOF
/var/log/security.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    postrotate
        /usr/lib/rsyslog/rsyslog-rotate
    endscript
}
EOF
        echo "${ICON_OK} logrotate configured."
    fi

    # Configure monitoring tools if installed (managed by apps-profile)
    if dpkg -l | grep -q "^ii  vnstat"; then
        echo "${ICON_OK} Configuring vnstat..."
        sudo systemctl enable vnstat
        sudo systemctl start vnstat
        echo "${ICON_OK} vnstat configured."
    fi

    if dpkg -l | grep -q "^ii  sysstat"; then
        echo "${ICON_OK} Configuring sysstat..."
        sudo sed -i 's/ENABLED="false"/ENABLED="true"/' /etc/default/sysstat
        sudo systemctl enable sysstat
        sudo systemctl start sysstat
        echo "${ICON_OK} sysstat configured."
    fi

    echo "${ICON_OK} Logging and monitoring configuration completed."
}

step_08_container_runtime() {
    # Step 8: Container runtime (Docker)
    log_section "Step 8: Configuring container runtime."

    # Check if Docker installation requested (via profile or explicit flag)
    local docker_requested=false

    if $INSTALL_DOCKER; then
        docker_requested=true
    elif dpkg -l | grep -q "docker\|containerd"; then
        docker_requested=true
    elif [[ "$APPS_PROFILE" =~ (development|full|enterprise) ]]; then
        docker_requested=true
    fi

    if ! $docker_requested; then
        echo "${ICON_SKIP} No Docker installation requested."
        return
    fi

    case "$DOCKER_TYPE" in
        io)
            configure_docker_io
            ;;
        ce)
            install_docker_ce
            ;;
        *)
            echo "${ICON_ERR} Invalid Docker type: $DOCKER_TYPE"
            exit 1
            ;;
    esac
}

configure_docker_io() {
    echo "${ICON_OK} Configuring docker.io..."

    # Check if docker.io is installed
    if ! dpkg -l | grep -q "^ii  docker.io"; then
        echo "${ICON_WARN} docker.io not found but requested. Installing..."
        sudo apt update
        DEBIAN_FRONTEND=noninteractive sudo apt install -y docker.io
        if $DOCKER_COMPOSE; then
            DEBIAN_FRONTEND=noninteractive sudo apt install -y docker-compose
        fi
    fi

    configure_docker_common
}

install_docker_ce() {
    echo "${ICON_OK} Installing Docker CE..."

    # Remove old Docker packages
    sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

    # Check and install prerequisites only if missing
    local missing_prereq=()
    for pkg in ca-certificates curl gnupg lsb-release; do
        if ! dpkg -l | grep -q "^ii  $pkg"; then
            missing_prereq+=("$pkg")
        fi
    done

    if [ ${#missing_prereq[@]} -gt 0 ]; then
        echo "${ICON_OK} Installing missing prerequisites: ${missing_prereq[*]}"
        sudo apt update
        DEBIAN_FRONTEND=noninteractive sudo apt install -y "${missing_prereq[@]}"
    fi

    # Add Docker's official GPG key
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/$DISTRO/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    # Add Docker repository
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$DISTRO \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker Engine
    sudo apt update
    DEBIAN_FRONTEND=noninteractive sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin

    # Install Docker Compose if requested
    if $DOCKER_COMPOSE; then
        DEBIAN_FRONTEND=noninteractive sudo apt install -y docker-compose-plugin
        echo "${ICON_OK} Docker Compose installed."
    fi

    configure_docker_common
}

configure_docker_common() {
    echo "${ICON_OK} Configuring Docker..."

    # Add user to docker group
    sudo usermod -aG docker "$USER"

    # Enable and start Docker
    sudo systemctl enable docker
    sudo systemctl start docker

    # Configure Docker daemon for security
    sudo tee /etc/docker/daemon.json > /dev/null << EOF
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    },
    "userland-proxy": false,
    "experimental": false,
    "icc": false,
    "userns-remap": "default",
    "no-new-privileges": true
}
EOF

    sudo systemctl restart docker
    echo "${ICON_OK} Docker ($DOCKER_TYPE) configured securely."
    echo "${ICON_WARN} Log out and back in for Docker group membership to take effect."
}

# ==============================================
# STEPS 9-12
# ==============================================

step_09_vim_configuration() {
    # Step 9: Vim configuration
    log_section "Step 9: Configuring Vim editor."

    if [[ "$EDITOR_MODE" == "neovim" || "$EDITOR_MODE" == "none" ]]; then
        echo "${ICON_SKIP} Skipping Vim configuration (mode: $EDITOR_MODE)."
        return
    fi

    echo "${ICON_OK} Installing Vim..."
    DEBIAN_FRONTEND=noninteractive sudo apt install -y vim

    case "$VIM_PRESET" in
        full)
            _configure_vim_full
            ;;
        minimal)
            _configure_vim_minimal
            ;;
        bare)
            _configure_vim_bare
            ;;
    esac

    echo "${ICON_OK} Vim configuration completed."
}

step_10_zsh_terminal() {
    # Step 10: Zsh and terminal configuration
    log_section "Step 10: Configuring Zsh terminal."

    # Check if Zsh is available (installed or being installed)
    # Try multiple detection methods for robustness
    if ! command -v zsh >/dev/null 2>&1 && ! dpkg -l 2>/dev/null | grep -q "^ii  zsh" && ! which zsh >/dev/null 2>&1 && ! test -f /usr/bin/zsh && ! test -f /bin/zsh; then
        echo "${ICON_SKIP} Zsh not installed, skipping configuration."
        echo "${ICON_OK} Use apps-profile default+ to install zsh first."
        return
    fi

    echo "${ICON_OK} Configuring Zsh..."

    # Install Oh My Zsh
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        echo "${ICON_OK} Installing Oh My Zsh..."
        RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL $URL_OHMYZSH)" || true
    else
        echo "${ICON_SKIP} Oh My Zsh already installed."
    fi

    # Install Powerlevel10k theme
    local p10k_dir="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    if [[ ! -d "$p10k_dir" ]]; then
        echo "${ICON_OK} Installing Powerlevel10k theme..."
        git clone --depth=1 "$URL_POWERLEVEL10K" "$p10k_dir"
    else
        echo "${ICON_SKIP} Powerlevel10k already installed."
    fi

    # Install Zsh plugins
    _install_zsh_plugins

    # Configure .zshrc
    _configure_zshrc

    # Install Nerd Fonts (if requested)
    _install_nerd_fonts

    # Change default shell to Zsh
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        echo "${ICON_OK} Changing default shell to Zsh..."
        chsh -s "$(which zsh)"
        echo "${ICON_WARN} Default shell changed to Zsh. Please log out and back in."
    fi

    echo "${ICON_OK} Zsh and terminal configuration completed."
}


step_11_extra_software() {
    # Step 11: Extra software and repositories
    log_section "Step 11: Installing extra software."

    # Install Mullvad VPN (if requested)
    _install_mullvad_vpn

    # Process additional extras
    if [[ -n "$EXTRA_REPOS" ]]; then
        echo "${ICON_OK} Installing additional extras: $EXTRA_REPOS"

        # Parse and install extras
        IFS=',' read -ra extras_array <<< "$EXTRA_REPOS"
        for extra in "${extras_array[@]}"; do
            case "$extra" in
                docker)
                    echo "${ICON_OK} Enabling Docker installation via extras."
                    INSTALL_DOCKER=true
                    ;;
                gh)
                    _install_github_cli
                    ;;
                hashicorp)
                    echo "${ICON_SKIP} HashiCorp tools handled by apps-profile."
                    echo "${ICON_OK} Use development/full/enterprise profile for terraform, packer, vault."
                    ;;
                monitoring)
                    echo "${ICON_SKIP} Monitoring handled by apps-profile + step 7."
                    ;;
                mullvad)
                    echo "${ICON_SKIP} Use --install-mullvad flag instead."
                    ;;
                *)
                    echo "${ICON_WARN} Unknown extra: $extra"
                    ;;
            esac
        done
    else
        echo "${ICON_SKIP} No additional extras specified."
    fi

    echo "${ICON_OK} Extra software installation completed."
}

# ==============================================
# VIM CONFIGURATION HELPERS
# ==============================================

_configure_vim_full() {
    echo "${ICON_OK} Configuring Vim (full preset)..."

    # Download vim-plug
    local plug_dir="$HOME/.vim/autoload"
    mkdir -p "$plug_dir"
    curl -fLo "$plug_dir/plug.vim" --create-dirs "$URL_VIM_PLUG"

    # Create .vimrc
    cat > "$HOME/.vimrc" << 'EOF'
" Vim configuration - Full preset
set nocompatible
filetype off

call plug#begin('~/.vim/plugged')
Plug 'preservim/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'morhetz/gruvbox'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'dense-analysis/ale'
call plug#end()

" Basic settings
set number
set relativenumber
set hlsearch
set incsearch
set ignorecase
set smartcase
set expandtab
set tabstop=4
set shiftwidth=4
set autoindent
set smartindent
set mouse=a
set clipboard=unnamed
set cursorline
set showmatch
set wildmenu
set laststatus=2
set encoding=utf-8

" Color scheme
set background=dark
colorscheme gruvbox
let g:airline_theme='gruvbox'

" Key mappings
let mapleader = ","
nnoremap <leader>n :NERDTreeToggle<CR>
nnoremap <leader>f :NERDTreeFind<CR>

" Auto-install plugins
if empty(glob('~/.vim/plugged'))
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

filetype plugin indent on
syntax enable
EOF

    echo "${ICON_OK} Vim full configuration applied."
}

_configure_vim_minimal() {
    echo "${ICON_OK} Configuring Vim (minimal preset)..."

    # Install gruvbox theme via package manager if available
    if apt-cache show vim-airline &>/dev/null; then
        DEBIAN_FRONTEND=noninteractive sudo apt install -y vim-airline vim-airline-themes
    fi

    cat > "$HOME/.vimrc" << 'EOF'
" Vim configuration - Minimal preset
set nocompatible
syntax enable
filetype plugin indent on

" Basic settings
set number
set hlsearch
set incsearch
set ignorecase
set smartcase
set expandtab
set tabstop=4
set shiftwidth=4
set autoindent
set mouse=a
set cursorline
set wildmenu
set laststatus=2

" Color scheme
set background=dark
try
    colorscheme gruvbox
catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme desert
endtry
EOF

    echo "${ICON_OK} Vim minimal configuration applied."
}

_configure_vim_bare() {
    echo "${ICON_OK} Configuring Vim (bare preset)..."

    cat > "$HOME/.vimrc" << EOF
" Vim configuration - Bare preset
set nocompatible
syntax enable
filetype plugin indent on

" Basic settings
set number
set hlsearch
set incsearch
set expandtab
set tabstop=4
set shiftwidth=4
set autoindent
set mouse=a

" Color scheme
colorscheme $VIM_COLORSCHEME
EOF

    echo "${ICON_OK} Vim bare configuration applied."
}

# ==============================================
# ZSH CONFIGURATION HELPERS
# ==============================================

_install_zsh_plugins() {
    echo "${ICON_OK} Installing Zsh plugins..."

    local custom_dir="$HOME/.oh-my-zsh/custom"

    # Autosuggestions
    local autosuggestions_dir="$custom_dir/plugins/zsh-autosuggestions"
    if [[ ! -d "$autosuggestions_dir" ]]; then
        git clone "$URL_PLUGIN_AUTOSUGGESTIONS" "$autosuggestions_dir"
    fi

    # Syntax highlighting
    local syntax_dir="$custom_dir/plugins/zsh-syntax-highlighting"
    if [[ ! -d "$syntax_dir" ]]; then
        git clone "$URL_PLUGIN_SYNTAX_HIGHLIGHTING" "$syntax_dir"
    fi

    # Completions
    local completions_dir="$custom_dir/plugins/zsh-completions"
    if [[ ! -d "$completions_dir" ]]; then
        git clone "$URL_PLUGIN_COMPLETIONS" "$completions_dir"
    fi
}

_configure_zshrc() {
    echo "${ICON_OK} Configuring .zshrc..."

    # Backup existing .zshrc
    if [[ -f "$HOME/.zshrc" ]]; then
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    fi

    cat > "$HOME/.zshrc" << 'EOF'
# Zsh configuration - Server optimized

# Oh My Zsh configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
    git
    docker
    docker-compose
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
)

source $ZSH/oh-my-zsh.sh

# User configuration
export PATH=$HOME/bin:/usr/local/bin:$PATH
export EDITOR='vim'

# Aliases for server administration
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# System monitoring aliases
alias ports='netstat -tulanp'
alias meminfo='free -m -l -t'
alias psmem='ps auxf | sort -nr -k 4'
alias pscpu='ps auxf | sort -nr -k 3'
alias cpuinfo='lscpu'
alias diskusage='df -H'

# Network aliases
alias myip='curl ifconfig.me'
alias netcons='netstat -ntu | grep :80 | wc -l'
alias listen='ss -tuln'

# Docker aliases (if installed)
if command -v docker &> /dev/null; then
    alias dps='docker ps'
    alias dpsa='docker ps -a'
    alias dimg='docker images'
    alias dlog='docker logs'
    alias dexec='docker exec -it'
fi

# Clear bash history if requested
if [[ "$CLEAR_BASH_HISTORY" == "true" ]]; then
    history -c
    history -w
fi

# Load Powerlevel10k instant prompt
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

    echo "${ICON_OK} .zshrc configured."
}



# ==============================================
# EXTRA SOFTWARE HELPERS
# ==============================================

_install_github_cli() {
    echo "${ICON_OK} Installing GitHub CLI..."

    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

    sudo apt update
    DEBIAN_FRONTEND=noninteractive sudo apt install -y gh
}

_install_hashicorp_from_profile() {
    # Install HashiCorp tools for apps-profile
    echo "${ICON_OK} Installing HashiCorp tools for profile..."
    case "$APPS_PROFILE" in
        development|full|enterprise)
            _install_hashicorp_tools "terraform packer vault"
            ;;
    esac
}

_install_hashicorp_tools() {
    local tools_list="${1:-terraform vault consul nomad packer}"
    echo "${ICON_OK} Installing HashiCorp tools: $tools_list"

    # Add HashiCorp repository if not already present
    if [[ ! -f /etc/apt/sources.list.d/hashicorp.list ]]; then
        curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
        sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
        sudo apt update
    fi

    # Convert space-separated list to array and install
    local tools_array=($tools_list)
    DEBIAN_FRONTEND=noninteractive sudo apt install -y "${tools_array[@]}"
}


# ==============================================
# MULLVAD VPN FUNCTIONS
# ==============================================

_install_mullvad_vpn() {
    # Install Mullvad VPN using specified or auto-detected method
    if ! $INSTALL_MULLVAD; then
        echo "${ICON_SKIP} Skipping Mullvad VPN installation."
        return
    fi

    echo "${ICON_OK} Installing Mullvad VPN..."

    if $_MULLVAD_SOURCE_EXPLICIT; then
        # User specified a method - use only that one
        case "$MULLVAD_SOURCE" in
            apt) _install_mullvad_apt ;;
            direct) _install_mullvad_direct ;;
            github) _install_mullvad_github ;;
        esac
    else
        # Auto-fallback: try apt → direct → github
        if ! _install_mullvad_apt; then
            echo "${ICON_WARN} APT method failed, trying direct download..."
            if ! _install_mullvad_direct; then
                echo "${ICON_WARN} Direct method failed, trying GitHub releases..."
                _install_mullvad_github
            fi
        fi
    fi
}

_install_mullvad_apt() {
    # Install Mullvad via official APT repository
    echo "${ICON_OK} Installing Mullvad VPN via APT repository..."

    # Download and verify GPG key
    if ! curl -fsSL "$URL_MULLVAD_KEYRING" | sudo gpg --dearmor -o /usr/share/keyrings/mullvad-keyring.gpg; then
        echo "${ICON_ERR} Failed to download Mullvad GPG key."
        return 1
    fi

    # Add repository
    echo "deb [signed-by=/usr/share/keyrings/mullvad-keyring.gpg arch=amd64] $URL_MULLVAD_REPO $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/mullvad.list >/dev/null

    # Update and install
    sudo apt update
    if DEBIAN_FRONTEND=noninteractive sudo apt install -y mullvad-vpn; then
        echo "${ICON_OK} Mullvad VPN installed successfully via APT."
        return 0
    else
        echo "${ICON_ERR} Failed to install Mullvad via APT."
        return 1
    fi
}

_install_mullvad_direct() {
    # Install Mullvad via direct .deb download
    echo "${ICON_OK} Installing Mullvad VPN via direct download..."

    local temp_dir="/tmp/mullvad-install"
    mkdir -p "$temp_dir"

    # Download .deb package
    if ! curl -L "$URL_MULLVAD" -o "$temp_dir/mullvad-vpn.deb"; then
        echo "${ICON_ERR} Failed to download Mullvad .deb package."
        rm -rf "$temp_dir"
        return 1
    fi

    # Install package
    if sudo dpkg -i "$temp_dir/mullvad-vpn.deb"; then
        # Fix any dependency issues
        sudo apt-get install -f -y
        echo "${ICON_OK} Mullvad VPN installed successfully via direct download."
        rm -rf "$temp_dir"
        return 0
    else
        echo "${ICON_ERR} Failed to install Mullvad .deb package."
        rm -rf "$temp_dir"
        return 1
    fi
}

_install_mullvad_github() {
    # Install Mullvad via GitHub releases
    echo "${ICON_OK} Installing Mullvad VPN via GitHub releases..."

    local temp_dir="/tmp/mullvad-github"
    mkdir -p "$temp_dir"

    # Get latest release info
    local release_info
    if ! release_info=$(curl -s "$URL_MULLVAD_GITHUB_API"); then
        echo "${ICON_ERR} Failed to fetch Mullvad release information."
        rm -rf "$temp_dir"
        return 1
    fi

    # Extract download URL for .deb package
    local download_url
    download_url=$(echo "$release_info" | grep -o '"browser_download_url": "[^"]*amd64\.deb"' | cut -d'"' -f4 | head -1)

    if [[ -z "$download_url" ]]; then
        echo "${ICON_ERR} Could not find .deb package in GitHub releases."
        rm -rf "$temp_dir"
        return 1
    fi

    # Download .deb package
    if ! curl -L "$download_url" -o "$temp_dir/mullvad-vpn.deb"; then
        echo "${ICON_ERR} Failed to download Mullvad .deb from GitHub."
        rm -rf "$temp_dir"
        return 1
    fi

    # Install package
    if sudo dpkg -i "$temp_dir/mullvad-vpn.deb"; then
        sudo apt-get install -f -y
        echo "${ICON_OK} Mullvad VPN installed successfully via GitHub releases."
        rm -rf "$temp_dir"
        return 0
    else
        echo "${ICON_ERR} Failed to install Mullvad .deb from GitHub."
        rm -rf "$temp_dir"
        return 1
    fi
}

# ==============================================
# NERD FONTS FUNCTIONS
# ==============================================

_install_nerd_fonts() {
    # Install Nerd Fonts based on selected profile
    if ! $INSTALL_NERD_FONTS; then
        echo "${ICON_SKIP} Skipping Nerd Fonts installation."
        return
    fi

    echo "${ICON_OK} Installing Nerd Fonts (profile: $NERD_FONTS_PROFILE)..."

    local fonts_dir="$HOME/.local/share/fonts"
    mkdir -p "$fonts_dir"

    case "$NERD_FONTS_PROFILE" in
        minimal)
            _install_font_firacode
            ;;
        default)
            _install_font_firacode
            _install_font_jetbrains
            ;;
        full)
            _install_font_firacode
            _install_font_jetbrains
            _install_font_hack
            _install_font_sourcecodepro
            ;;
    esac

    # Update font cache
    fc-cache -fv
    echo "${ICON_OK} Nerd Fonts installation completed."
}

_install_font_firacode() {
    echo "${ICON_OK} Installing FiraCode Nerd Font..."
    local url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraCode.zip"
    _download_and_install_font "$url" "FiraCode"
}

_install_font_jetbrains() {
    echo "${ICON_OK} Installing JetBrains Mono Nerd Font..."
    local url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip"
    _download_and_install_font "$url" "JetBrainsMono"
}

_install_font_hack() {
    echo "${ICON_OK} Installing Hack Nerd Font..."
    local url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Hack.zip"
    _download_and_install_font "$url" "Hack"
}

_install_font_sourcecodepro() {
    echo "${ICON_OK} Installing Source Code Pro Nerd Font..."
    local url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/SourceCodePro.zip"
    _download_and_install_font "$url" "SourceCodePro"
}

_download_and_install_font() {
    local url="$1"
    local font_name="$2"
    local temp_dir="/tmp/nerdfonts-$font_name"
    local fonts_dir="$HOME/.local/share/fonts"

    mkdir -p "$temp_dir"

    if curl -L "$url" -o "$temp_dir/$font_name.zip"; then
        if command -v unzip &>/dev/null; then
            unzip -o "$temp_dir/$font_name.zip" -d "$temp_dir"
            cp "$temp_dir"/*.ttf "$fonts_dir/" 2>/dev/null || true
            cp "$temp_dir"/*.otf "$fonts_dir/" 2>/dev/null || true
            echo "${ICON_OK} $font_name installed successfully."
        else
            echo "${ICON_WARN} unzip not available, skipping $font_name."
        fi
    else
        echo "${ICON_WARN} Failed to download $font_name."
    fi

    rm -rf "$temp_dir"
}

# ==============================================
# SIGNAL HANDLING AND MAIN EXECUTION
# ==============================================

cleanup() {
    # Clean up on exit or interrupt
    echo ""
    echo "${ICON_INFO} Cleaning up..."

    # Kill background sudo keepalive if running
    if [[ -n "${SUDO_KEEPALIVE_PID:-}" ]]; then
        kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
    fi

    # Show elapsed time
    if [[ -n "${START_TIME:-}" ]]; then
        local end_time elapsed_time
        end_time=$(date +%s)
        elapsed_time=$((end_time - START_TIME))
        echo "${ICON_INFO} Elapsed time: ${elapsed_time}s"
    fi
}

handle_interrupt() {
    echo ""
    echo "${ICON_WARN} Script interrupted by user."
    cleanup
    exit $EXIT_INTERRUPT
}

sudo_keepalive() {
    # Background function to keep sudo alive during script execution
    # Prevents password prompts during long-running operations

    echo "${ICON_OK} Starting sudo keepalive process..."

    # Run keepalive in background
    while true; do
        sudo -n true 2>/dev/null || {
            echo "${ICON_WARN} sudo session expired - you may be prompted for password again."
            break
        }
        sleep 60
    done &

    SUDO_KEEPALIVE_PID=$!
    echo "${ICON_OK} sudo keepalive started (PID: $SUDO_KEEPALIVE_PID)"
}

check_package_manager() {
    # Check if another package manager is running to prevent conflicts
    # This prevents apt lock errors and database corruption

    echo "${ICON_OK} Checking package manager availability..."

    # Check for running package managers
    local running_managers=()

    if pgrep -x apt &>/dev/null; then
        running_managers+=("apt")
    fi

    if pgrep -x apt-get &>/dev/null; then
        running_managers+=("apt-get")
    fi

    if pgrep -x dpkg &>/dev/null; then
        running_managers+=("dpkg")
    fi

    if pgrep -x synaptic &>/dev/null; then
        running_managers+=("synaptic")
    fi

    if pgrep -x unattended-upgrade &>/dev/null; then
        running_managers+=("unattended-upgrade")
    fi

    if pgrep -x packagekit &>/dev/null; then
        running_managers+=("packagekit")
    fi

    # Check for apt locks
    if fuser /var/lib/dpkg/lock-frontend &>/dev/null; then
        running_managers+=("dpkg-lock")
    fi

    if fuser /var/lib/apt/lists/lock &>/dev/null; then
        running_managers+=("apt-lists-lock")
    fi

    # If any managers are running, exit with detailed error
    if [[ ${#running_managers[@]} -gt 0 ]]; then
        echo "${ICON_ERR} Package manager conflict detected!"
        echo "${ICON_ERR} The following processes are currently using the package manager:"
        printf "${ICON_ERR}   - %s\n" "${running_managers[@]}"
        echo ""
        echo "Please wait for these processes to complete, then run the script again."
        echo "You can check running processes with: sudo lsof /var/lib/dpkg/lock-frontend"
        echo "Or kill them with: sudo killall apt apt-get dpkg synaptic"
        exit 1
    fi

    echo "${ICON_OK} Package manager is available."
}

run_selected_steps() {
    # Run the selected steps
    local steps_to_run

    if [[ -n "$SELECTED_STEPS" ]]; then
        steps_to_run=$(parse_step_selection "$SELECTED_STEPS")
        echo "${ICON_OK} Running selected steps: $steps_to_run"
    else
        steps_to_run="1 2 3 4 5 6 7 8 9 10 11"
        echo "${ICON_OK} Running all steps: $steps_to_run"
    fi

    # Validate step numbers
    for step in $steps_to_run; do
        if (( step < 1 || step > 11 )); then
            echo "${ICON_ERR} Invalid step number: $step (valid range: 1-11)"
            exit 1
        fi
    done

    # Execute steps
    for step in $steps_to_run; do
        case $step in
            1) step_01_system_update ;;
            2) step_02_network_firewall ;;
            3) step_03_ssh_hardening ;;
            4) step_04_system_hardening ;;
            5) step_05_core_packages ;;
            6) step_06_security_monitoring ;;
            7) step_07_logging_monitoring ;;
            8) step_08_container_runtime ;;
            9) step_09_vim_configuration ;;
            10) step_10_zsh_terminal ;;
            11) step_11_extra_software ;;
        esac
        echo ""
    done
}

show_completion_summary() {
    # Show completion summary
    cat << EOF
${SEPARATOR}
${ICON_OK} Post-installation completed successfully
${SEPARATOR}

Configuration applied:
- Server profile: $SERVER_PROFILE
- Apps profile: $APPS_PROFILE ($(_count_packages) packages)
- Firewall: $FIREWALL ($FIREWALL_PROFILE)$(if [[ $SSH_PORT != "22" ]]; then echo " | SSH port: $SSH_PORT"; fi)
- Security: Fail2ban$(if $INSTALL_MULLVAD; then echo " | Mullvad VPN"; fi)$(if $INSTALL_DOCKER; then echo " | Docker ($DOCKER_TYPE)"; fi)

EOF

    # Show important notices
    local restart_required=false

    if $INSTALL_DOCKER && [[ $(groups "$USER" | grep -c docker) -eq 0 ]]; then
        echo "${ICON_WARN} Docker group membership requires logout/login"
        restart_required=true
    fi

    if [[ "$SHELL" != "$(which zsh)" ]]; then
        echo "${ICON_WARN} Shell changed to Zsh - logout/login required"
        restart_required=true
    fi

    if [[ $SSH_PORT != "22" ]]; then
        echo "${ICON_WARN} SSH port changed to $SSH_PORT"
    fi

    if $restart_required; then
        echo ""
        echo "${ICON_INFO} Logout/login required to apply all changes"
    fi

    echo "$SEPARATOR"
}

_count_packages() {
    # Quick package count helper for summary
    case "$APPS_PROFILE" in
        minimal) echo "5" ;;
        default) echo "29" ;;
        server) echo "37" ;;
        minimal-development) echo "32" ;;
        development) echo "43" ;;
        security) echo "39" ;;
        defense) echo "47" ;;
        offsec) echo "40" ;;
        full) echo "57" ;;
        enterprise) echo "59" ;;
        *) echo "?" ;;
    esac
}

main() {
    # Main execution function
    local START_TIME
    START_TIME=$(date +%s)

    # Set up signal handlers
    trap handle_interrupt SIGINT SIGTERM

    # Initialize
    _init_symbols

    # Show banner
    show_banner

    # Parse arguments first to check for --allow-root
    parse_args "$@"

    # Check prerequisites
    check_root
    check_sudo

    # Detect distribution
    detect_distribution

    # Apply server profile defaults (can be overridden by explicit flags)
    _apply_server_profile

    # Check package manager availability
    check_package_manager

    # Start sudo keepalive in background
    sudo_keepalive

    echo "${ICON_OK} Starting Debian Server Post-Installation Script v1.0.0"
    echo "${ICON_OK} Target system: $DISTRO $DISTRO_VERSION"
    echo "${ICON_OK} Server profile: $SERVER_PROFILE"
    echo "${ICON_OK} Hardening profile: $HARDENING_PROFILE"
    echo "${ICON_OK} Apps profile: $APPS_PROFILE"
    echo "${ICON_OK} Firewall: $FIREWALL ($FIREWALL_PROFILE)"

    if $INSTALL_MULLVAD; then
        echo "${ICON_OK} Mullvad VPN: $MULLVAD_SOURCE method"
    fi

    if $INSTALL_NERD_FONTS; then
        echo "${ICON_OK} Nerd Fonts: $NERD_FONTS_PROFILE profile"
    fi

    echo ""

    # Run selected steps
    run_selected_steps

    # Clean up
    cleanup

    # Show completion summary
    show_completion_summary

    echo "${ICON_OK} Script completed successfully!"
    exit $EXIT_SUCCESS
}

# ==============================================
# SCRIPT ENTRY POINT
# ==============================================

# Check if help is requested without parsing all args
if [[ "$*" == *"--help"* ]] || [[ "$*" == *"-h"* ]]; then
    show_help
fi

# Run main function with all arguments
main "$@"