#!/usr/bin/env python3
"""
Simple HTTP server with Cross-Origin Opener Policy (COOP) and Cross-Origin Embedder Policy (COEP)
headers required for Godot 4 WebGL / WASM builds.

Usage:
    python web/serve.py [port]
"""

import sys
import os
from http.server import HTTPServer, SimpleHTTPRequestHandler

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8000
DIRECTORY = os.path.dirname(os.path.abspath(__file__))

class GodotHTTPRequestHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def end_headers(self):
        # Crucial headers for WebAssembly / SharedArrayBuffer
        self.send_header('Cross-Origin-Opener-Policy', 'same-origin')
        self.send_header('Cross-Origin-Embedder-Policy', 'require-corp')
        self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
        super().end_headers()

if __name__ == '__main__':
    server_address = ('', PORT)
    httpd = HTTPServer(server_address, GodotHTTPRequestHandler)
    print(f"==================================================")
    print(f" Appsara Bali WebGL Server running at:")
    print(f" http://localhost:{PORT}")
    print(f" Serving files from: {DIRECTORY}")
    print(f" Press Ctrl+C to stop.")
    print(f"==================================================")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nServer stopped.")
