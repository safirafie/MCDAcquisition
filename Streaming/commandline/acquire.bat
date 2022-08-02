ssh root@rp-f07d64
cat /opt/redpitaya/fpga/fpga_streaming.bit > /dev/xdevcfg
/opt/redpitaya/sbin/mkoverlay.sh stream_app

streaming-server -c /root/.streaming_config

LD_LIBRARY_PATH=/opt/redpitaya/lib streaming-server -c /root/.streaming_config_cmd



