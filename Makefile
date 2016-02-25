INCLUDE = network,logic,message,utils,state
PKG = async,yojson

all:
	corebuild -pkg $(PKG) main.native -Is $(INCLUDE)

install:
	echo "TODO: scp to amazon server"

clean:
	corebuild -clean
