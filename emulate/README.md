# Testing tcpu on FPGA

We will use the `Tangnano9K` to emulate the `tcpu`

![t9k](./t9k-reg.jpg)

## Install FPGA toolchain in Linux

> install openfpgaloader
```
./install_ofpgal.sh
```

> [!IMPORTANT]
> Follow the [readme here](https://github.com/matchahack/think.like_a_chip/tree/main/0_GETTING_STARTED) to get the docker image for building bitstreams


> terminal 0:
```
docker run -it --privileged --device=/dev/ttyUSB0 --device=/dev/ttyUSB1 --device=/dev/ttyUSB2 $(docker images -q bsides_tlac)
```

> terminal 1:
```
cd /home/$USER/tcpu/emulate/
docker cp ../tcpu $(docker ps -q --filter "ancestor=bsides_tlac"):/root/
docker cp Makefile $(docker ps -q --filter "ancestor=bsides_tlac"):/root/tcpu
docker cp tangnano9k.cst $(docker ps -q --filter "ancestor=bsides_tlac"):/root/tcpu
```

## Build and Load the `tcpu` onto the T9K

> build in docker (terminal 0)
```
cd tcpu
make
```

> load in host, and flash fpga (terminal 1)
```
docker cp $(docker ps -q --filter "ancestor=bsides_tlac"):/root/tcpu/control.fs .
openFPGALoader -b tangnano9k -f control.fs
```