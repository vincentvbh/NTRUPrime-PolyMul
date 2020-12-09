DEVICE=/dev/ttyUSB0

stty -F $DEVICE raw icanon eof \^d 115200
st-flash --reset write $1 0x8000000 >/dev/null 2>&1
sed '/#/q' < $DEVICE >/dev/null 2>&1 #dummy read to avoid incomplete outputs
st-flash reset >/dev/null 2>&1 
sed '/#/q' < $DEVICE
