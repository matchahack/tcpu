sudo apt update
sudo apt upgrade
sudo apt install -y iverilog python3-pip
sudo apt install -y autoconf help2man yosys
sudo apt-get install libpcap-dev
pip3 install -r requirements.txt
pip install scapy cocotb pyserial

if [ ! -d "verilator" ]; then
    git clone https://github.com/verilator/verilator   # Only first time
fi

unset VERILATOR_ROOT
cd verilator
git pull
git checkout stable

autoconf
./configure
make -j $(nproc)
sudo make install