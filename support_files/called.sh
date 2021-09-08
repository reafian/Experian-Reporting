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

# Check for lock file
lock_status=$(check_for_lock)

if [ $lock_status == '1' ]
then
    echo "$(date "+%Y-%m-%d %H:%M:%S") - Lock file found ($lock_file), exiting"
    exit 1
fi

create_lock_file

first_date=$1
second_date=$2
email=$3

echo "$(date "+%Y-%m-%d %H:%M:%S") - Using first date = $first_date, second date = $second_date"

experian_file_checks $first_date $second_date
experian_data_checks $first_date $second_date

tidy_up $email

remove_lock_file
