#!/bin/sh
#
# Name: make_pgstatspack_daily_report.sh
#
# Author: Aleksey Tsalolikhin
#
# Date: 19 Mar 2013
#
# Description: run "pgstatspack" report for most recent snapshot interval


TODAYS_DATE=`perl -e '
                               @T=localtime(time);
                               printf("%02d-%02d-%02d", $T[5]+1900, $T[4]+1, $T[3]);
                         '
                `
TIME_NOW=`date +%H:%M:%S`

MOST_RECENT_SNAPSHOT_ID=`psql -t --user postgres --dbname __YOUR_DB_NAME__ --quiet --command "select snapid from pgstatspack_snap where (ts > '$TODAYS_DATE 00:00:00' and ts < '$TODAYS_DATE
 ${TIME_NOW}') order by snapid desc limit 1" | xargs echo`

END_SNAP=$MOST_RECENT_SNAPSHOT_ID
START_SNAP=`expr $END_SNAP - 1`

OUTFILE=/tmp/pgstatspack-report-${TODAYS_DATE}.${TIME_NOW}.txt

(echo $START_SNAP; echo $END_SNAP) | \
     /home/postgres/pgstatspack/bin/pgstatspack_report.sh  \
         -u postgres  \
         -d ddcKeyGen \
         -f $OUTFILE \
         >/dev/null

if [ $? -ne 0 ]
then
    echo 'pgstatspack_report.sh daily report exited with error, aborting'
    exit 1
fi

if [ ! -f $OUTFILE ]
then
    echo "$OUTFILE does not exist, aborting."
    exit 1
fi


if [ ! -s $OUTFILE ]
then
    echo "$OUTFILE is empty, aborting."
    exit 1
fi

less $OUTFILE

rm $OUTFILE

exit 0
