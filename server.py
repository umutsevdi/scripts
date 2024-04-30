#******************************************************************************
#
# * File: server.py
#
# * Author:  Umut Sevdi
# * Created: 05/01/24
# * Description: Simple echo server for tests
#*****************************************************************************
import argparse
from http.server import BaseHTTPRequestHandler, HTTPServer

class SimpleHTTPRequestHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        body = self.rfile.read(content_length)
        print("Received POST request with body:")
        print(body.decode('utf-8'))
        self.send_response(200)
        self.end_headers()

def run(port=8000, server_class=HTTPServer, handler_class=SimpleHTTPRequestHandler):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print(f"Echo server on port:{port}")
    httpd.serve_forever()


parser = argparse.ArgumentParser(description='A demo echo server')
parser.add_argument('-p', '--port', type=int, default=8000, help='Port number (default: 8000)')
args = parser.parse_args()

if __name__ == "__main__":
    run(args.port)
