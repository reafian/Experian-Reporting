#! /bin/bash

#
# Variables file.
#
# Here we define all system variables we need for the script

# System independent Variables
experian_file_check_status=0
experian_data_check_status=0
percent_to_worry_about=20

# System Dependent Variables

if [[ $(uname -a | awk '{print $1}') == "Darwin" ]]
then
    #
    # Local variables for testing
    #
    today=$(date +%Y%m%d)
    yesterday=$(date -v-1d +%Y%m%d)
    day_before_yesterday=$(date -v-2d +%Y%m%d)

    archive=~/Desktop/archive
    reports=~/Desktop/reports
    scripts=~/Desktop
    working=$scripts/.working
    support_files=$scripts/support_files
    lock_file=$working/experian.lock

    # SQL
    sqlbin=$(which sqlite3)
    sqldb=$working/Experian.db

    # Reports
    experian_report_file=$working/report.tmp
    experian_record_counts_csv=$working/record_count_report.csv
    experian_file_report_csv=$working/file_report.csv
    experian_attr_report_csv=$working/attr_report.csv
    experian_attr_data_report_csv=$working/attr_data_report.csv
    experian_error_file=$working/error.tmp

    #email
    reply_to=
else
    #
    # Actual proper production values
    #
    today=$(date +%Y%m%d)
    yesterday=$(date -d "1 day ago" +%Y%m%d)
    day_before_yesterday=$(date -d "2 day ago" +%Y%m%d)
  
    archive=/ulshome/etluser-adm/archive
    reports=/home/n7796420/scripts/experian/scripts/reports
    scripts=/home/n7796420/scripts/experian/scripts
    working=$scripts/.working
    support_files=$scripts/support_files
    lock_file=$working/experian.lock

    # SQL
    sqlbin=~/bin/sqlite3
    sqldb=$working/Experian.db

    # Reports
    experian_report_file=$working/report.tmp
    experian_record_counts_csv=$working/record_count_report.csv
    experian_file_report_csv=$working/file_report.csv
    experian_attr_report_csv=$working/attr_report.csv
    experian_attr_data_report_csv=$working/attr_data_report.csv
    experian_error_file=$working/error.tmp

    #email
    reply_to=
fi
