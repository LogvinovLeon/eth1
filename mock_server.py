import SocketServer
from time import sleep


class MyTCPHandler(SocketServer.StreamRequestHandler):
    def handle(self):
        while True:
            self.wfile.write("Hello\nMulti line\n")
            sleep(1)


if __name__ == "__main__":
    HOST, PORT = "localhost", 80
    server = SocketServer.TCPServer((HOST, PORT), MyTCPHandler)
    server.serve_forever()

