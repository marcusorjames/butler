# Security Policy

## Supported versions

Security fixes are applied to the latest release and to `main`.

## Reporting a vulnerability

Report vulnerabilities privately through GitHub: open the repository's **Security** tab and choose **Report a vulnerability**. Please do not open a public issue.

Include the affected command or template, the steps to reproduce, and the impact you observed. You can expect an acknowledgement within a few days and an update once the report has been assessed.

## Scope

Butler runs local development stacks. Areas most relevant to security reports include:

- shell injection through site names, template names or environment values
- unsafe handling of files in the sites and projects directories
- exposure of credentials from `.env` files, for example `NGROK_AUTHTOKEN` and `MYSQL_PASSWORD`
- services bound to network interfaces beyond what a template documents
