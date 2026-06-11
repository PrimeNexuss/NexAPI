
```
███╗   ██╗███████╗██╗  ██╗ █████╗ ██████╗ ██╗
████╗  ██║██╔════╝╚██╗██╔╝██╔══██╗██╔══██╗██║
██╔██╗ ██║█████╗   ╚███╔╝ ███████║██████╔╝██║
██║╚██╗██║██╔══╝   ██╔██╗ ██╔══██║██╔═══╝ ██║
██║ ╚████║███████╗██╔╝ ██╗██║  ██║██║     ██║
╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝
```

# NexAPI — API Penetration Testing Lab

**A deliberately vulnerable REST API for security research and offensive web exploitation practice**

![Ruby](https://img.shields.io/badge/Ruby_on_Rails-CC0000?style=for-the-badge&logo=ruby-on-rails&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![OWASP](https://img.shields.io/badge/OWASP_API_Top_10-000000?style=for-the-badge&logo=owasp&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-red?style=for-the-badge)

> **Nex-Experience | Offensive Security Research**
> Author: Greg Ochieng (Primenexuss)
> GitHub: [github.com/PrimeNexuss](https://github.com/PrimeNexuss)

</div>

---

## ⚠️ Legal Disclaimer

> This project is intended **strictly for educational and authorized security research purposes only**.
> All vulnerabilities are intentionally implemented in an isolated lab environment.
> **Do NOT deploy this application on a public server or production environment.**
> The author assumes no liability for misuse of any techniques documented herein.
> Always obtain written authorization before conducting security assessments.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Lab Setup](#lab-setup)
- [Vulnerability Index](#vulnerability-index)
- [Tools & Methodology](#tools--methodology)
- [Attack Surface Map](#attack-surface-map)
- [OWASP API Top 10 Coverage](#owasp-api-top-10-coverage)
- [Remediation Summary](#remediation-summary)
- [References](#references)

---

## Overview

**NexAPI** is a deliberately vulnerable Ruby on Rails REST API simulating a fictional financial services platform called **NexBank**. It implements all ten vulnerabilities from the [OWASP API Security Top 10 (2023)](https://owasp.org/API-Security/editions/2023/en/0x11-t10/) in a realistic, exploitable context.

The goal is to practice API penetration testing methodology in a controlled environment — moving from endpoint discovery through exploitation to documented findings, mirroring real-world engagements.

**Scope of this research:**

| Category | Detail |
|---|---|
| Target | NexAPI v1.0 (NexBank Simulation) |
| Stack | Ruby on Rails 7, PostgreSQL, JWT |
| Environment | Local VirtualBox / Docker (isolated) |
| Methodology | OWASP API Top 10 (2023) |
| Tools | Burp Suite, ffuf, jwt_tool, Postman, curl |
| Author | Greg Ochieng |
| Date | June 2026 |

---

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                   NexBank API                       │
│                                                     │
│  ┌──────────┐    ┌──────────┐    ┌──────────────┐   │
│  │  Client  │───▶│  Rails   │───▶│  PostgreSQL  │   │
│  │ (Burp/   │    │ API      │    │  Database    │   │
│  │  curl)   │    │  :3000   │    │  :5432       │   │
│  └──────────┘    └──────────┘    └──────────────┘   │
│                       │                             │
│              ┌────────┴────────┐                    │
│              │   API Routes    │                    │
│              │                 │                    │
│              │  /api/v1/*      │  ← Primary         │
│              │  /api/v0/*      │  ← Legacy (API9)   │
│              │  /api/admin/*   │  ← Admin (API5)    │
│              │  /api/webhooks  │  ← SSRF (API7)     │
│              └─────────────────┘                    │
└─────────────────────────────────────────────────────┘
```

**API Endpoints Overview:**

```
POST   /api/v1/auth/register          User registration
POST   /api/v1/auth/login             Authentication → JWT
GET    /api/v1/users/:id              User profile (BOLA)
PATCH  /api/v1/users/:id              Update user (Mass Assignment)
GET    /api/v1/accounts/:id           Account details (BOLA)
POST   /api/v1/accounts/:id/transfer  Transfer funds (Business Logic)
GET    /api/v1/transactions           Transaction history
POST   /api/v1/webhooks               Webhook registration (SSRF)
GET    /api/admin/users               Admin user list (BFLA)
GET    /api/v0/users                  Legacy endpoint (Inv. Management)
```

---

## Lab Setup

### Prerequisites

```bash
# System requirements
ruby >= 3.2.0
rails >= 7.1.0
postgresql >= 14
bundler >= 2.4.0
```

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/PrimeNexuss/NexAPI.git
cd NexAPI

# 2. Run the automated setup script
chmod +x setup/install.sh
./setup/install.sh

# 3. Seed the vulnerable database
rails db:create db:migrate db:seed

# 4. Start the server
rails server -p 3000 -b 0.0.0.0
```

### Test Users (Post-Seed)

| Role | Email | Password | Notes |
|------|-------|----------|-------|
| Admin | admin@nexbank.com | Admin@123 | Full privileges |
| User 1 | alice@nexbank.com | Password1! | Account ID: 1 |
| User 2 | bob@nexbank.com | Password2! | Account ID: 2 |
| User 3 | carol@nexbank.com | Password3! | Account ID: 3 |

### Verify Installation

```bash
curl -s http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"alice@nexbank.com","password":"Password1!"}' | jq .
```

Expected response:
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": { "id": 1, "email": "alice@nexbank.com", "role": "user" }
}
```

---

## Vulnerability Index

| # | OWASP ID | Vulnerability | Severity | Write-up |
|---|----------|---------------|----------|----------|
| 1 | API1:2023 | Broken Object Level Authorization (BOLA) | 🔴 Critical | [View →](exploits/API1_Broken_Object_Level_Authorization.md) |
| 2 | API2:2023 | Broken Authentication | 🔴 Critical | [View →](exploits/API2_Broken_Authentication.md) |
| 3 | API3:2023 | Broken Object Property Level Authorization | 🟠 High | [View →](exploits/API3_Broken_Object_Property_Level_Authorization.md) |
| 4 | API4:2023 | Unrestricted Resource Consumption | 🟠 High | [View →](exploits/API4_Unrestricted_Resource_Consumption.md) |
| 5 | API5:2023 | Broken Function Level Authorization | 🔴 Critical | [View →](exploits/API5_Broken_Function_Level_Authorization.md) |
| 6 | API6:2023 | Unrestricted Access to Sensitive Business Flows | 🟠 High | [View →](exploits/API6_Unrestricted_Access_To_Sensitive_Business_Flows.md) |
| 7 | API7:2023 | Server-Side Request Forgery | 🔴 Critical | [View →](exploits/API7_Server_Side_Request_Forgery.md) |
| 8 | API8:2023 | Security Misconfiguration | 🟡 Medium | [View →](exploits/API8_Security_Misconfiguration.md) |
| 9 | API9:2023 | Improper Inventory Management | 🟡 Medium | [View →](exploits/API9_Improper_Inventory_Management.md) |
| 10 | API10:2023 | Unsafe Consumption of APIs | 🟠 High | [View →](exploits/API10_Unsafe_Consumption_Of_APIs.md) |

---

## Tools & Methodology

### Tools Used

| Tool | Purpose |
|------|---------|
| **Burp Suite Community** | HTTP interception, replay, active scanning |
| **ffuf** | Endpoint discovery, parameter fuzzing |
| **jwt_tool** | JWT decode, secret brute-force, algorithm confusion |
| **Postman** | Manual request crafting, collection management |
| **mitmproxy** | Traffic analysis, scripted interception |
| **curl** | PoC scripting, quick validation |
| **jq** | JSON response parsing |

### Engagement Methodology

```
Phase 1: Reconnaissance
    └── Endpoint enumeration (ffuf)
    └── API documentation discovery
    └── Authentication mechanism analysis

Phase 2: Authentication Testing
    └── JWT analysis (jwt_tool)
    └── Credential brute-force
    └── Token manipulation

Phase 3: Authorization Testing
    └── BOLA (Horizontal privilege escalation)
    └── BFLA (Vertical privilege escalation)
    └── Mass assignment testing

Phase 4: Business Logic Testing
    └── Rate limiting bypass
    └── Transaction limit bypass
    └── Workflow manipulation

Phase 5: Infrastructure Testing
    └── SSRF
    └── Security misconfiguration
    └── Legacy endpoint discovery

Phase 6: Reporting
    └── Finding documentation
    └── PoC validation
    └── Remediation recommendations
```

---

## Attack Surface Map

```
[Unauthenticated]
    POST /api/v1/auth/register   → API4 (no rate limit)
    POST /api/v1/auth/login      → API4 (no rate limit), API2 (weak JWT)
    GET  /api/v0/users           → API9 (legacy, no auth)

[Authenticated — Low Privilege]
    GET    /api/v1/users/:id     → API1 (BOLA — access other users)
    PATCH  /api/v1/users/:id     → API3 (mass assignment — escalate role)
    GET    /api/v1/accounts/:id  → API1 (BOLA — access other accounts)
    POST   /api/v1/accounts/:id/transfer → API6 (no transfer limits)
    POST   /api/v1/webhooks      → API7 (SSRF via webhook URL)

[Authenticated — Admin Function]
    GET  /api/admin/users        → API5 (BFLA — accessible by low-priv users)

[Infrastructure]
    All endpoints                → API8 (verbose errors, CORS wildcard, debug mode)
    Third-party webhook data     → API10 (unsafe consumption)
```

---

## OWASP API Top 10 Coverage

```
API1:2023  Broken Object Level Authorization          ██████████  Covered
API2:2023  Broken Authentication                      ██████████  Covered
API3:2023  Broken Object Property Level Authorization ██████████  Covered
API4:2023  Unrestricted Resource Consumption          ██████████  Covered
API5:2023  Broken Function Level Authorization        ██████████  Covered
API6:2023  Unrestricted Access to Sensitive Flows     ██████████  Covered
API7:2023  Server-Side Request Forgery                ██████████  Covered
API8:2023  Security Misconfiguration                  ██████████  Covered
API9:2023  Improper Inventory Management              ██████████  Covered
API10:2023 Unsafe Consumption of APIs                 ██████████  Covered

Coverage: 10/10 (100%)
```

---

## Remediation Summary

| # | Vulnerability | Remediation |
|---|---------------|-------------|
| API1 | BOLA | Validate object ownership server-side on every request |
| API2 | Broken Auth | Use strong JWT secrets, enforce expiry, rotate tokens |
| API3 | Mass Assignment | Use strong parameter filtering (`permit` whitelist) |
| API4 | Rate Limiting | Implement `rack-attack` with per-IP request throttling |
| API5 | BFLA | Enforce role-based access control (RBAC) on all routes |
| API6 | Business Logic | Implement server-side transaction limits and velocity checks |
| API7 | SSRF | Validate and allowlist webhook URLs; block internal ranges |
| API8 | Misconfiguration | Disable debug mode in production; restrict CORS origins |
| API9 | Inv. Management | Decommission legacy endpoints; maintain API inventory |
| API10 | Unsafe Consumption | Validate and sanitize all third-party API responses |

---

## References

- [OWASP API Security Top 10 2023](https://owasp.org/API-Security/editions/2023/en/0x11-t10/)
- [PortSwigger Web Security Academy — API Testing](https://portswigger.net/web-security/api-testing)
- [HackTricks — API Pentesting](https://book.hacktricks.xyz/network-services-pentesting/pentesting-web/api)
- [jwt_tool GitHub](https://github.com/ticarpi/jwt_tool)
- [ffuf GitHub](https://github.com/ffuf/ffuf)
- [Rails Security Guide](https://guides.rubyonrails.org/security.html)

---

<div align="center">

**Nex-Experience | Offensive Security Research**
Built by [Primenexuss](https://github.com/PrimeNexuss) · University of Nairobi · Department of Information Science

*"Know your enemy and know yourself." — Sun Tzu*

</div>
