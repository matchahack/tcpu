# 
stty -F /dev/ttyUSB1 115200 raw -echo min 0 time 10
printf '\x20\x20\x20\x20\x20\x20\x20\x20' > /dev/ttyUSB1
dd if=/dev/ttyUSB1 bs=1 count=256 status=none