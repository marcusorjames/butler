#!/usr/bin/env python3
import http.server
import os
import socketserver
import subprocess
import tempfile
import time

SITES_DIR = os.environ.get('BUTLER_SITES_DIR', '/sites')
TLD = os.environ.get('BUTLER_TLD', 'test')
POLL_SECS = 0.5
APP_DIR = os.path.dirname(__file__)


def parse_dotenv(path):
    env = {}
    try:
        with open(path) as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith('#') or '=' not in line:
                    continue
                key, _, val = line.partition('=')
                env[key.strip()] = val.strip().strip('"').strip("'")
    except OSError:
        pass
    return env


def find_site(subdomain):
    """Return (site_dir, site_name), preferring multi-project explicit matches."""
    try:
        entries = sorted(os.listdir(SITES_DIR))
    except OSError:
        return None, None

    # Pass 1: explicit/auto-derived BUTLER_PROJECT_* in multi-project sites.
    # A combined stack can serve multiple subdomains; match any of them here
    # before falling back to a direct site directory name match.
    for name in entries:
        site_dir = os.path.join(SITES_DIR, name)
        if not os.path.isdir(site_dir):
            continue
        env = parse_dotenv(os.path.join(site_dir, '.env'))
        projects_raw = env.get('BUTLER_PROJECTS', '')
        if not projects_raw:
            continue
        for proj in (p.strip() for p in projects_raw.split(',') if p.strip()):
            key = 'BUTLER_PROJECT_' + proj.upper().replace('-', '_')
            if env.get(key, proj) == subdomain:
                return site_dir, name

    # Pass 2: direct site directory name match.
    site_dir = os.path.join(SITES_DIR, subdomain)
    if os.path.isdir(site_dir):
        return site_dir, subdomain

    return None, None


def build_env(site_dir, site_name):
    env = os.environ.copy()
    env['BUTLER_PROJECT'] = site_name
    site_env = parse_dotenv(os.path.join(site_dir, '.env'))
    env.update(site_env)
    for proj in (p.strip() for p in site_env.get('BUTLER_PROJECTS', '').split(',') if p.strip()):
        key = 'BUTLER_PROJECT_' + proj.upper().replace('-', '_')
        env.setdefault(key, proj)
    return env


def page(title, head, body_class, content):
    return f'''<!DOCTYPE html>
<html>
<head>
  <title>{title}</title>
  <link rel="stylesheet" href="/style.css">
  {head}
</head>
<body class="{body_class}">
  {content}
</body>
</html>'''.encode()


class WatcherHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/style.css':
            self._serve_static('style.css', 'text/css')
            return

        # nginx-proxy rewrites Host to its VIRTUAL_HOST value; original is in X-Forwarded-Host
        host = (self.headers.get('X-Forwarded-Host') or self.headers.get('Host', '')).split(':')[0]
        suffix = f'.{TLD}'
        if not host.endswith(suffix):
            self._respond_not_found(host)
            return

        subdomain = host[: -len(suffix)]
        site_dir, site_name = find_site(subdomain)

        if not site_dir:
            self._respond_not_found(host)
            return

        env = build_env(site_dir, site_name)

        with tempfile.TemporaryFile() as err_f:
            proc = subprocess.Popen(
                ['docker', 'compose', '--project-directory', site_dir, 'up', '-d'],
                stdout=subprocess.DEVNULL,
                stderr=err_f,
                env=env,
            )
            time.sleep(POLL_SECS)
            rc = proc.poll()
            if rc is not None and rc != 0:
                err_f.seek(0)
                detail = err_f.read(4096).decode(errors='replace')
                self._respond_error(site_name, detail)
                return

        self._respond_starting(site_name)

    def _serve_static(self, filename, content_type):
        try:
            with open(os.path.join(APP_DIR, filename), 'rb') as f:
                body = f.read()
            self.send_response(200)
            self.send_header('Content-Type', content_type)
            self.send_header('Content-Length', len(body))
            self.end_headers()
            self.wfile.write(body)
        except OSError:
            self.send_response(404)
            self.end_headers()

    def _respond_starting(self, site):
        body = page(
            f'Starting {site}...',
            '<meta http-equiv="refresh" content="5">',
            'centered',
            f'<div class="box centered-content"><h2>Starting {site}&hellip;</h2>'
            f'<p>This page will refresh automatically.</p></div>',
        )
        self._send(200, body)

    def _respond_error(self, site, detail=''):
        detail_html = f'<pre>{detail}</pre>' if detail else ''
        body = page(
            f'Failed to start {site}',
            '',
            '',
            f'<div class="box wide"><h2 class="error">Failed to start {site}</h2>'
            f'{detail_html}'
            f'<p>Run <code>butler up {site}</code> for more detail.</p></div>',
        )
        self._send(500, body)

    def _respond_not_found(self, host):
        body = page(
            f'No site for {host}',
            '',
            'centered',
            f'<div class="box centered-content"><h2>No site for {host}</h2>'
            f'<p>Run <code>butler site add</code> to create one.</p></div>',
        )
        self._send(404, body)

    def _send(self, status, body):
        self.send_response(status)
        self.send_header('Content-Type', 'text/html')
        self.send_header('Content-Length', len(body))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        pass


class ThreadedWatcher(socketserver.ThreadingMixIn, http.server.HTTPServer):
    daemon_threads = True


if __name__ == '__main__':
    print(f'Butler watcher running — SITES_DIR={SITES_DIR} TLD={TLD}', flush=True)
    ThreadedWatcher(('', 80), WatcherHandler).serve_forever()
