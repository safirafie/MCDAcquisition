ssh root@rp-f07d64 "cat /opt/redpitaya/fpga/fpga_streaming.bit > /dev/xdevcfg && /opt/redpitaya/sbin/mkoverlay.sh stream_app && LD_LIBRARY_PATH=/opt/redpitaya/lib streaming-server -b /root/.streaming_config"


pause