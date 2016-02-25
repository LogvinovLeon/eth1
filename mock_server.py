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
    timeout = 0.001

    def handle(self):
        while True:
            data = [
                {"type": "hello"},
                {"type": "error", "error": "dupa"},
                {"type": "fill", "symbol": "GS", "dir": "BUY", "size": "1", "order_id": "1"}
            ]
            data = "".join([json.dumps(d) + "\n" for d in data])
            print data
            self.wfile.write(data)
            try:
                print "{} wrote: {}".format(self.client_address[0], self.rfile.readline())
            except:
                pass
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
