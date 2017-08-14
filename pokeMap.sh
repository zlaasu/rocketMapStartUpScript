#!/bin/bash

### DEFAULTS
dir_alarm="/home/zlasu/pokeAlarm/"
dir_rm="/home/zlasu/rocketMap/"
dir_config="/home/zlasu/config/"
dir_config_run="/home/zlasu/config_run/"
acc="/home/zlasu/config/acc.csv"
accl30="/home/zlasu/config/accl30.csv"

###CHECK IF ACC AND ACCL30 IS ENOUGH
echo "Check accounts number for all cities..."
account_needed=0
account_neededl30=0
c=0

while read city; do
  while read line; do

    IFS=';' read -r -a array <<< "$line"
    account_needed=$(($account_needed + ${array[2]}))
    account_neededl30=$(($account_neededl30 + ${array[3]}))

    let c++

  done <$dir_config$city"Loc.txt"
done <$dir_config"citys.txt"

acc_in_file=$(wc -l < $acc)
acc_in_filel30=$(wc -l < $accl30)

echo 'zoneCount='$c
#echo 'acc='$account_needed
#echo 'acc.csv='$acc_in_file

if [ "$account_needed" -gt "$acc_in_file" ]; then
  echo "Not enough accounts!!! ...is "$acc_in_file", need "$account_needed"."
  exit 1
fi
echo "Accounts are enough!!! ...is "$acc_in_file", need "$account_needed"."

if [ "$account_neededl30" -gt "$acc_in_filel30" ]; then
  echo "Not enough accountslvl.30!! ...is "$acc_in_filel30", need "$account_neededl30"."
  exit 1
fi
echo "Accounts are enough l30!!! ...is "$acc_in_filel30", need "$account_neededl30"."


###REMOVE OLD RUN CONFIG
echo "Remove config_run folder..."
rm -rf $dir_config_run
mkdir -p $dir_config_run

###GEN CITIES CONFIGS
echo "Create config_run for all cities..."
while read city; do
  cat $dir_config"config.ini" $dir_config$city"Config.ini" > $dir_config_run$city".ini"
done <$dir_config"citys.txt"

###SPLIT ACC
echo "Split acc.csv..."
start=1
startl30=1
num=0
while read city; do
  while read line; do

    IFS=';' read -r -a array <<< "$line"
    stop=$(($start + ${array[2]} - 1))
    sed -n "${start},${stop}p" < $acc > $dir_config_run"xxx"$num".csv"
    start=$(($stop + 1))
    if [ "${array[3]}" -gt "0" ]; then
      stopl30=$(($startl30 + ${array[3]} - 1))
      sed -n "${startl30},${stopl30}p" < $accl30 > $dir_config_run"yyy"$num".csv" 
      startl30=$(($stopl30 + 1))
    fi
    let num++

  done <$dir_config$city"Loc.txt"
done <$dir_config"citys.txt"

###KILL ALL
echo "KILL ALL"
killall screen

###START ALARMS AND MOBILE APP PUSH SERVICE
echo "start - pokeNotify" 
cd pokeNotify
screen -S "pokeNotifyWaw" -dm java -jar pokenotify-0.1.0-SNAPSHOT.jar --pokenotify.fcmToken=xxxxxxxxxxxxxx
cd ..

echo "start - Alert"

cmd='screen -S "alarmWawEndGame" -dm python '$dir_alarm'start_pokealarm.py -P 4000 -a '$dir_alarm'alarmsWawEndGame.json -f '$dir_alarm'filtersWawEndGame.json'
echo $cmd
eval $cmd

cmd='screen -S "alarmWawRare" -dm python '$dir_alarm'start_pokealarm.py -P 4001 -a '$dir_alarm'alarmsWawRare.json -f '$dir_alarm'filtersWawRare.json'
echo $cmd

eval $cmd

###START MPAS
i=0
while read city; do
  p=0
  while read loc; do

    echo $city"_"$p"/"$i"/"$c " - " $loc 
    #printf -v w "%03d" $i
    IFS=';' read -r -a array <<< "$loc"
    #echo "${array[0]}"
    p1='screen -S '$city$p' -dm python '$dir_rm'runserver.py -sn '$city'H'$p' -l "'${array[0]}'" -ac config_run/xxx'$i'.csv -cf config_run/'$city'.ini -st '${array[1]}

    if [ -e 'config_run/yyy'$i'.csv' ]
    then
      p2=' -hlvl config_run/yyy'$i'.csv'
    else
      p2=' '
    fi

    cmd=$p1$p2
    echo $cmd
    eval $cmd
    let i++
    let p++
    sleep 15

  done <$dir_config$city"Loc.txt"
done <$dir_config"citys.txt"

screen -list
