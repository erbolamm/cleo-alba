import http.server
import http.client
import os

# Configuración
OLLAMA_HOST = "127.0.0.1"
OLLAMA_PORT = 11434
PROXY_PORT = 11435
PASSWORD_FILE = os.path.expanduser("~/last_password.txt")

def get_allowed_password():
    if os.path.exists(PASSWORD_FILE):
        with open(PASSWORD_FILE, "r") as f:
            return f.read().strip()
    return "clawmobil" # Password por defecto

class AuthProxyHandler(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        # Verificar contraseña en el header
        client_pass = self.headers.get("X-Claw-Key")
        allowed_pass = get_allowed_password()

        if client_pass != allowed_pass:
            self.send_response(401)
            self.end_headers()
            self.wfile.write(b'{"error": "Unauthorized: Invalid X-Claw-Key"}')
            return

        # Redirigir a Ollama
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length)

        conn = http.client.HTTPConnection(OLLAMA_HOST, OLLAMA_PORT)
        headers = {k: v for k, v in self.headers.items() if k.lower() != 'host'}
        
        try:
            conn.request("POST", self.path, body, headers)
            res = conn.getresponse()
            
            self.send_response(res.status)
            for k, v in res.getheaders():
                self.send_header(k, v)
            self.end_headers()
            self.wfile.write(res.read())
        except Exception as e:
            self.send_response(500)
            self.end_headers()
            self.wfile.write(str(e).encode())
        finally:
            conn.close()

    def do_GET(self):
        # Ollama tags etc
        conn = http.client.HTTPConnection(OLLAMA_HOST, OLLAMA_PORT)
        try:
            conn.request("GET", self.path, headers=self.headers)
            res = conn.getresponse()
            self.send_response(res.status)
            for k, v in res.getheaders():
                self.send_header(k, v)
            self.end_headers()
            self.wfile.write(res.read())
        except Exception as e:
            self.send_response(500)
            self.end_headers()
            self.wfile.write(str(e).encode())
        finally:
            conn.close()

if __name__ == "__main__":
    print(f"🛡️ Auth Proxy escuchando en puerto {PROXY_PORT}")
    print(f"   Redirigiendo a Ollama en {OLLAMA_HOST}:{OLLAMA_PORT}")
    http.server.HTTPServer(('', PROXY_PORT), AuthProxyHandler).serve_forever()
