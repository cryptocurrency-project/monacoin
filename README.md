## Monacoin Formula
[monacoinproject/monacoin](https://github.com/monacoinproject/monacoin)

## Monacoin API
Bitcoinと同様

## Monacoin Explorer
[mona-coin](https://chaintools.mona-coin.de/)
[prohashing.com Monacoin](https://prohashing.com/explorer/Monacoin/)

## Build method
docker build --build-arg MONACOIN_VERSION=0.17.1 --build-arg GOSU_VERSION=1.11 -t mona-core:v0.17.1 -f Dockerfile .
