# Web Application Security Assessment & VAPT Reporting Lab

A hands-on local Web Application Vulnerability Assessment and Penetration Testing (VAPT) project focused on identifying, validating, documenting, remediating, and retesting common web application security vulnerabilities.

The project demonstrates an end-to-end VAPT lifecycle using a deliberately vulnerable local web application built for security testing and interview demonstration.

---

## 1. Project Overview

**Project Name:** Web Application Security Assessment & VAPT Reporting Lab

**Assessment Type:** Web Application VAPT

**Environment:** Local authorized security testing laboratory

**Target Application:**

```text
http://127.0.0.1:3000
```

**Operating System:**

```text
Kali Linux
```

**Application Technology:**

```text
Node.js
Express.js
```

The project follows a practical security assessment workflow:

```text
Reconnaissance
      ↓
Application Mapping
      ↓
Manual Security Testing
      ↓
Automated Scanning
      ↓
Vulnerability Validation
      ↓
Evidence Collection
      ↓
Severity Assessment
      ↓
OWASP/CWE Mapping
      ↓
Remediation
      ↓
Retesting
      ↓
Final Reporting
```

---

## 2. Objectives

The primary objectives of this project are:

* Understand the attack surface of a web application.
* Perform application mapping and reconnaissance.
* Test authentication and authorization controls.
* Test session security.
* Identify common web application vulnerabilities.
* Validate automated scanner findings manually.
* Collect reproducible security evidence.
* Map findings to OWASP categories and CWE identifiers.
* Implement security remediation.
* Retest vulnerabilities after remediation.
* Produce professional VAPT documentation.
* Demonstrate practical VAPT methodology during interviews.

---

## 3. Scope

### In-Scope

The assessment covered the following application functionality:

```text
/login
/register
/profile
/products
/comments
/upload
/admin
/api/users
```

Security testing included:

* Authentication
* Authorization
* Session management
* REST API security
* Input validation
* Reflected XSS
* CSRF
* SQL Injection testing
* Error handling
* Security headers
* Security misconfiguration
* Path traversal assessment
* File upload assessment
* Automated vulnerability scanning
* Manual validation
* Remediation and retesting

### Out of Scope

The following were not treated as confirmed vulnerabilities when the required attack surface was unavailable or the vulnerability could not be reproduced:

* SQL Injection
* Classic URL-based IDOR
* Path Traversal
* Actual File Upload Vulnerability
* SSRF
* GraphQL vulnerabilities
* HTTP Request Smuggling
* XXE exploitation
* Deserialization vulnerability
* CORS misconfiguration

---

## 4. Technology Stack

| Component         | Technology               |
| ----------------- | ------------------------ |
| Operating System  | Kali Linux               |
| Virtualization    | VMware                   |
| Backend           | Node.js                  |
| Framework         | Express.js               |
| Testing Proxy     | Burp Suite               |
| HTTP Testing      | cURL                     |
| Automated Scanner | Nuclei                   |
| Browser Testing   | Chromium                 |
| Documentation     | Markdown                 |
| Evidence          | Text files / screenshots |

---

## 5. Tools Used

### Burp Suite

Used for:

* HTTP request interception
* HTTP history analysis
* Request modification
* Repeater-based manual testing
* Parameter manipulation
* Authentication and authorization testing

### cURL

Used for:

* HTTP request generation
* Header inspection
* Authentication testing
* Cookie handling
* API testing
* CSRF testing
* XSS validation
* Error-response analysis

### Nuclei

Used for:

* Automated vulnerability detection
* Security template-based scanning
* Identifying potential issues for manual validation

Important:

> Automated scanner results were treated as potential findings and manually validated before being documented as confirmed vulnerabilities.

---

## 6. Application Architecture

```text
                 Browser
                    |
                    v
              Burp Suite
                    |
                    v
          http://127.0.0.1:3000
                    |
                    v
             Express.js App
                    |
        +-----------+-----------+
        |           |           |
      Web UI       REST API   Security
                              Controls
```

---

## 7. Application Modules

The training application contains:

### Authentication

```text
/login
/register
```

### User Functionality

```text
/profile
/products
/comments
```

### Administrative Functionality

```text
/admin
```

### API

```text
/api/users
```

### File Upload Interface

```text
/upload
```

The upload functionality was intentionally disabled in the final training build because no backend upload processing was implemented.

---

## 8. VAPT Methodology

The assessment was performed using the following methodology:

### Phase 1 — Reconnaissance

* Application discovery
* Endpoint identification
* HTTP response analysis
* Security header inspection

### Phase 2 — Application Mapping

Identified application functionality and important endpoints.

### Phase 3 — Manual Testing

Performed tests against:

* Authentication
* Authorization
* Sessions
* API endpoints
* Input handling
* XSS
* CSRF
* Error handling
* Security configuration

### Phase 4 — Automated Testing

Nuclei was used to identify potential security issues.

### Phase 5 — Manual Validation

Potential findings were manually reproduced and verified.

### Phase 6 — Evidence Collection

Captured:

* HTTP requests
* HTTP responses
* Application behavior
* Command output
* Retest evidence

### Phase 7 — Remediation

Security controls were implemented in the application.

### Phase 8 — Retesting

Previously identified findings were tested again against the remediated application.

---

# 9. Findings Summary

The original vulnerable build produced seven documented security findings.

| ID   | Finding                                            | Classification      | Status |
| ---- | -------------------------------------------------- | ------------------- | ------ |
| F-01 | Verbose Error / Stack Trace Disclosure             | CWE-209 / OWASP A05 | Fixed  |
| F-02 | Missing Authentication on `/profile`               | OWASP A01           | Fixed  |
| F-03 | Missing Authentication / Authorization on `/admin` | OWASP A01           | Fixed  |
| F-04 | Unauthenticated REST API Data Exposure             | OWASP A01           | Fixed  |
| F-05 | Invalid Bearer Token Acceptance                    | OWASP A07           | Fixed  |
| F-06 | Reflected XSS                                      | CWE-79 / OWASP A03  | Fixed  |
| F-07 | CSRF Protection Weakness                           | CWE-352 / OWASP A01 | Fixed  |

---

# 10. Detailed Findings

## F-01 — Verbose Error / Stack Trace Disclosure

### Description

The original application exposed detailed server-side error information when malformed input was submitted to the login endpoint.

The response included:

* Node.js error information
* Stack trace
* Application source-code path

### Security Impact

Verbose errors can disclose internal application implementation details and assist further reconnaissance.

### Classification

```text
CWE-209
OWASP A05 — Security Misconfiguration
```

### Remediation

Implemented generic client-facing error handling and server-side logging.

### Retest

Malformed requests no longer returned stack traces or source-code paths.

**Status: FIXED**

---

## F-02 — Missing Authentication on `/profile`

### Description

The original `/profile` endpoint was accessible without authentication.

### Retest After Remediation

```text
GET /profile
```

Result:

```text
401 Unauthorized
```

Response:

```json
{"error":"Authentication required"}
```

**Status: FIXED**

---

## F-03 — Missing Authentication / Authorization on `/admin`

### Original Issue

The administrative endpoint was accessible without proper authentication and authorization controls.

### Remediation

Implemented:

* Authentication requirement
* Role-based authorization
* Administrator-only access

### Retest Matrix

```text
Unauthenticated → 401
Normal User     → 403
Administrator   → 200
```

**Status: FIXED**

---

## F-04 — Unauthenticated REST API Data Exposure

### Original Issue

The `/api/users` endpoint exposed user information without sufficient access control.

### Remediation

Implemented authentication and administrator authorization.

### Retest Matrix

```text
Unauthenticated → 401
Normal User     → 403
Administrator   → 200
```

**Status: FIXED**

---

## F-05 — Invalid Bearer Token Acceptance

### Original Issue

An invalid Bearer token was not rejected by the original API implementation.

### Remediation

Implemented validation of opaque Bearer tokens against active server-side sessions.

### Important Technical Note

The application does **not** use JWT.

Therefore, this project does not claim JWT signature validation.

### Retest

```text
Authorization: Bearer invalid-test-token
```

Result:

```text
401 Unauthorized
```

Response:

```json
{"error":"Invalid bearer token"}
```

**Status: FIXED**

---

## F-06 — Reflected Cross-Site Scripting

### Original Issue

User-controlled input from the comments functionality was reflected directly into the HTML response.

### Test Payload

```html
<script>alert(document.domain)</script>
```

The original vulnerable implementation allowed the browser to execute the injected JavaScript.

### Classification

```text
CWE-79
OWASP A03 — Injection
```

### Remediation

Implemented HTML output encoding for user-controlled content.

### Retest

The same payload was returned as encoded HTML:

```html
<p>Comment: &lt;script&gt;alert(document.domain)&lt;/script&gt;</p>
```

Browser validation confirmed:

```text
Payload displayed as text
JavaScript did not execute
No alert popup
```

**Status: FIXED**

---

## F-07 — CSRF Protection Weakness

### Original Issue

The original registration functionality did not implement effective CSRF protection.

### Remediation

Implemented:

* Session-bound CSRF tokens
* Hidden CSRF form field
* Server-side CSRF token validation
* `SameSite=Strict` session cookie configuration

### Retest

Authenticated request without a valid CSRF token:

```text
HTTP/1.1 403 Forbidden
```

Response:

```json
{"error":"Invalid CSRF token"}
```

**Status: FIXED**

---

# 11. Security Controls Implemented

The remediated application includes the following controls.

## Authentication

* Server-side session management
* Protected application endpoints
* Authentication enforcement

## Authorization

* Role-based authorization
* Administrator-only functionality
* API authorization

## Session Security

Session identifiers are generated using cryptographically secure random values.

Session cookie configuration includes:

```text
HttpOnly
SameSite=Strict
Path=/
```

## CSRF Protection

Session-bound CSRF tokens are required for protected state-changing operations.

## XSS Protection

User-controlled output is HTML encoded before being reflected into responses.

## Security Headers

Implemented:

```text
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Referrer-Policy: no-referrer
Content-Security-Policy
```

## Error Handling

Internal implementation details are not returned to clients.

---

# 12. Retesting Results

All seven documented findings were retested after remediation.

```text
F-01  Verbose Error Disclosure       PASS
F-02  Profile Authentication         PASS
F-03  Admin Authorization            PASS
F-04  REST API Authorization         PASS
F-05  Bearer Token Validation        PASS
F-06  Reflected XSS                  PASS
F-07  CSRF Protection                PASS
```

### Overall Result

```text
7 / 7 documented findings
successfully remediated
and not reproduced during retesting.
```

This result applies to the tested local training build and tested attack paths. It does not establish that the application is free of all possible vulnerabilities.

---

# 13. Evidence

Evidence is stored under:

```text
~/web-vapt-lab/evidence/
```

Example evidence files:

```text
E-RT-01-F01-verbose-error.txt

E-RT-02-F02-profile-auth.txt

E-RT-03-F03-admin-auth-user.txt
E-RT-03-F03-admin-auth-admin.txt

E-RT-04-F04-api-auth-unauth.txt
E-RT-04-F04-api-auth-user.txt
E-RT-04-F04-api-auth-admin.txt

E-RT-05-F05-token-validation.txt

E-RT-06-F06-xss.txt

E-RT-07-F07-csrf.txt
```

Evidence contains reproducible HTTP responses and retesting results.

---

# 14. Project Structure

```text
web-vapt-lab/
│
├── README.md
│
├── vulnerable-web-app/
│   ├── server.js
│   ├── server-vulnerable-backup.js
│   └── package.json
│
├── REST-API/
│
├── screenshots/
│
├── evidence/
│   ├── E-RT-01-F01-verbose-error.txt
│   ├── E-RT-02-F02-profile-auth.txt
│   ├── E-RT-03-F03-admin-auth-user.txt
│   ├── E-RT-03-F03-admin-auth-admin.txt
│   ├── E-RT-04-F04-api-auth-unauth.txt
│   ├── E-RT-04-F04-api-auth-user.txt
│   ├── E-RT-04-F04-api-auth-admin.txt
│   ├── E-RT-05-F05-token-validation.txt
│   ├── E-RT-06-F06-xss.txt
│   └── E-RT-07-F07-csrf.txt
│
├── notes/
│   └── application-map.txt
│
├── report/
│
└── scans/
```

---

# 15. How to Run the Lab

## Clone or access the project

```bash
cd ~/web-vapt-lab/vulnerable-web-app
```

## Install dependencies

```bash
npm install
```

## Start the application

```bash
npm start
```

Expected:

```text
Secure VAPT Lab running at http://127.0.0.1:3000
```

## Verify the application

```bash
curl -i http://127.0.0.1:3000/
```

Open in a browser:

```text
http://127.0.0.1:3000
```

---

# 16. Useful VAPT Commands

### Inspect response headers

```bash
curl -I http://127.0.0.1:3000/
```

### Inspect headers and body

```bash
curl -i http://127.0.0.1:3000/
```

### Test authentication

```bash
curl -i http://127.0.0.1:3000/profile
```

### Save cookies

```bash
curl -i -c /tmp/vapt-cookies.txt \
-X POST http://127.0.0.1:3000/login \
-H 'Content-Type: application/x-www-form-urlencoded' \
--data 'username=bhola&password=Test%4012345'
```

### Reuse cookies

```bash
curl -i \
-b /tmp/vapt-cookies.txt \
http://127.0.0.1:3000/profile
```

### Test API authorization

```bash
curl -i http://127.0.0.1:3000/api/users
```

### Syntax validation

```bash
node --check server.js
```

---

# 17. Key VAPT Principle

A scanner result or unusual response is not automatically a confirmed vulnerability.

The project follows:

```text
TEST
 ↓
RESULT
 ↓
VALIDATE
 ↓
CONCLUSION
 ↓
EVIDENCE
 ↓
IMPACT
 ↓
REMEDIATION
 ↓
RETEST
```

This approach reduces false positives and produces reproducible security findings.

---

# 18. Interview Demonstration

The project can be demonstrated using the following flow:

```text
1. Introduce the application
2. Explain scope
3. Show application mapping
4. Demonstrate Burp Suite workflow
5. Show vulnerability evidence
6. Explain OWASP/CWE mapping
7. Show remediation
8. Demonstrate retesting
9. Show evidence directory
10. Explain final security state
```

### Recommended 5-Minute Demo

```text
00:00–00:30  Project introduction
00:30–01:00  Architecture and scope
01:00–02:00  VAPT methodology
02:00–03:15  Key findings
03:15–04:15  Remediation
04:15–05:00  Retesting and conclusion
```

---

# 19. Key Interview Talking Points

### Authentication vs Authorization

```text
Authentication → Who are you?
Authorization  → What are you allowed to access?
```

### XSS

```text
Untrusted Input
      ↓
Unsafe Output
      ↓
Browser interprets HTML/JavaScript
```

Remediation:

```text
Output Encoding
```

### CSRF

```text
Authenticated Browser
        +
Unwanted State-Changing Request
        ↓
CSRF Risk
```

Remediation:

```text
CSRF Token
+
SameSite Cookie
```

### API Authorization

```text
Unauthenticated → 401
Normal User     → 403
Admin           → 200
```

### VAPT Philosophy

> Find the issue, reproduce it, prove the impact, document evidence, remediate it, and retest it.

---

# 20. Security Disclaimer

This project is intended exclusively for authorized security testing, education, interview preparation, and controlled laboratory environments.

The testing techniques demonstrated in this repository should only be used against systems for which the tester has explicit authorization.

Do not use these techniques against third-party systems, applications, networks, or accounts without permission.

---

# 21. Final Project Outcome

This project demonstrates practical experience with:

* Web application reconnaissance
* Application mapping
* HTTP analysis
* Burp Suite
* cURL
* Nuclei
* Authentication testing
* Authorization testing
* Session security
* REST API security
* XSS testing
* CSRF testing
* Security headers
* Error handling
* OWASP mapping
* CWE classification
* Evidence collection
* Vulnerability remediation
* Retesting
* VAPT reporting

The project demonstrates the complete security assessment lifecycle:

```text
Identify
   ↓
Test
   ↓
Validate
   ↓
Document
   ↓
Remediate
   ↓
Retest
```

---

## Author

**Bhola Gupta**

Cybersecurity / VAPT | Web Application Security | Android Development

LinkedIn:

```text
https://www.linkedin.com/in/bhola-gupta-729668150/
```
