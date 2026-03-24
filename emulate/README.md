# Testing `tcpu` on FPGA

We will use the `Tangnano9K` to emulate the `tcpu`

![t9k](./t9k-reg.jpg)

## Install FPGA toolchain in Linux

> install `openFPGALoader`:
```
cd /home/$USER/tcpu/emulate/
chmod a+x *.sh
./install_ofpgal.sh
```

> [!IMPORTANT]
> Follow the [readme here](https://github.com/matchahack/think.like_a_chip/tree/main/0_GETTING_STARTED) to get the docker image for building bitstreams

## Build and load the `tcpu` onto the T9K

> run docker (terminal 0):
```
make docker_up
```

> build in docker, and flash bitstream to fpga (terminal 1):
```
make docker_build
make fpga_flash
```

## Read device cell/gate usage summary

> (terminal 1):
```
make read_gls
```

## Run program on emulator

> (terminal 1):
```
chmod a+x *.sh
python programmer.py -p /dev/ttyUSB2 -i "[0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20]"
```