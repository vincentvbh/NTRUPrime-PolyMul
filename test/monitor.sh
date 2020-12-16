DEVICE=""

for i in "$@"
do

case $i in
    -d=*|--device=*)
    DEVICE="${i#*=}"
    shift 
    ;;
    -b=*|--binary=*)
    BIN="${i#*=}"
    shift
    ;;
    *)    # unknown option
    echo """
    The binary file should be given
    Example:
    monitor.sh -b=my_binary.bin
    
    Optionally the device addres can be given as for example -d=/dev/ttyUSB0
    """
    exit
    shift 
    ;;
esac
done

NUMDEV=$(ls /dev/ttyUSB* | wc -l)
if [ $NUMDEV -gt 1 ] && [ "$DEVICE" = "" ];
then
  echo "You have more then one ttyUSB active please specify the correct one with -d option"
  exit
fi
  
DEVICE=${DEVICE:=$(ls /dev/ttyUSB*)}
stty -F $DEVICE raw icanon eof \^d 115200
st-flash --reset write $BIN 0x8000000 > flashing.log 2>&1
grep "jolly good" flashing.log > /dev/null

if [ $? -ne 0 ];
then
  echo "Please check flashing.log"
  exit
fi

sed '/#/q' < $DEVICE >/dev/null 2>&1 #dummy read to avoid incomplete outputs
st-flash reset >> /dev/null 2>&1 
sed '/#/q' < $DEVICE
