stty -F /dev/ttyUSB2 115200 raw -echo min 0 time 10
printf '\x20\x20\x20\x20\x20\x20\x20\x20' > /dev/ttyUSB2
dd if=/dev/ttyUSB2 bs=1 count=256 status=none