---
name: security-audit
description: Comprehensive security auditing workflow covering code analysis, API security, vulnerability scanning, dependency auditing, and security hardening.
---

# Security Audit Skill

## When to Use This Skill
- Performing security audits on mobile applications, client code, and backend APIs.
- Conducting static application security testing (SAST), secrets detection, and dependency reviews.
- Testing API endpoints for authentication, authorization (RLS/RBAC), transport encryption, and injection flaws.
- Producing structured audit reports with CVE/CWE classifications, risk severity matrices, and concrete remediations.

## Methodology & Audit Phases

### Phase 1: Code Review & Secrets Detection (SAST)
- Scan for hardcoded API keys, bearer tokens, passwords, private keys, or sensitive staging endpoints.
- Verify separation between public/publishable client keys (e.g. Supabase anon key) and administrative secret keys (e.g. Supabase service_role key, Apple App Store Connect private keys).
- Inspect sensitive data handling: Keychain vs UserDefaults, clipboard leakage, logging/telemetry scrubbing (`print()`, logs, analytics).

### Phase 2: Static Dependency Analysis (SCA)
- Identify external frameworks, packages (SwiftPM, CocoaPods), and third-party libraries.
- Check dependencies against known vulnerabilities, unpinned dependencies, or insecure transport mechanisms.
- Review build configurations, App Transport Security (ATS), entitlements, and permissions.

### Phase 3: API Security & Backend Trust Boundaries
- **Transport Security**: Enforce HTTPS / TLS 1.3, evaluate certificate pinning requirements.
- **Authorization & RLS**: Ensure client apps with public API keys rely strictly on database-level Row Level Security (RLS) policies rather than client-enforced checks.
- **Injection & Input Validation**: Inspect parameter handling, URL construction, PostgREST query parameters, and JSON payloads.
- **Business Logic & Tampering**: Detect client-side state manipulation (e.g. `isPro` flags in local memory without receipt validation or server entitlement checks).

### Phase 4: Reporting & Actionable Remediation
- Classify all findings by severity: Critical, High, Medium, Low, Informational.
- Provide clear risk summaries, root cause explanations, and exact code patches for immediate remediation.
