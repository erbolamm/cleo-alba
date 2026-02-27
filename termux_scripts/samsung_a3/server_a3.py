#!/usr/bin/env python3
"""
ClawMobil - Servidor Samsung A3
Python 3.8 stdlib only. Sin dependencias externas.
Chat directo via Groq API (llama-3.1-8b-instant).
"""
import json, threading, os, sys
import urllib.request, urllib.parse, urllib.error
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse

# --- CONFIGURACIÓN ---
LISTEN_PORT   = 8080
GROQ_API_KEY  = os.getenv("GROQ_API_KEY", "")  # Configura en claves.env
GROQ_MODEL    = "llama-3.1-8b-instant"
GROQ_URL      = "https://api.groq.com/openai/v1/chat/completions"
SYSTEM_PROMPT = (
    "Eres ApliBot, un asistente inteligente que corre en un Samsung Galaxy A3 2015. "
    "Eres directo, útil y sabes que tienes recursos limitados. "
    "Responde siempre en español, de forma concisa."
)

# Historial de conversación en memoria
history = []
history_lock = threading.Lock()
_server = None  # Referencia global al servidor HTTP

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

# Tipos MIME básicos
MIME = {
    ".html": "text/html; charset=utf-8",
    ".css":  "text/css",
    ".js":   "application/javascript",
    ".png":  "image/png",
    ".ico":  "image/x-icon",
    ".json": "application/json",
}


def groq_chat(user_text: str) -> str:
    """Llama a la API de Groq y devuelve la respuesta."""
    with history_lock:
        history.append({"role": "user", "content": user_text})
        messages = [{"role": "system", "content": SYSTEM_PROMPT}] + history[-20:]

    payload = json.dumps({
        "model": GROQ_MODEL,
        "messages": messages,
        "max_tokens": 512,
        "temperature": 0.7,
    }).encode("utf-8")

    req = urllib.request.Request(
        GROQ_URL,
        data=payload,
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {GROQ_API_KEY}",
        },
        method="POST",
    )

    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            data = json.loads(resp.read())
            reply = data["choices"][0]["message"]["content"].strip()
    except urllib.error.HTTPError as e:
        reply = f"[Error Groq {e.code}]: {e.read().decode()[:200]}"
    except Exception as e:
        reply = f"[Error de red]: {e}"

    with history_lock:
        history.append({"role": "assistant", "content": reply})

    return reply


class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        # Silenciar logs del servidor salvo errores
        pass

    def _send(self, body: bytes, status=200, ctype="application/json"):
        self.send_response(status)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(body)

    def _json(self, data, status=200):
        self._send(json.dumps(data, ensure_ascii=False).encode(), status)

    def _body(self):
        n = int(self.headers.get("Content-Length", 0))
        return json.loads(self.rfile.read(n)) if n else {}

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()

    def do_GET(self):
        path = urlparse(self.path).path

        if path == "/" or path == "":
            path = "/chat.html"

        if path == "/api/status":
            self._json({"status": "ok", "model": GROQ_MODEL, "messages": len(history)})
            return

        if path == "/api/history":
            with history_lock:
                self._json(history)
            return

        # Servir archivos estáticos
        file_path = os.path.join(SCRIPT_DIR, path.lstrip("/"))
        if os.path.isfile(file_path):
            ext  = os.path.splitext(file_path)[1]
            mime = MIME.get(ext, "application/octet-stream")
            with open(file_path, "rb") as f:
                self._send(f.read(), ctype=mime)
        else:
            self._json({"error": "Not Found"}, 404)

    def do_POST(self):
        path = urlparse(self.path).path

        if path == "/api/chat":
            data  = self._body()
            text  = data.get("text", "").strip()
            if not text:
                self._json({"error": "Texto vacío"}, 400)
                return
            reply = groq_chat(text)
            self._json({"response": reply})

        elif path == "/api/clear":
            with history_lock:
                history.clear()
            self._json({"status": "cleared"})

        elif path == "/api/shutdown":
            self._json({"status": "shutting_down"})
            # Apagar el servidor en un hilo separado para poder responder primero
            if _server:
                threading.Timer(0.5, _server.shutdown).start()

        else:
            self._json({"error": "Not Found"}, 404)


if __name__ == "__main__":
    class ReuseServer(HTTPServer):
        allow_reuse_address = True

    _server = ReuseServer(("0.0.0.0", LISTEN_PORT), Handler)
    ip = os.popen("ip addr show wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d/ -f1").read().strip()
    print(f"✅ ClawMobil A3 corriendo en puerto {LISTEN_PORT}")
    print(f"   Local:  http://localhost:{LISTEN_PORT}")
    if ip:
        print(f"   WiFi:   http://{ip}:{LISTEN_PORT}")
    print(f"   Modelo: {GROQ_MODEL}")
    print("   Ctrl+C para detener\n")
    try:
        _server.serve_forever()
    except KeyboardInterrupt:
        print("\nServidor detenido.")
