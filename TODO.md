# Roadmap

## Current Status and Goals

**Current**: v1.0.0 - Functional server automation (CIS compliance ~25%)  
**Target**: v2.0.0 - CIS Level 1 Server compliance (~80-90%)

## Development Phases

### Phase 1 - COMPLETED (v1.0.0)
- [x] Server-focused architecture (12 steps)
- [x] Multi-distribution support (Debian/Ubuntu Server)
- [x] Multi-engine firewall support (ufw/nftables/iptables) 
- [x] Basic SSH hardening
- [x] Partial system hardening
- [x] Container runtime integration
- [x] Security tooling
- [x] Basic monitoring (Fail2ban, AIDE, auditd)

### Phase 2 - CRITICAL (v1.1.0 - HIGH PRIORITY)
Missing critical security elements

- [ ] **CIS 5.4** - PAM Password Policy
- [ ] **CIS 6.2.3** - Complete auditd Rules
- [ ] **CIS 5.5** - login.defs Hardening
- [ ] **CIS 1.2.2.2** - Automated Security Updates
- [ ] **CIS 5.3** - Advanced SSH Hardening
- [ ] **CIS 5.2** - sudo Configuration
- [ ] **CIS 7.1** - System File Permissions

### Phase 3 - IMPORTANT (v1.2.0 - MEDIUM PRIORITY)
System reinforcement and extended compliance

- [ ] **CIS 1.6** - Login Banners
- [ ] **CIS 1.1.1** - Kernel Module Controls
- [ ] **CIS 3.3** - Additional Network sysctl
- [ ] **CIS 6.1** - journald Configuration
- [ ] **CIS 2.3** - Time Synchronization
- [ ] **CIS 5.1** - cron Security
- [ ] **CIS 1.3** - AppArmor Implementation

### Phase 4 - ADVANCED (v2.0.0 - LOWER PRIORITY)
Complete CIS Level 1 compliance

- [ ] **CIS 1.4** - Boot Loader Security
- [ ] **CIS 1.1.2** - Filesystem Configuration
- [ ] **CIS 7.2** - User and Group Auditing
- [ ] **CIS 4.x** - Advanced Firewall Rules
- [ ] Comprehensive test automation
- [ ] Compliance verification mode

## Phase 2 Implementation Details

### PAM Password Policy (CIS 5.4)
Implement comprehensive password requirements using libpam-pwquality:
- Minimum length and complexity requirements
- Account lockout after failed attempts
- Password history to prevent reuse
- Secure password hashing algorithms

### Complete auditd Rules (CIS 6.2.3)
Expand audit coverage to monitor:
- Date and time modifications
- Privileged command execution
- Unsuccessful file access attempts
- User and group modifications
- Network environment changes
- Login and logout events
- Permission and ownership changes
- Kernel module operations

### login.defs Hardening (CIS 5.5)
Configure user account policies:
- Password aging requirements
- Session timeouts
- Default permissions (umask)
- Account expiration settings

### Automated Security Updates (CIS 1.2.2.2)
Configure unattended-upgrades for:
- Automatic security patch installation
- System maintenance scheduling
- Reboot policies for kernel updates
- Update logging and monitoring

### Advanced SSH Hardening (CIS 5.3)
Enhance SSH security with:
- Restricted cipher suites and MACs
- Connection rate limiting
- User/group access controls
- Detailed logging configuration

### sudo Configuration (CIS 5.2)
Implement sudo security controls:
- Command logging and monitoring
- Session timeout policies
- Privilege escalation restrictions
- Secure environment handling

### System File Permissions (CIS 7.1)
Audit and correct permissions for:
- Critical system files (/etc/passwd, /etc/shadow)
- Configuration directories
- Log files and system binaries
- World-writable file detection and remediation

## Testing Strategy

### Automated Validation
- Lynis security score tracking
- CIS benchmark compliance testing
- Functionality verification scripts
- Multi-distribution compatibility checks

### Target Compliance Levels
- **v1.0.0 (current)**: ~25% CIS L1 Server
- **v1.1.0 (Phase 2)**: ~65% CIS L1 Server  
- **v1.2.0 (Phase 3)**: ~80% CIS L1 Server
- **v2.0.0 (Phase 4)**: ~90% CIS L1 Server

## Architecture Improvements

### Modular Structure
Organize hardening functions into logical groupings:
```bash
step_04_system_hardening() {
    step_04a_pam_hardening
    step_04b_login_defs_hardening  
    step_04c_automated_updates
    step_04d_sudo_hardening
    step_04e_file_permissions
}
```

### Compliance Features
- `--compliance-check`: Audit-only mode without making changes
- `--compliance-report`: Generate detailed compliance reports
- External configuration file support for enterprise deployments

### Backwards Compatibility
- Maintain existing command-line interface
- New features opt-in by default
- Legacy mode support for existing deployments

## Implementation Priority

**Phase 2 development order** (estimated effort):

1. **Automated Updates** (~1 hour) - Immediate security impact
2. **login.defs Configuration** (~1 hour) - Basic account policies
3. **File Permissions** (~30 minutes) - Quick security wins
4. **PAM Password Policy** (~2 hours) - Complex testing required
5. **sudo Hardening** (~1 hour) - Significant security improvement
6. **Advanced SSH** (~1 hour) - Enhance existing implementation
7. **Complete auditd Rules** (~3 hours) - Most complex implementation

**Total Phase 2 estimate**: ~10 hours development + testing

## References

- [CIS Ubuntu Linux 24.04 LTS Benchmark v1.0.0](https://rayasec.com/wp-content/uploads/CIS-Benchmark/Ubuntu-Linux/CIS_Ubuntu_Linux_24.04_LTS_Benchmark_v1.0.0.pdf)
- [CIS Debian Linux 12 Benchmark v1.1.0](https://itsecure.hu/wp-content/uploads/2025/05/CIS_Debian_Linux_12_Benchmark_v1.1.0.pdf)
- [NIST SP 800-53 Security Controls](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final)
- [Ansible-Lockdown UBUNTU24-CIS](https://github.com/ansible-lockdown/UBUNTU24-CIS-Audit)

---

**Last updated**: May 2026  
**Next review**: Phase 2 implementation start