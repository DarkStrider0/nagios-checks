# evaluate cpu usage in prosent from Linux based systems

# get arguments

while getopts 'w:c:hp' OPT; do
  case $OPT in
    w)  int_warn=$OPTARG;;
    c)  int_crit=$OPTARG;;
    h)  hlp="yes";;
    p)  perform="yes";;
    *)  unknown="yes";;
  esac
done

# usage
HELP="
    usage: $0 [ -w value -c value -p -h ]

    syntax:

            -w --> Warning integer value
            -c --> Critical integer value
            -p --> print out performance data
            -h --> print this help screen
"

if [ "$hlp" = "yes" -o $# -lt 1 ]; then
  echo "$HELP"
  exit 0
fi

# get cpu prosent
prosent=`cat /proc/loadavg | cut -c 1-4 | echo "scale=2; ($(</dev/stdin)/\`nproc\`)*100" | bc -l | cut -d"." -f1`

#echo "her kommer det "$prosentCpuLoud " ------------"
#exit

# output with or without performance data
if [ "$perform" = "yes" ]; then
  OUTPUTP="Cpu prosent: $prosent % | CpuLoad="$prosent" ;$int_warn;$int_crit;0"
else
  OUTPUT="Cpu: "$prosent" %"
fi

if [ -n "$int_warn" -a -n "$int_crit" ]; then

  err=0
#echo $prosent " output---- " $OUTPUT
  if (( $prosent >= $int_crit )); then
    err=2
  elif (( $prosent >= $int_warn )); then
    err=1
  fi
#echo " ----------------------"$int_crit"----err "$err
  if (( $err == 0 )); then

    if [ "$perform" = "yes" ]; then
      echo -n "OK - $OUTPUTP"
      exit "$err"
    else
      echo -n "OK - $OUTPUT"
      exit "$err"
    fi

  elif (( $err == 1 )); then
    if [ "$perform" = "yes" ]; then
      echo -n "WARNING - $OUTPUTP"
      exit "$err"
    else
      echo -n "WARNING - $OUTPUT"
      exit "$err"
    fi

  elif (( $err == 2 )); then

    if [ "$perform" = "yes" ]; then
      echo -n "CRITICAL - $OUTPUTP"
      exit "$err"
    else
      echo -n "CRITICAL - $OUTPUT"
      exit "$err"
    fi

  fi

else

  echo -n "no output from plugin"
  exit 3

fi
exit

