#!/bin/bash - 
#===============================================================================
#
#          FILE: cosp_driver.sh
# 
USAGE="./cosp_driver.sh [ -t ] + infile "
# 
#   DESCRIPTION:  to drive cosp_test
# 
#       OPTIONS: --- t for test
#  REQUIREMENTS: --- cosp_cmor_nl.txt, cosp_input_nl.txt,cosp_output_nl.txt
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


for j in 2011 # Year
do
    for i in  01  # month
    do
        for ((timestep = 0; timestep < 124 ; timestep++))
        do
            day=$(echo $timestep | awk '{print (($1)-($1)%4)/4 +1}' | awk '{if( $1 < 10)print 0$1;else print $1}')
            echo ================== day = $day
            mkdir -p cloud_"$j"-"$i"-"$timestep"
            #FINPUT='COSP_1.nc'
#=================================================== change namelist file
            # change the starttime
            cat ./cosp_cmor_nl.temp.txt | awk '{\
                gsub(/date90908/,"'$j'-'$i'-'$day'");\
                gsub(/output90908/,"cloud_'$j'-'$i'-'$timestep'");\
                print}' > \
                ./cosp_cmor_nl.txt

            # change the input data
            cat ./cosp_input_nl.temp.txt | awk '{\
                gsub(/input90908/,"COSP_SUBEX_'$j'-'$i'-'$timestep'.nc");\
                print}' > \
                ./cosp_input_nl.txt
#=================================================== end of change namelist file
            ./cosp_test > cosp.logout

        done
    done
done



