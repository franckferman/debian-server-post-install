# Development Roadmap

## Project Status

Current version: v1.0.0 (25% CIS Level 1 compliance)  
Target: v2.0.0 (80-90% CIS Level 1 compliance)

## Completed Work (v1.0.0)
- [x] 12-step server automation architecture
- [x] Debian/Ubuntu Server support
- [x] Multi-firewall backend (ufw/nftables/iptables)
- [x] SSH hardening baseline
- [x] Basic system hardening
- [x] Container runtime setup
- [x] Security tools installation
- [x] Core monitoring (Fail2ban, AIDE, auditd)

## Phase 2: Critical Security Gaps (v1.1.0)

Priority items needed for production deployment:

- [ ] **CIS 5.4** - PAM password policy enforcement
- [ ] **CIS 6.2.3** - Complete audit rule coverage
- [ ] **CIS 5.5** - login.defs account policies  
- [ ] **CIS 1.2.2.2** - Unattended security updates
- [ ] **CIS 5.3** - SSH cipher and protocol restrictions
- [ ] **CIS 5.2** - sudo logging and timeout policies
- [ ] **CIS 7.1** - System file permission auditing

## Phase 3: Extended Hardening (v1.2.0)

- [ ] **CIS 1.6** - Login warning banners
- [ ] **CIS 1.1.1** - Kernel module blacklisting
- [ ] **CIS 3.3** - Network parameter tuning
- [ ] **CIS 6.1** - Systemd journal configuration
- [ ] **CIS 2.3** - NTP/chrony time sync
- [ ] **CIS 5.1** - Cron access controls
- [ ] **CIS 1.3** - AppArmor profile enforcement

## Phase 4: Full CIS Compliance (v2.0.0)

- [ ] **CIS 1.4** - GRUB bootloader security
- [ ] **CIS 1.1.2** - Filesystem mount options
- [ ] **CIS 7.2** - User/group validation checks
- [ ] **CIS 4.x** - Advanced iptables rulesets
- [ ] Automated compliance testing
- [ ] Read-only audit mode

## Implementation Notes

### PAM Password Policy (CIS 5.4)
Configure libpam-pwquality for password enforcement:
- Set minimum length and complexity rules
- Enable account lockout after failed logins  
- Track password history to prevent reuse
- Force SHA-512 hashing in /etc/login.defs

### Comprehensive Audit Rules (CIS 6.2.3)
Add missing auditd rules for:
- System time changes (adjtimex, settimeofday)
- Privileged command execution (/usr/bin/sudo, /bin/su)
- File access failures (-F success=0)
- User/group file modifications (/etc/passwd, /etc/group)
- Network configuration changes (/etc/hosts, /etc/network/)
- Session events (logins, logouts)
- File permission changes (chmod, chown)
- Kernel module loading/unloading

### Account Policy Configuration (CIS 5.5)
Update /etc/login.defs settings:
- PASS_MAX_DAYS 365, PASS_MIN_DAYS 1, PASS_WARN_AGE 7
- UMASK 027 for restrictive file creation
- LOGIN_TIMEOUT 60 for session limits
- Set proper UID/GID ranges

### Unattended Security Updates (CIS 1.2.2.2)
Configure automatic patching:
- Install unattended-upgrades package
- Enable security repository updates only
- Set reboot time for kernel updates (02:00)
- Log all update activity to /var/log/unattended-upgrades/

### SSH Protocol Hardening (CIS 5.3)
Restrict SSH algorithms and protocols:
- Ciphers: chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
- MACs: hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com
- KexAlgorithms: curve25519-sha256,diffie-hellman-group16-sha512
- Set MaxStartups 10:30:60, MaxSessions 4

### Sudo Security Controls (CIS 5.2)
Configure /etc/sudoers.d/ policies:
- Enable command logging with log_input,log_output
- Set session timeouts with timestamp_timeout=15
- Disable root login preservation with !rootpw
- Require tty with requiretty

### File Permission Audit (CIS 7.1)
Check and fix critical file permissions:
- /etc/passwd (644), /etc/shadow (640), /etc/group (644)
- /etc/gshadow (640), /etc/passwd- (644), /etc/shadow- (640)
- Boot files: /boot/grub/grub.cfg (400)
- Find world-writable files: find / -xdev -type f -perm -0002

## Testing and Validation

### Compliance Tracking
- Lynis security audit scores
- CIS-CAT benchmark results  
- Custom verification scripts per control
- Cross-distribution testing (Debian 12, Ubuntu 24.04 LTS)

### Target Metrics
- v1.0.0 (current): 25% CIS L1 compliance
- v1.1.0 (Phase 2): 65% CIS L1 compliance
- v1.2.0 (Phase 3): 80% CIS L1 compliance  
- v2.0.0 (Phase 4): 90% CIS L1 compliance

## Code Structure Changes

Break down system hardening into focused functions:
```bash
step_04_system_hardening() {
    step_04a_pam_hardening
    step_04b_login_defs_hardening
    step_04c_automated_updates  
    step_04d_sudo_hardening
    step_04e_file_permissions
}
```

### New Command Options
- `--audit-only`: Check compliance without making changes
- `--compliance-report`: Generate detailed CIS control status
- `--config-file`: Use external configuration for enterprise setups

## Development Schedule

Phase 2 implementation order:

1. **Automated Updates** (1 hour) - Quick security win
2. **login.defs** (1 hour) - Account policy baseline
3. **File Permissions** (30 minutes) - Low-hanging fruit
4. **PAM Policy** (2 hours) - Requires careful testing
5. **sudo Hardening** (1 hour) - Access control improvements
6. **SSH Protocols** (1 hour) - Crypto algorithm restrictions  
7. **auditd Rules** (3 hours) - Complex rule validation needed

Estimated total: 10 hours development + testing

## References

- CIS Ubuntu Linux 24.04 LTS Benchmark v1.0.0
- CIS Debian Linux 12 Benchmark v1.1.0  
- NIST SP 800-53 Security Controls (Rev 5)
- Ansible-Lockdown CIS audit playbooks