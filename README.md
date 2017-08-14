# RocketMap startup script

This is my Multi city * multi instance * multi DB RocketMap startup script. I run 7 cities now with different hex sizes and workers count.

## HOW IT WORKS

This script takes all cities name store in citys.txt and create the separate configs for each one. 
Then split workers to seperate files for all instaces. U dont have to do it by hand.  
Then run all instance one by one. 

## RUN

To run this U need to have:

1) Clone RocketMap code one folder.

2) Edit config/config.ini <- same part of for config for all cities

3) Edit config for each city ex. config/city1Config.ini

4) Edit loc for each city ex. config/city1Loc.txt format: loc;step;workes_count;workerel30_count

5) Add all workers to one file to config/acc.csv and config/accl30.csv

6) Edit path in pokeMap.sh