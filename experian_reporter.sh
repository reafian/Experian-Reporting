#!/bin/bash

# Script to query Experian file differences.

# Ignore case
shopt -s nocaseglob

# Variables
if [[ $(uname -a | awk '{print $1}') == "Darwin" ]]
then
    source_path=$HOME/Desktop/support_files
else
    source_path=$HOME/scripts/experian/scripts/support_files
fi

source $source_path/variables.sh
source $source_path/functions.sh
source $source_path/experian_file_checks.sh
source $source_path/experian_data_checks.sh

# ********** START **********

# Check folders exist
check_folder_structure

while getopts "f:s:e:h" options
do              
    case "${options}" in
        f)
            date1=${OPTARG}
            check_date_format $date1
            date1=$(reformat_date $date1)
            ;;
        s)
            date2=${OPTARG}
            check_date_format $date2
            date2=$(reformat_date $date2)
            ;;
        e)
            email=${OPTARG}
            ;;
        h)
            usage
            ;;
        *)
            usage
            ;;
    esac
done

if [[ ! -z $email ]]
then
    echo "$(date "+%Y-%m-%d %H:%M:%S") - Sending report email to ${email} when finished."
fi

if [[ $date1 == "" && $date2 == "" ]]
then
    echo "$(date "+%Y-%m-%d %H:%M:%S") - No parameters passed - Using today and yesterday."
    date1=$today
    date2=$yesterday
fi

if [[ $date1 == "" || $date2 == "" ]]
then
    if [[ $date1 == "" ]]
    then
        first_date=$(add_day $date2)
        second_date=$date2
        echo "$(date "+%Y-%m-%d %H:%M:%S") - First date missing, using: $first_date"
    else
        first_date=$date1
        second_date=$(remove_day $date1)
        echo "$(date "+%Y-%m-%d %H:%M:%S") - Second date missing, using: $second_date"
    fi
else
    if [[ $date1 -eq $date2 ]]
    then
        echo "$(date "+%Y-%m-%d %H:%M:%S") - The second date can't be the same as the first date"
        remove_lock_file
        exit
    elif [[ $date2 -ge $date1 ]]
    then
        echo "$(date "+%Y-%m-%d %H:%M:%S") - The dates are the wrong way around but we can work with it"
        first_date=$date2
        second_date=$date1
    else
        first_date=$date1
        second_date=$date2
    fi
fi

echo "$(date "+%Y-%m-%d %H:%M:%S") - Using first date = $first_date, second date = $second_date"

nohup $source_path/called.sh $first_date $second_date $email &
