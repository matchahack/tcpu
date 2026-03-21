# Testing tcpu on FPGA

We will use the `Tangnano9K` to emulate the `tcpu`

![t9k](./t9k-reg.jpg)

## Install FPGA toolchain in Linux

> Follow the [readme here](https://github.com/matchahack/think.like_a_chip/tree/main/0_GETTING_STARTED) to get the docker image for building bitstreams

```
docker run -it --privileged --device=/dev/ttyUSB0 --device=/dev/ttyUSB1 $(docker images -q bsides_tlac)
```

```
cd /home/$USER/tcpu/emulate/
docker cp ../tcpu $(docker ps -q --filter "ancestor=bsides_tlac"):/root/
docker cp Makefile $(docker ps -q --filter "ancestor=bsides_tlac"):/root/tcpu
docker cp tangnano9k.cst $(docker ps -q --filter "ancestor=bsides_tlac"):/root/tcpu
```

## Build and Load the `tcpu` onto the T9K

```
cd tcpu
make
```