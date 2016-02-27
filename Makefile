INCLUDE = network,logic,message,utils,state
PKG = async,yojson

all:
	corebuild -pkg $(PKG) main.native -Is $(INCLUDE)

install:
	scp main.native ubuntu@54.194.72.28:

clean:
	corebuild -clean
