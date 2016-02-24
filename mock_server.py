#!/usr/bin/python
import json
import argparse
import SocketServer
import socket
from time import sleep


class MyTCPServer(SocketServer.TCPServer):
    def server_bind(self):
        self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.socket.bind(self.server_address)


class MyTCPHandler(SocketServer.StreamRequestHandler):
    def handle(self):
        while True:
            data1 = {"type" : "hello"}
            data2 = {"type" : "error", "error": "dupa"}
            data = json.dumps(data1) + "\n" + json.dumps(data2) + "\n"
            self.wfile.write(data)
            print "{} wrote: {}".format(self.client_address[0], self.rfile.readline())
            sleep(1)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Starts dummy TCP server accepting connections '
                                                 'and writing multiline data.',
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('--host', default="localhost", type=str)
    parser.add_argument('--port', default=25000, type=int)
    args = parser.parse_args()
    server = MyTCPServer((args.host, args.port), MyTCPHandler)
    server.serve_forever()
