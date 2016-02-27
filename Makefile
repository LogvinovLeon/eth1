INCLUDE = network,logic,message,utils,state
PKG = async,yojson,sexplib,pa_sexp_conv

all:
	corebuild -pkg $(PKG) -syntax camlp4o main.native -Is $(INCLUDE)

install:
	scp main.native ubuntu@54.194.72.28:

clean:
	corebuild -clean
