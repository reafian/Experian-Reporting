#! /bin/bash

#
# Experian File Checks
#
# Functions to support the checking of the Experian database go here

function get_record_count {
	if [ -f ${archive}/Audience_DLAR_${1}*_1.csv ]
	then
		echo $(awk 'END {print NR}' ${archive}/Audience_DLAR_${1}*)
	else
		echo 0
	fi
}

function get_file_record_counts {
	record_count_first_date=$(get_record_count $first_date)
	echo "$(date "+%Y-%m-%d %H:%M:%S") - $record_count_first_date records in the files from ${first_date_formatted}"
	record_count_second_date=$(get_record_count $second_date)
	echo "$(date "+%Y-%m-%d %H:%M:%S") - $record_count_second_date records in the files from ${second_date_formatted}"
	percentage_change=$(check_percentage_change_in_files $record_count_first_date $record_count_second_date)
	percentage_change_whole_number=$(echo $percentage_change | cut -d. -f1 | tr -d '-')
	#
	# If we need to worry the experian_file_check_status flag wil be set here
	#
	worried=$(do_we_need_to_worry $percentage_change_whole_number)
#	if [[ $worried == 1 ]]
#	then
		echo "Record Count $first_date_formatted	Record Count $second_date_formatted" >> $experian_report_file
		echo "===============================================" >> $experian_report_file
		echo "$record_count_first_date			$record_count_second_date" >> $experian_report_file
		echo "" >> $experian_report_file
		echo "Percentage change = $percentage_change" >> $experian_report_file
		echo "Record Count","$first_date_formatted","$record_count_first_date","$second_date_formatted","$record_count_second_date","$percentage_change" >> $experian_file_report_csv
#	fi
}

function count_files {
	if [ -f $archive/Audience_DLAR_${1}*_1.csv ]
	then
		count=$(ls $archive/Audience_DLAR_${1}* | wc -l | awk '{print $1}')
		echo $count
	else
		echo 0
	fi
}

function get_number_of_files_counts {
	file_count_first_date=$(count_files $first_date)
	echo "$(date "+%Y-%m-%d %H:%M:%S") - $file_count_first_date files delivered on $first_date_formatted"
	file_count_second_date=$(count_files $second_date)
	echo "$(date "+%Y-%m-%d %H:%M:%S") - $file_count_second_date files delivered on $second_date_formatted"
	percentage_change=$(check_percentage_change_in_files $file_count_first_date $file_count_second_date)
	percentage_change_whole_number=$(echo $percentage_change | cut -d. -f1 | tr -d '-')
	
	#
	# If we need to worry the experian_file_check_status flag wil be set here
	#
	worried=$(do_we_need_to_worry $percentage_change_whole_number)
#	if [[ $worried == 1 ]]
#	then
		echo "File Count $first_date_formatted	File Count $second_date_formatted" >> $experian_report_file
		echo "=============================================" >> $experian_report_file
		echo "$file_count_first_date			$file_count_second_date" >> $experian_report_file
		echo "" >> $experian_report_file
		echo "Percentage change = $percentage_change" >> $experian_report_file
		echo "File Count","$first_date_formatted","$file_count_first_date","$second_date_formatted","$file_count_second_date","$percentage_change" >> $experian_file_report_csv
#	fi

}

function experian_file_checks {
	first_date=$1
	second_date=$2
	first_date_formatted=$(unfix_date $1)
	second_date_formatted=$(unfix_date $2)
	echo "$(date "+%Y-%m-%d %H:%M:%S") - Check Audience files for consistency"
	# Experian will do pretty much all the data checks. We're just checking to see if we have
	# a sensible number of files delivered, or not.
	echo "Counted Value","First Date","First Count","Second Date","Second Count","Percentage Change" > $experian_file_report_csv
	get_file_record_counts $first_date $second_date
	get_number_of_files_counts $first_date $second_date
	echo "$(date "+%Y-%m-%d %H:%M:%S") - Audience file consistency check finished"
}
