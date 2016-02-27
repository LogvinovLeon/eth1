INCLUDE = network,logic,message,utils,state
PKG = async,yojson
ifeq ($(shell hostname),amharc-asus)
ADDITIONAL=-package sexplib,pa_sexp_conv -syntax camlp4o
else ifeq ($(shell hostname),bot-team)
ADDITIONAL=-package sexplib,pa_sexp_conv -syntax camlp4o
else
ADDITIONAl=
endif

all:
	corebuild -pkg $(PKG) $(ADDITIONAL) main.native -Is $(INCLUDE)

install:
	scp main.native ubuntu@54.194.72.28:

clean:
	corebuild -clean
