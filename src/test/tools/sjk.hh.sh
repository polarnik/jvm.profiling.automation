#!/bin/bash
N=30
app=Apache.JMeter
user=x1337
influx=http://localhost:8086/write?db=sjk
PID=`pgrep -f "^java.*-jar ApacheJMeter"`
if [ -n "$PID" ]
then
  sudo -u $user java -jar /opt/sjk/sjk.jar hh --pid $PID | \
    awk -v app=$app -v param=all -v maxN=$N -f /opt/sjk/sjk.hh.2.influx.awk | \
    curl  -i -XPOST $influx --data-binary @-
  sudo -u $user java -jar /opt/sjk/sjk.jar hh --pid $PID --live | \
    awk -v app=$app -v param=live -v maxN=$N -f /opt/sjk/sjk.hh.2.influx.awk | \
    curl  -i -XPOST $influx --data-binary @-
fi

