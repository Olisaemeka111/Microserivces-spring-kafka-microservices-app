# Security Scanning Features

This project includes comprehensive security scanning as part of the CI/CD pipeline to identify and mitigate potential vulnerabilities.

## Security Scanning Tools

### 1. OWASP Dependency Check
- Scans project dependencies for known vulnerabilities (CVEs)
- Generates HTML and XML reports
- Configured to fail the build for critical vulnerabilities (CVSS score ≥ 7)

### 2. SpotBugs with FindSecBugs
- Static code analysis to identify potential bugs and security vulnerabilities
- Includes the FindSecBugs plugin specifically designed to detect security issues
- Configured with "Max" effort and "Medium" threshold

### 3. Trivy Container Scanner
- Scans Docker container images for vulnerabilities
- Identifies issues in the OS packages and application dependencies
- Results are uploaded to GitHub Security tab in SARIF format

### 4. Dockle Container Linter
- Checks Docker containers against security best practices
- Validates container configuration against CIS benchmarks
- Helps ensure Docker images follow security best practices

## GitHub Actions Workflows

Two dedicated GitHub Actions workflows have been set up for security scanning:

1. **Security Vulnerability Scan** (`security-scan.yml`)
   - Runs on push to main, pull requests, and weekly schedule
   - Performs OWASP Dependency Check and SpotBugs analysis
   - Generates and uploads security reports as artifacts

2. **Docker Security Scan** (`docker-security-scan.yml`)
   - Runs on push to main, pull requests, and weekly schedule
   - Builds and scans all service Docker images
   - Uses Trivy and Dockle for comprehensive container security analysis

## Running Security Scans Locally

You can run the security scans locally using the following Maven commands:

```bash
# Run OWASP Dependency Check
mvn org.owasp:dependency-check-maven:check

# Run SpotBugs analysis
mvn spotbugs:check
```

## Security Reports

Security scan reports are available as GitHub Actions artifacts after each workflow run. You can download and review these reports to understand and address any identified vulnerabilities.

## Security Best Practices

This project follows these security best practices:
- Regular dependency updates
- Vulnerability scanning in CI/CD pipeline
- Static code analysis
- Container security scanning
- Secure configuration validation
