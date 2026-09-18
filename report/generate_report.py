from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import mm
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle,
    PageBreak, KeepTogether
)

OUTPUT = "/home/kali/web-vapt-lab/report/Web_VAPT_Final_Report.pdf"

doc = SimpleDocTemplate(
    OUTPUT,
    pagesize=A4,
    rightMargin=18*mm,
    leftMargin=18*mm,
    topMargin=18*mm,
    bottomMargin=18*mm
)

styles = getSampleStyleSheet()

title = ParagraphStyle(
    "TitleCustom",
    parent=styles["Title"],
    alignment=TA_CENTER,
    fontSize=24,
    leading=30,
    spaceAfter=12
)

subtitle = ParagraphStyle(
    "Subtitle",
    parent=styles["Normal"],
    alignment=TA_CENTER,
    fontSize=12,
    leading=18
)

heading = ParagraphStyle(
    "HeadingCustom",
    parent=styles["Heading1"],
    fontSize=16,
    leading=20,
    spaceBefore=12,
    spaceAfter=8
)

subheading = ParagraphStyle(
    "SubHeadingCustom",
    parent=styles["Heading2"],
    fontSize=12,
    leading=16,
    spaceBefore=8,
    spaceAfter=5
)

body = ParagraphStyle(
    "BodyCustom",
    parent=styles["BodyText"],
    fontSize=9.5,
    leading=14,
    spaceAfter=6
)

small = ParagraphStyle(
    "Small",
    parent=styles["BodyText"],
    fontSize=8,
    leading=11
)

story = []

# COVER
story.append(Spacer(1, 35*mm))
story.append(Paragraph("WEB APPLICATION SECURITY<br/>ASSESSMENT & VAPT REPORT", title))
story.append(Spacer(1, 8*mm))
story.append(Paragraph("Web VAPT Training Lab", subtitle))
story.append(Spacer(1, 5*mm))
story.append(Paragraph("Target: http://127.0.0.1:3000", subtitle))
story.append(Spacer(1, 20*mm))
story.append(Paragraph("Prepared by: Bhola Gupta", subtitle))
story.append(Spacer(1, 5*mm))
story.append(Paragraph("Assessment Type: Authorized Local Security Assessment", subtitle))
story.append(PageBreak())

# EXECUTIVE SUMMARY
story.append(Paragraph("1. Executive Summary", heading))
story.append(Paragraph(
    "This project demonstrates an end-to-end Web Application Vulnerability "
    "Assessment and Penetration Testing workflow against an intentionally "
    "controlled local training application. The assessment covered application "
    "mapping, reconnaissance, authentication, authorization, session handling, "
    "injection testing, XSS, CSRF, API security, security headers, error handling, "
    "automated scanning, evidence collection, remediation and retesting.",
    body
))
story.append(Paragraph(
    "Seven security findings were documented during the initial assessment. "
    "Remediation controls were then implemented and the affected functionality "
    "was retested. The current local build passed the documented remediation "
    "checks for all seven findings.",
    body
))

# SCOPE
story.append(Paragraph("2. Scope", heading))
scope_data = [
    ["Item", "Details"],
    ["Target", "http://127.0.0.1:3000"],
    ["Environment", "Kali Linux local laboratory"],
    ["Application", "Node.js / Express training application"],
    ["Testing Type", "Manual + automated supporting validation"],
    ["Primary Tools", "cURL, Burp Suite, Nuclei, browser"],
    ["Authorization", "Controlled local training environment"],
]
t = Table(scope_data, colWidths=[45*mm, 125*mm])
t.setStyle(TableStyle([
    ("BACKGROUND", (0,0), (-1,0), colors.lightgrey),
    ("GRID", (0,0), (-1,-1), 0.5, colors.grey),
    ("FONTNAME", (0,0), (-1,0), "Helvetica-Bold"),
    ("FONTSIZE", (0,0), (-1,-1), 8.5),
    ("VALIGN", (0,0), (-1,-1), "TOP"),
    ("BOTTOMPADDING", (0,0), (-1,-1), 6),
    ("TOPPADDING", (0,0), (-1,-1), 6),
]))
story.append(t)

# METHODOLOGY
story.append(Paragraph("3. VAPT Methodology", heading))
methodology = [
    "1. Scope Definition",
    "2. Application Mapping",
    "3. Reconnaissance",
    "4. Burp Suite and cURL based manual testing",
    "5. Authentication and authorization testing",
    "6. Injection and XSS testing",
    "7. CSRF and API security testing",
    "8. Security configuration and error handling review",
    "9. Automated supporting scan",
    "10. Evidence collection",
    "11. OWASP mapping and severity assessment",
    "12. Remediation",
    "13. Retesting",
]
for item in methodology:
    story.append(Paragraph(item, body))

# FINDINGS SUMMARY
story.append(Paragraph("4. Findings Summary", heading))
findings = [
    ["ID", "Finding", "Severity", "Status"],
    ["F-01", "Verbose Error / Stack Trace Disclosure", "Medium", "Fixed"],
    ["F-02", "Missing Authentication on /profile", "Medium", "Fixed"],
    ["F-03", "Missing Authorization on /admin", "Medium", "Fixed"],
    ["F-04", "Unauthenticated REST API Exposure", "Medium", "Fixed"],
    ["F-05", "Invalid Bearer Token Accepted", "Medium", "Fixed"],
    ["F-06", "Reflected XSS", "Medium", "Fixed"],
    ["F-07", "CSRF Protection Weakness", "Low/Medium", "Fixed"],
]
t = Table(findings, colWidths=[15*mm, 80*mm, 30*mm, 25*mm])
t.setStyle(TableStyle([
    ("BACKGROUND", (0,0), (-1,0), colors.lightgrey),
    ("GRID", (0,0), (-1,-1), 0.5, colors.grey),
    ("FONTNAME", (0,0), (-1,0), "Helvetica-Bold"),
    ("FONTSIZE", (0,0), (-1,-1), 7.5),
    ("VALIGN", (0,0), (-1,-1), "TOP"),
    ("BOTTOMPADDING", (0,0), (-1,-1), 5),
    ("TOPPADDING", (0,0), (-1,-1), 5),
]))
story.append(t)

# DETAILED FINDINGS
story.append(Paragraph("5. Detailed Findings", heading))

detailed = [
    (
        "F-01 — Verbose Error / Stack Trace Information Disclosure",
        "CWE-209 / OWASP A05",
        "A malformed request originally caused the application to expose a server-side "
        "TypeError and source-code file path in the HTTP response.",
        "Information disclosure can reveal implementation details and filesystem paths "
        "that assist further testing or exploitation.",
        "Generic client-facing error responses were implemented while detailed errors are "
        "logged server-side.",
        "Retest returned HTTP 401 with a generic authentication error and no stack trace."
    ),
    (
        "F-02 — Missing Authentication Enforcement on /profile",
        "OWASP A01 — Broken Access Control",
        "The original /profile endpoint returned user information without requiring an "
        "authenticated session.",
        "Unauthenticated users could access protected user information.",
        "Session-based authentication and an authentication middleware were implemented.",
        "Unauthenticated request now returns HTTP 401."
    ),
    (
        "F-03 — Missing Authorization on /admin",
        "OWASP A01 — Broken Access Control",
        "The original administrative endpoint was directly accessible without authentication "
        "or role validation.",
        "Administrative functionality could be accessed by unauthorized users.",
        "Authentication plus role-based authorization was implemented.",
        "Unauthenticated users receive 401, normal users receive 403, and admin receives 200."
    ),
    (
        "F-04 — Unauthenticated REST API Data Exposure",
        "OWASP A01 — Broken Access Control",
        "The original /api/users endpoint exposed user and role information without proper "
        "authorization.",
        "Sensitive application data could be disclosed to unauthenticated users.",
        "Authentication and admin authorization were added to the API endpoint.",
        "Unauthenticated: 401. Normal user: 403. Admin: 200."
    ),
    (
        "F-05 — Invalid Bearer Token Accepted",
        "OWASP A07 — Identification and Authentication Failures",
        "An invalid Bearer token was originally accepted by the API.",
        "Improper token validation can allow unauthorized API access.",
        "Opaque Bearer token validation was implemented using server-side session state.",
        "Invalid Bearer token now returns HTTP 401. The implementation does not claim JWT signature validation."
    ),
    (
        "F-06 — Reflected Cross-Site Scripting",
        "CWE-79 / OWASP A03 — Injection",
        "The comments endpoint originally reflected user-controlled HTML/JavaScript without "
        "output encoding. A script payload executed in the browser.",
        "Successful XSS can execute attacker-controlled JavaScript in the victim's browser.",
        "User-controlled output is HTML-escaped before rendering.",
        "The same payload is now displayed as encoded text and no JavaScript executes."
    ),
    (
        "F-07 — CSRF Protection Weakness",
        "CWE-352 / OWASP A01",
        "The original state-changing registration request did not use a CSRF token and accepted "
        "a cross-origin-style request.",
        "An authenticated user's browser could potentially be induced to perform an unintended "
        "state-changing action.",
        "Session-bound CSRF tokens and SameSite=Strict session cookies were implemented.",
        "Authenticated request without a valid CSRF token now returns HTTP 403."
    ),
]

for title_text, mapping, description, impact, remediation, retest in detailed:
    story.append(KeepTogether([
        Paragraph(title_text, subheading),
        Paragraph("<b>Mapping:</b> " + mapping, body),
        Paragraph("<b>Description:</b> " + description, body),
        Paragraph("<b>Impact:</b> " + impact, body),
        Paragraph("<b>Remediation:</b> " + remediation, body),
        Paragraph("<b>Retest:</b> " + retest, body),
    ]))

# SECURITY CONTROLS
story.append(PageBreak())
story.append(Paragraph("6. Security Controls Implemented", heading))

controls = [
    "Random session identifiers using cryptographically secure random bytes.",
    "HttpOnly and SameSite=Strict session cookies.",
    "Authentication middleware for protected resources.",
    "Role-based authorization for administrative functionality.",
    "Opaque Bearer token validation.",
    "HTML output encoding for reflected user input.",
    "Session-bound CSRF token validation.",
    "Content Security Policy.",
    "X-Content-Type-Options: nosniff.",
    "X-Frame-Options: DENY.",
    "Referrer-Policy: no-referrer.",
    "Generic client-facing error messages.",
    "Server-side error logging without exposing stack traces.",
]
for item in controls:
    story.append(Paragraph("• " + item, body))

# RETEST
story.append(Paragraph("7. Retesting Results", heading))

retest_data = [
    ["Finding", "Retest", "Result"],
    ["F-01", "Malformed request / stack trace", "PASS"],
    ["F-02", "Unauthenticated /profile", "PASS"],
    ["F-03", "Admin access control matrix", "PASS"],
    ["F-04", "REST API authorization", "PASS"],
    ["F-05", "Invalid Bearer token", "PASS"],
    ["F-06", "Reflected XSS payload", "PASS"],
    ["F-07", "Authenticated request without CSRF token", "PASS"],
]
t = Table(retest_data, colWidths=[30*mm, 105*mm, 25*mm])
t.setStyle(TableStyle([
    ("BACKGROUND", (0,0), (-1,0), colors.lightgrey),
    ("GRID", (0,0), (-1,-1), 0.5, colors.grey),
    ("FONTNAME", (0,0), (-1,0), "Helvetica-Bold"),
    ("FONTSIZE", (0,0), (-1,-1), 8),
    ("VALIGN", (0,0), (-1,-1), "TOP"),
    ("ALIGN", (-1,1), (-1,-1), "CENTER"),
    ("BOTTOMPADDING", (0,0), (-1,-1), 6),
    ("TOPPADDING", (0,0), (-1,-1), 6),
]))
story.append(t)

story.append(Paragraph(
    "Retesting result: 7/7 documented findings passed the implemented remediation checks "
    "on the current local build. This conclusion is limited to the tested application paths "
    "and test cases documented in the assessment.",
    body
))

# NON-CONFIRMED
story.append(Paragraph("8. Tests Not Confirmed / Not Applicable", heading))

not_confirmed = [
    "SQL Injection — tested but not confirmed.",
    "Classic URL-based IDOR — tested but not confirmed.",
    "CORS misconfiguration — not confirmed.",
    "HTTP method misconfiguration — not confirmed.",
    "Path Traversal — no user-controlled file/path functionality identified.",
    "Actual File Upload vulnerability — upload functionality disabled/not implemented.",
    "GraphQL vulnerability — GraphQL attack surface not present in the tested build.",
    "SSRF — no applicable server-side URL-fetch functionality identified.",
    "XXE — XXE exploitation not confirmed; verbose XML error handling was remediated.",
    "Insecure Deserialization — not confirmed.",
    "HTTP Request Smuggling — no applicable attack surface identified."
]
for item in not_confirmed:
    story.append(Paragraph("• " + item, body))

# EVIDENCE
story.append(Paragraph("9. Evidence", heading))
evidence = [
    "E-RT-01-F01-verbose-error.txt",
    "E-RT-02-F02-profile-auth.txt",
    "E-RT-03-F03-admin-auth-user.txt",
    "E-RT-03-F03-admin-auth-admin.txt",
    "E-RT-04-F04-api-auth-unauth.txt",
    "E-RT-04-F04-api-auth-user.txt",
    "E-RT-04-F04-api-auth-admin.txt",
    "E-RT-05-F05-token-validation.txt",
    "E-RT-06-F06-xss.txt",
    "E-RT-07-F07-csrf.txt",
]
for item in evidence:
    story.append(Paragraph("• " + item, body))

# PROJECT STRUCTURE
story.append(Paragraph("10. Project Structure", heading))
structure = """
web-vapt-lab/
├── README.md
├── vulnerable-web-app/
├── REST-API/
├── screenshots/
├── evidence/
├── notes/
├── report/
└── scans/
"""
story.append(Paragraph(structure.replace("\n", "<br/>"), small))

# INTERVIEW
story.append(Paragraph("11. Interview Demonstration Summary", heading))
story.append(Paragraph(
    "The project demonstrates the complete VAPT lifecycle: Find → Validate → Document → "
    "Fix → Retest. During an interview, the tester can demonstrate the local application, "
    "show the original security issue, explain the impact, demonstrate the remediation, "
    "and show the retest evidence.",
    body
))

story.append(Paragraph("Recommended interview flow:", subheading))
for item in [
    "1. Explain application scope and architecture.",
    "2. Demonstrate Burp Proxy and Repeater.",
    "3. Explain authentication versus authorization.",
    "4. Demonstrate XSS testing and output encoding.",
    "5. Demonstrate API authorization.",
    "6. Explain CSRF tokens and SameSite cookies.",
    "7. Show evidence files.",
    "8. Explain remediation and retesting.",
    "9. Close with the complete VAPT lifecycle."
]:
    story.append(Paragraph(item, body))

# CONCLUSION
story.append(Paragraph("12. Final Conclusion", heading))
story.append(Paragraph(
    "The assessment successfully demonstrated a practical Web Application VAPT workflow "
    "against a controlled local training environment. The project covered manual testing, "
    "automated supporting validation, evidence collection, OWASP mapping, remediation and "
    "retesting. The final build includes stronger authentication, authorization, session "
    "security, CSRF protection, output encoding, security headers and safer error handling.",
    body
))

story.append(Paragraph(
    "Security Disclaimer: This project is intended for authorized security testing and "
    "training purposes only. Testing should only be performed against systems for which "
    "explicit authorization has been obtained.",
    body
))

def add_page_number(canvas, doc):
    canvas.saveState()
    canvas.setFont("Helvetica", 8)
    canvas.drawCentredString(
        A4[0] / 2,
        10*mm,
        f"Web VAPT Lab | Page {doc.page}"
    )
    canvas.restoreState()

doc.build(
    story,
    onFirstPage=add_page_number,
    onLaterPages=add_page_number
)

print(f"PDF generated successfully: {OUTPUT}")
