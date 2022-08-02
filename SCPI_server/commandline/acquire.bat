ssh root@192.168.1.106

cat /opt/redpitaya/fpga/fpga_0.94.bit > /dev/xdevcfg

acquire 16384 16 -t 2P -l 0.7 -o > /tmp/data3

pause



