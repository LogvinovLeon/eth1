all:
	corebuild -pkg async,yojson main.native -I network -I logic -I message

install:
	echo "TODO: scp to amazon server"

clean:
	rm -rf _build
	rm main.native
