#!/usr/bin/env python3
import json, subprocess, threading, time, os, sys, urllib.request, urllib.parse
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse

# --- CONFIGURACIÓN DEL DISPOSITIVO ---
LISTEN_PORT = 8080
PROOT_CMD = "proot-distro login debian --"
BOT_TOKEN = "YOUR_BOT_TOKEN"
CHAT_ID = "YOUR_CHAT_ID"

# Estado global
last_response = "ApliBot listo."
current_state = "idle"
display_state = "idle"
state_lock = threading.Lock()

class BridgeHandler(BaseHTTPRequestHandler):
    def _send_json(self, data, status=200):
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(json.dumps(data, ensure_ascii=False).encode("utf-8"))

    def _read_body(self):
        length = int(self.headers.get("Content-Length", 0))
        return json.loads(self.rfile.read(length)) if length else {}

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()

    def do_GET(self):
        path = urlparse(self.path).path
        if path == "/api/status":
            self._send_json({
                "state": current_state,
                "agent_alive": True,
                "lastResponse": last_response,
                "server": "v1.5 Activo"
            })
        elif path == "/api/display_state":
            self._send_json({"state": display_state})
        elif path == "/api/config":
            self._send_json({"version": "1.5", "hasGroq": True})
        else:
            self._send_json({"error": "Not Found"}, 404)

    def do_POST(self):
        path = urlparse(self.path).path
        data = self._read_body()
        
        if path == "/api/chat":
            text = data.get("text", "")
            # Enviar a Telegram en hilo separado
            threading.Thread(target=self._notify_telegram, args=(f"👤 Usuario: {text}",)).start()
            
            # Respuesta rápida para evitar timeouts en Flutter
            self._send_json({"response": f"Procesando comando: {text}"})
        elif path == "/api/display_update":
            global display_state
            display_state = data.get("state", "idle")
            self._send_json({"status": "updated"})
        else:
            self._send_json({"error": "Method not allowed"}, 405)

    def _notify_telegram(self, msg):
        try:
            url = f"https://api.telegram.org/bot{BOT_TOKEN}/sendMessage"
            data = urllib.parse.urlencode({"chat_id": CHAT_ID, "text": msg}).encode("utf-8")
            urllib.request.urlopen(url, data=data, timeout=5)
        except: pass

def main():
    class ReuseServer(HTTPServer): allow_reuse_address = True
    server = ReuseServer(("0.0.0.0", LISTEN_PORT), BridgeHandler)
    print("--- Bridge Server Starting (v1.5) ---")
    print("🌉 Escuchando en el puerto 8080...")
    server.serve_forever()

if __name__ == "__main__":
    main()
