# Testing tcpu on FPGA

We will use the `Tangnano9K` to emulate the `tcpu`

![t9k](./t9k-reg.jpg)

## Install FPGA toolchain in Linux

```
chmod a+x *.sh
./installs_linux.sh
```

## Build and Load the `tcpu` onto the T9K

```
cd tcpu
make
```