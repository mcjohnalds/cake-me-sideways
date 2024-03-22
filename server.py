#!/usr/bin/env python3
# Python 3 script to run the exported Godot HTML5 game. Run with ./server.py
# and open http://localhost:8000
from http import server

class MyHTTPRequestHandler(server.SimpleHTTPRequestHandler):
        def __init__(self, *args, **kwargs):
                super().__init__(*args, directory='./build', **kwargs)

        def end_headers(self):
                self.send_my_headers()
                server.SimpleHTTPRequestHandler.end_headers(self)

        def send_my_headers(self):
                self.send_header("Access-Control-Allow-Origin", "*")
                self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
                self.send_header("Cross-Origin-Opener-Policy", "same-origin")

if __name__ == '__main__':
        server.test(HandlerClass=MyHTTPRequestHandler)
