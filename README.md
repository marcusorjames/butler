# Butler

**Your friendly dev stack helper**

## Xdebug
### PHPStorm
1. Run -> edit configurations -> Add php remote debug
1. Set name to your preference e.g. "Docker"
1. Check "Filter debug connection by IDE key"
1. Server: click on 3 dots
1. Add new server (hostname e.g.: website.local)
  1. Name: <hostname>
  1. Host: <hostname>
  1. Port: 80
  1. Debugger: Xdebug
  1. Map your route directory to /var/www/html
  1. Save
1. Ensure Server is set to your new server
1. IDE key(session id): PHPSTORM
1. When you want to debug, ensure the configuration is set to the one you just
   created e.g. "Docker"
1. Click Debug

