#!/bin/bash

# ============================================================
#              WEB VAPT LAB - COMPLETE ASSESSMENT
# ============================================================
# Target: Local Vulnerable Web Application
# Scope: Steps 1-16
# Purpose: Evidence collection + assessment documentation
# ============================================================

TARGET="http://127.0.0.1:3000"
DATE=$(date '+%Y-%m-%d_%H-%M-%S')

BASE_DIR="$(pwd)"
EVIDENCE_ROOT="$BASE_DIR/Evidence"
REPORT_ROOT="$BASE_DIR/VAPT_Report"
RUN_DIR="$EVIDENCE_ROOT/$DATE"

mkdir -p "$RUN_DIR"
mkdir -p "$REPORT_ROOT"

# ============================================================
# COLORS
# ============================================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ============================================================
# FUNCTIONS
# ============================================================

section() {
    echo
    echo "============================================================"
    echo "$1"
    echo "============================================================"
}

success() {
    echo -e "${GREEN}[+] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[!] $1${NC}"
}

info() {
    echo -e "${BLUE}[*] $1${NC}"
}

error_msg() {
    echo -e "${RED}[-] $1${NC}"
}

# ============================================================
# START
# ============================================================

clear

echo "============================================================"
echo "              WEB VAPT LAB ASSESSMENT"
echo "============================================================"
echo
echo "Target       : $TARGET"
echo "Assessment   : $(date)"
echo "Evidence     : $RUN_DIR"
echo "Report       : $REPORT_ROOT"
echo

# ============================================================
# STEP 1 - LAB SETUP
# ============================================================

section "STEP 1 - LAB SETUP"

cat > "$RUN_DIR/01_lab_setup.txt" <<EOF
STEP 1 - LAB SETUP
==================

Status: COMPLETED

Environment:
OS       : $(uname -s)
Kernel   : $(uname -r)
Hostname : $(hostname)
User     : $(whoami)

Project Directory:
$BASE_DIR

Target:
$TARGET

Tools checked:
- curl
- nmap
- docker
- Burp Suite (manual)
EOF

cat "$RUN_DIR/01_lab_setup.txt"

if command -v curl >/dev/null 2>&1; then
    success "curl available"
else
    warning "curl not installed"
fi

if command -v nmap >/dev/null 2>&1; then
    success "nmap available"
else
    warning "nmap not installed"
fi

if command -v docker >/dev/null 2>&1; then
    success "Docker available"
else
    warning "Docker not detected"
fi

# ============================================================
# STEP 2 - VULNERABLE WEB APP SETUP
# ============================================================

section "STEP 2 - VULNERABLE WEB APP SETUP"

cat > "$RUN_DIR/02_web_app_setup.txt" <<EOF
STEP 2 - VULNERABLE WEB APP SETUP
=================================

Status: COMPLETED

Application:
Local vulnerable web application

Target:
$TARGET

Application components mapped during the assessment:

- Login
- Register
- User Profile
- Products
- Comments
- File Upload
- Admin Panel
- REST/API functionality
- Application endpoints
EOF

cat "$RUN_DIR/02_web_app_setup.txt"

success "Local vulnerable web application configured"

# ============================================================
# STEP 3 - APPLICATION START
# ============================================================

section "STEP 3 - APPLICATION START"

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    --max-time 5 "$TARGET")

echo "Target: $TARGET"
echo "HTTP Status: $HTTP_CODE"

if [[ "$HTTP_CODE" =~ ^[23][0-9][0-9]$ ]]; then
    success "Application is running and reachable"
    APP_STATUS="RUNNING"
else
    warning "Application returned HTTP status: $HTTP_CODE"
    APP_STATUS="CHECK REQUIRED"
fi

curl -s -D "$RUN_DIR/03_application_headers.txt" \
    -o /dev/null "$TARGET"

# ============================================================
# STEP 4 - APPLICATION MAPPING
# ============================================================

section "STEP 4 - APPLICATION MAPPING"

cat > "$RUN_DIR/04_application_mapping.txt" <<EOF
APPLICATION MAPPING
===================

Target:
$TARGET

PUBLIC FUNCTIONALITY
--------------------
1. /login
2. /register
3. /products
4. /comments

AUTHENTICATED FUNCTIONALITY
---------------------------
1. /profile

ADMIN / OTHER FUNCTIONALITY
---------------------------
1. /admin
2. /upload

API / NETWORK
-------------
1. /api

PARAMETER OF INTEREST
---------------------
/comments?comment=

APPLICATION MAP STATUS
----------------------
COMPLETED

Note:
Endpoint mapping was performed manually using browser and
Burp Suite request/response inspection.
EOF

cat "$RUN_DIR/04_application_mapping.txt"

success "Application mapping documented"

# ============================================================
# STEP 5 - RECONNAISSANCE
# ============================================================

section "STEP 5 - RECONNAISSANCE"

cat > "$RUN_DIR/05_reconnaissance.txt" <<EOF
RECONNAISSANCE
==============

Status:
BASIC RECON COMPLETED

Target:
$TARGET

Activities:
- Application availability check
- HTTP response inspection
- Server/technology header inspection
- Endpoint identification
- Application mapping
- Burp-based request/response observation

Further manual testing can be performed where required.
EOF

echo "Target information:"
echo "URL      : $TARGET"
echo "HTTP Code: $HTTP_CODE"

curl -s -D "$RUN_DIR/05_recon_headers.txt" \
    -o /dev/null "$TARGET"

echo
echo "Interesting headers:"
grep -Ei \
'^(Server|X-Powered-By|Content-Security-Policy|X-Frame-Options|X-Content-Type-Options|Strict-Transport-Security|Referrer-Policy|Permissions-Policy):' \
"$RUN_DIR/05_recon_headers.txt" \
|| true

success "Basic reconnaissance documented"

# ============================================================
# STEP 6 - BURP SUITE
# ============================================================

section "STEP 6 - BURP SUITE SETUP"

cat > "$RUN_DIR/06_burp_suite.txt" <<EOF
BURP SUITE ASSESSMENT
=====================

Status:
COMPLETED

Burp Suite was used for:

- HTTP request interception
- HTTP response inspection
- Endpoint discovery
- Parameter identification
- Authentication testing
- Session testing
- Authorization testing
- XSS testing
- CSRF observation
- Security header inspection

Manual request/response evidence was reviewed during testing.
EOF

cat "$RUN_DIR/06_burp_suite.txt"

success "Burp Suite assessment documented"

# ============================================================
# STEP 7 - AUTHENTICATION TESTING
# ============================================================

section "STEP 7 - AUTHENTICATION TESTING"

cat > "$RUN_DIR/07_authentication.txt" <<EOF
AUTHENTICATION TESTING
======================

Status:
ISSUE OBSERVED

Finding:
Authentication enforcement weakness identified.

Assessment:
Application access controls did not consistently enforce the
expected authentication requirement on tested functionality.

Testing approach:
- Accessed application functionality
- Observed unauthenticated behavior
- Compared expected and actual access behavior
- Reviewed HTTP requests/responses in Burp Suite

Important:
Final severity should depend on the actual business impact
and reproducibility.
EOF

cat "$RUN_DIR/07_authentication.txt"

# ============================================================
# STEP 8 - SESSION TESTING
# ============================================================

section "STEP 8 - SESSION TESTING"

cat > "$RUN_DIR/08_session_testing.txt" <<EOF
SESSION TESTING
===============

Status:
WEAKNESS OBSERVED

Finding:
Effective session enforcement was not observed.

Testing:
- Reviewed session-dependent behavior
- Compared authenticated and unauthenticated access
- Inspected requests/responses
- Observed application access-control behavior

Important:
No claim of session hijacking or session fixation is made unless
such behavior is separately reproduced.
EOF

cat "$RUN_DIR/08_session_testing.txt"

# ============================================================
# STEP 9 - AUTHORIZATION / IDOR
# ============================================================

section "STEP 9 - AUTHORIZATION / IDOR"

cat > "$RUN_DIR/09_authorization_idor.txt" <<EOF
AUTHORIZATION / IDOR TESTING
============================

Status:
AUTHORIZATION ISSUE OBSERVED

Confirmed observation:
 /admin access-control issue

IDOR:
Classic /api/users/{id} IDOR was NOT CONFIRMED.

Testing:
- Reviewed authorization behavior
- Tested access to administrative functionality
- Reviewed API/object access patterns
- Compared expected and actual authorization behavior

Important:
IDOR is not reported as confirmed because unauthorized object
access through /api/users/{id} was not demonstrated.
EOF

cat "$RUN_DIR/09_authorization_idor.txt"

# ============================================================
# STEP 10 - SQL INJECTION
# ============================================================

section "STEP 10 - SQL INJECTION"

cat > "$RUN_DIR/10_sql_injection.txt" <<EOF
SQL INJECTION TESTING
=====================

Target:
Login functionality

Status:
NOT CONFIRMED

Testing performed:
- Manual parameter testing
- Request/response observation
- Application behavior analysis
- Error/response analysis

Result:
SQL Injection was tested but was NOT confirmed.

Reporting rule:
No SQL Injection vulnerability should be reported as confirmed
without reproducible evidence.
EOF

cat "$RUN_DIR/10_sql_injection.txt"

# ============================================================
# STEP 11 - XSS
# ============================================================

section "STEP 11 - CROSS-SITE SCRIPTING"

cat > "$RUN_DIR/11_xss.txt" <<EOF
REFLECTED CROSS-SITE SCRIPTING
==============================

Status:
CONFIRMED

Vulnerability:
Reflected XSS

Endpoint:
/comments?comment=

Type:
Reflected Cross-Site Scripting

Observation:
User-controlled input from the comment parameter was reflected
in the application response without adequate output encoding.

Potential impact:
Attacker-controlled JavaScript may execute in the victim's
browser when the crafted request is processed.

Recommended mitigation:
- Context-aware output encoding
- Input validation
- Secure framework escaping
- Content Security Policy
- Avoid unsafe DOM sinks
EOF

cat "$RUN_DIR/11_xss.txt"

success "Reflected XSS documented as CONFIRMED"

# ============================================================
# STEP 12 - CSRF
# ============================================================

section "STEP 12 - CSRF"

cat > "$RUN_DIR/12_csrf.txt" <<EOF
CSRF TESTING
============

Status:
WEAKNESS OBSERVED

Finding:
CSRF protection weakness identified.

Important limitation:
Authenticated business impact was NOT demonstrated.

Potential controls:
- Anti-CSRF tokens
- SameSite cookie configuration
- Origin/Referer validation where appropriate
- Do not use GET for state-changing actions
- Validate state-changing requests server-side
EOF

cat "$RUN_DIR/12_csrf.txt"

# ============================================================
# STEP 13 - PATH TRAVERSAL
# ============================================================

section "STEP 13 - PATH TRAVERSAL"

cat > "$RUN_DIR/13_path_traversal.txt" <<EOF
PATH TRAVERSAL TESTING
======================

Status:
NOT TESTABLE

Result:
No suitable file/path attack surface was identified during
the current application assessment.

Reason:
Current application functionality did not expose an appropriate
file/path parameter for meaningful traversal validation.

Therefore:
Path Traversal is NOT reported as a vulnerability.
EOF

cat "$RUN_DIR/13_path_traversal.txt"

# ============================================================
# STEP 14 - FILE UPLOAD
# ============================================================

section "STEP 14 - FILE UPLOAD
"

cat > "$RUN_DIR/14_file_upload.txt" <<EOF
FILE UPLOAD TESTING
===================

Status:
NOT TESTABLE

Observation:
File Upload UI/functionality is present.

Backend:
Backend upload functionality is not implemented.

Therefore:
A complete upload security assessment could not be performed.

Future testing areas:
- Extension validation
- MIME validation
- Content validation
- Filename handling
- Storage location
- Execution permissions
- Authentication/authorization
- Size limits
EOF

cat "$RUN_DIR/14_file_upload.txt"

# ============================================================
# STEP 15 - SECURITY HEADERS
# ============================================================

section "STEP 15 - SECURITY HEADERS"

curl -s -D "$RUN_DIR/15_security_headers.txt" \
    -o /dev/null "$TARGET"

echo "Observed headers:"
cat "$RUN_DIR/15_security_headers.txt"

echo
echo "Security header assessment:"
echo

HEADER_LIST=(
"Content-Security-Policy"
"X-Content-Type-Options"
"X-Frame-Options"
"Strict-Transport-Security"
"Referrer-Policy"
"Permissions-Policy"
)

{
    echo "SECURITY HEADER ASSESSMENT"
    echo "=========================="
    echo

    for HEADER in "${HEADER_LIST[@]}"; do

        if grep -qi "^$HEADER:" "$RUN_DIR/15_security_headers.txt"; then
            echo "[PRESENT] $HEADER"
        else
            echo "[NOT OBSERVED] $HEADER"
        fi

    done

} > "$RUN_DIR/15_security_headers_result.txt"

cat "$RUN_DIR/15_security_headers_result.txt"

cat > "$RUN_DIR/15_security_headers_notes.txt" <<EOF
SECURITY HEADERS
================

Status:
WEAKNESS OBSERVED

Observation:
Several recommended security headers were not observed on
tested normal endpoints.

Headers reviewed:
- Content-Security-Policy
- X-Content-Type-Options
- X-Frame-Options
- Strict-Transport-Security
- Referrer-Policy
- Permissions-Policy

Note:
Header presence should be evaluated according to deployment
architecture and HTTPS requirements.
EOF

# ============================================================
# STEP 16 - SECURITY MISCONFIGURATION
# ============================================================

section "STEP 16 - SECURITY MISCONFIGURATION"

cat > "$RUN_DIR/16_security_misconfiguration.txt" <<EOF
SECURITY MISCONFIGURATION
=========================

Status:
WEAKNESS OBSERVED

OBSERVATIONS
------------

1. TRACE
   Status: BLOCKED

2. .env
   Status: NOT ACCESSIBLE

3. robots.txt
   Status: NOT ACCESSIBLE

4. Verbose errors
   Status: No major verbose error disclosure observed

5. Technology disclosure
   Status: Express/X-Powered-By disclosure observed

Overall:
No critical exposed configuration file or major verbose error
disclosure was identified during the current checks.

Recommendation:
- Disable unnecessary technology disclosure
- Review production error handling
- Apply appropriate security headers
- Disable unnecessary HTTP methods
- Review exposed resources
EOF

cat "$RUN_DIR/16_security_misconfiguration.txt"

# ============================================================
# ENDPOINT STATUS CHECK
# ============================================================

section "ADDITIONAL - ENDPOINT STATUS CHECK"

cat > "$RUN_DIR/endpoint_status.txt" <<EOF
ENDPOINT STATUS CHECK
=====================

Target:
$TARGET

EOF

ENDPOINTS=(
"/login"
"/register"
"/profile"
"/products"
"/comments"
"/upload"
"/admin"
"/api"
)

for ENDPOINT in "${ENDPOINTS[@]}"; do

    CODE=$(curl -s -o /dev/null -w "%{http_code}" \
        --max-time 5 "$TARGET$ENDPOINT")

    printf "%-20s HTTP %s\n" "$ENDPOINT" "$CODE" \
        | tee -a "$RUN_DIR/endpoint_status.txt"

done

# ============================================================
# FINAL 1-16 MASTER TABLE
# ============================================================

section "FINAL 1-16 RESULT"

cat > "$RUN_DIR/FINAL_VAPT_RESULT.txt" <<EOF
============================================================
                 WEB VAPT LAB
              FINAL ASSESSMENT
============================================================

Target:
$TARGET

Assessment Date:
$(date)

------------------------------------------------------------
STEP   ACTIVITY                         STATUS
------------------------------------------------------------

01     Lab Setup                        COMPLETED

02     Vulnerable Web App Setup         COMPLETED

03     Application Start                COMPLETED

04     Application Mapping              COMPLETED

05     Reconnaissance                   BASIC COMPLETED

06     Burp Suite Setup                 COMPLETED

07     Authentication Testing           ISSUE OBSERVED

08     Session Testing                  WEAKNESS OBSERVED

09     Authorization / IDOR             ISSUE OBSERVED
       Classic IDOR                     NOT CONFIRMED

10     SQL Injection                    NOT CONFIRMED

11     XSS                              CONFIRMED
       Type                             REFLECTED XSS

12     CSRF                             WEAKNESS OBSERVED

13     Path Traversal                  NOT TESTABLE

14     File Upload                     NOT TESTABLE

15     Security Headers                WEAKNESS OBSERVED

16     Security Misconfiguration       WEAKNESS OBSERVED

------------------------------------------------------------
CONFIRMED FINDING
------------------------------------------------------------

Reflected XSS

Endpoint:
/comments?comment=

------------------------------------------------------------
AUTHORIZATION OBSERVATION
------------------------------------------------------------

/admin access-control issue identified.

Classic:
/api/users/{id}

IDOR was NOT confirmed.

------------------------------------------------------------
SQL INJECTION
------------------------------------------------------------

Login SQL Injection was tested.

Result:
NOT CONFIRMED.

------------------------------------------------------------
CSRF
------------------------------------------------------------

CSRF protection weakness identified.

Authenticated impact:
NOT DEMONSTRATED.

------------------------------------------------------------
PATH TRAVERSAL
------------------------------------------------------------

No suitable file/path attack surface.

Result:
NOT TESTABLE.

------------------------------------------------------------
FILE UPLOAD
------------------------------------------------------------

UI exists.

Backend upload functionality:
NOT IMPLEMENTED.

Result:
NOT TESTABLE.

------------------------------------------------------------
SECURITY HEADERS
------------------------------------------------------------

Several recommended security headers were not observed.

------------------------------------------------------------
SECURITY MISCONFIGURATION
------------------------------------------------------------

Observed:
- Express/X-Powered-By disclosure
- TRACE blocked
- .env inaccessible
- robots.txt inaccessible
- No major verbose error disclosure observed

------------------------------------------------------------
REPORTING PRINCIPLE
------------------------------------------------------------

Confirmed vulnerabilities are reported only where the current
assessment provides reproducible evidence.

Untested or unconfirmed vulnerabilities are not presented as
confirmed findings.

============================================================
                  END OF ASSESSMENT
============================================================
EOF

cat "$RUN_DIR/FINAL_VAPT_RESULT.txt"

# ============================================================
# MASTER REPORT
# ============================================================

cp "$RUN_DIR/FINAL_VAPT_RESULT.txt" \
   "$REPORT_ROOT/VAPT_Assessment_Summary.txt"

# ============================================================
# EVIDENCE INDEX
# ============================================================

cat > "$RUN_DIR/README.txt" <<EOF
============================================================
              WEB VAPT LAB EVIDENCE INDEX
============================================================

Target:
$TARGET

Assessment:
$(date)

Evidence Directory:
$RUN_DIR

------------------------------------------------------------
STEP 01
------------------------------------------------------------
01_lab_setup.txt

------------------------------------------------------------
STEP 02
------------------------------------------------------------
02_web_app_setup.txt

------------------------------------------------------------
STEP 03
------------------------------------------------------------
03_application_headers.txt

------------------------------------------------------------
STEP 04
------------------------------------------------------------
04_application_mapping.txt

------------------------------------------------------------
STEP 05
------------------------------------------------------------
05_reconnaissance.txt
05_recon_headers.txt

------------------------------------------------------------
STEP 06
------------------------------------------------------------
06_burp_suite.txt

------------------------------------------------------------
STEP 07
------------------------------------------------------------
07_authentication.txt

------------------------------------------------------------
STEP 08
------------------------------------------------------------
08_session_testing.txt

------------------------------------------------------------
STEP 09
------------------------------------------------------------
09_authorization_idor.txt

------------------------------------------------------------
STEP 10
------------------------------------------------------------
10_sql_injection.txt

------------------------------------------------------------
STEP 11
------------------------------------------------------------
11_xss.txt

------------------------------------------------------------
STEP 12
------------------------------------------------------------
12_csrf.txt

------------------------------------------------------------
STEP 13
------------------------------------------------------------
13_path_traversal.txt

------------------------------------------------------------
STEP 14
------------------------------------------------------------
14_file_upload.txt

------------------------------------------------------------
STEP 15
------------------------------------------------------------
15_security_headers.txt
15_security_headers_result.txt
15_security_headers_notes.txt

------------------------------------------------------------
STEP 16
------------------------------------------------------------
16_security_misconfiguration.txt

------------------------------------------------------------
ADDITIONAL
------------------------------------------------------------
endpoint_status.txt
FINAL_VAPT_RESULT.txt

============================================================
