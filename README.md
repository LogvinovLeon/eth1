# Eth1 trading program

## How to run

* Install opam (package manager) with it's dependencies

    `apt-get install -y software-properties-common git unzip aspcud mercurial m4`
    
    `wget https://raw.github.com/ocaml/opam/master/shell/opam_installer.sh -O - | sh -s /usr/local/bin`
    
    `opam init`
    
    `eval $(opam config env)`

* Clone this repo

    `git clone https://github.com/LogvinovLeon/eth1`

* Install dependencies

    `opam install core async -j 4`

* Make

    `make`

* Install on amazon EC2 instance

    `make intall`

## TODO

* Add more data & metrics to State
* Install on amazon EC2
* Adapt message & action types to real data specification
* Implement two moving average crossover strategy
* Implement pair trading strategy
