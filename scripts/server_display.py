#!/usr/bin/env python3
"""
📡 ClawMobil — Pantalla de Estado del Servidor
Servidor HTTP ultraligero que muestra la IP y estado en una página web.
Abre http://localhost:8080 en cualquier navegador del YesTeL.

Uso: python3 scripts/server_display.py &
"""
import http.server
import socket
import subprocess
import os

PORT = 8080

def get_local_ip():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except:
        return "Sin conexión"

def get_tunnel_url():
    try:
        path = os.path.expanduser("~/last_tunnel_url.txt")
        with open(path) as f:
            return f.read().strip()
    except:
        return None

def is_ollama_running():
    try:
        import urllib.request
        urllib.request.urlopen("http://127.0.0.1:11434/api/tags", timeout=2)
        return True
    except:
        return False

class StatusHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        ip = get_local_ip()
        tunnel = get_tunnel_url()
        ollama_ok = is_ollama_running()

        html = f"""<!DOCTYPE html>
<html><head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta http-equiv="refresh" content="10">
<title>ClawMobil Server</title>
<style>
*{{margin:0;padding:0;box-sizing:border-box}}
body{{
  background:#030712;color:#fff;font-family:system-ui,-apple-system,sans-serif;
  display:flex;justify-content:center;align-items:center;min-height:100vh;
  padding:20px;
}}
.card{{
  background:linear-gradient(135deg,#0a1628,#1a2744);
  border:1px solid rgba(94,206,245,0.2);border-radius:24px;
  padding:40px;text-align:center;max-width:500px;width:100%;
  box-shadow:0 20px 60px rgba(0,0,0,0.5);
}}
.logo{{font-size:4rem;margin-bottom:16px}}
h1{{font-size:1.8rem;margin-bottom:8px;color:#5ecef5}}
.subtitle{{color:#8899aa;margin-bottom:32px;font-size:0.95rem}}
.info-row{{
  background:rgba(255,255,255,0.05);border-radius:12px;
  padding:16px;margin:8px 0;display:flex;justify-content:space-between;
  align-items:center;border:1px solid rgba(255,255,255,0.08);
}}
.label{{color:#8899aa;font-size:0.85rem}}
.value{{font-family:monospace;font-size:1.05rem;color:#5ecef5;font-weight:700}}
.status{{
  display:inline-block;width:10px;height:10px;border-radius:50%;
  margin-right:8px;animation:pulse 2s infinite;
}}
.online{{background:#22c55e}}
.offline{{background:#ef4444}}
@keyframes pulse{{0%,100%{{opacity:1}}50%{{opacity:0.5}}}}
.footer{{margin-top:24px;color:#556677;font-size:0.75rem}}
</style>
</head><body>
<div class="card">
  <div class="logo">🦀</div>
  <h1>ClawMobil Server</h1>
  <p class="subtitle">Tu IA privada, en tu bolsillo</p>

  <div class="info-row">
    <span class="label">Estado</span>
    <span class="value">
      <span class="status {'online' if ollama_ok else 'offline'}"></span>
      {'Ollama Activo' if ollama_ok else 'Ollama Apagado'}
    </span>
  </div>

  <div class="info-row">
    <span class="label">📶 Conectar Local</span>
    <span class="value">http://{ip}:11434</span>
  </div>

  <div class="info-row">
    <span class="label">🌐 Conectar Online</span>
    <span class="value">{tunnel if tunnel else 'Túnel apagado'}</span>
  </div>

  <p class="footer">Se actualiza cada 10s · apliarte.com</p>
</div>
</body></html>"""

        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.end_headers()
        self.wfile.write(html.encode())

    def log_message(self, *args):
        pass  # Silencioso

if __name__ == "__main__":
    ip = get_local_ip()
    print(f"📡 Pantalla de estado en: http://{ip}:{PORT}")
    print(f"   También en: http://localhost:{PORT}")
    server = http.server.HTTPServer(("0.0.0.0", PORT), StatusHandler)
    server.serve_forever()
