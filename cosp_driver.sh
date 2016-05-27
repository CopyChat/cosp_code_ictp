#!/bin/bash - 
#===============================================================================
#
#          FILE: cosp_driver.sh
# 
USAGE="./cosp_driver.sh [ -t ] "
# 
#   DESCRIPTION:  to drive cosp_test
# 
#       OPTIONS: --- t for test
#  REQUIREMENTS: --- cosp_cmor_nl.temp.txt, cosp_input_nl.temp.txt, cosp_output_nl.txt
#                    awk, cdo
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Tang (Tang), chao.tang.1@gmail.com
#  ORGANIZATION: le2p
#       CREATED: 05/27/2016 10:33:51 AM CEST
#      REVISION:  ---
#===============================================================================

#set -o nounset                             # Treat unset variables as an error
shopt -s extglob 							# "shopt -u extglob" to turn it off
#=================================================== 
while getopts ":t" opt; do
    case $opt in
        t) TEST=1 ;;
        \?) echo $USAGE && exit 1
    esac
done
shift $(($OPTIND - 1))
#=================================================== 

startday="2011-01-01"  # default start day in cosp_cmor_nl.txt
infile_prefix="COSP_SUBEX"  # input file, e.g. COSP_SUBEX_2011-01-98.nc


for j in 2011 # Year
do
    for i in  01 07  # month, if you add other months, please take care of the limits of timestep, in next loop.
    do
        for ((timestep = 0; timestep < 124 ; timestep++))  
        do
            # Josefina's formula to convert timesteps to day
            day=$(echo $timestep | awk '{print (($1)-($1)%4)/4 +1}' | awk '{if( $1 < 10)print 0$1;else print $1}')
            echo ================== day = $day

            # make a directory for each timestep
            mkdir -p cloud_"$j"-"$i"-"$timestep"
            #FINPUT='COSP_1.nc'
#=================================================== change namelist file

            #NOTE: if you want simulator to output the same named file, comment/delete this line, maybe convinient for post-processing
            startday=$(echo "'$j'-'$i'-'$day'")

            # change the starttime and output dir; 
            cat ./cosp_cmor_nl.temp.txt | awk '{\
                gsub(/output90908/,"cloud_'$j'-'$i'-'$timestep'");\
                gsub(/date90908/,"'$startday'");\  
                print}' > \
                ./cosp_cmor_nl.txt

            # change the input data
            cat ./cosp_input_nl.temp.txt | awk '{\
                gsub(/input90908/,"'$infile_prefix'_'$j'-'$i'-'$timestep'.nc");\
                print}' > \
                ./cosp_input_nl.txt
#=================================================== end of change namelist file

            # call the exe of simulator
            ./cosp_test > cosp.logout

        done
    done
done


