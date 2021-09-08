#! /bin/bash

#
# Odds and ends go here
#

#
# Lock Files
#

function check_for_lock {
  if [[ -e $lock_file ]]
  then
    echo 1
  else
    echo 0
  fi
}

function create_lock_file {
  if [[ ! -e $lock_file ]]
  then
    touch $lock_file
  fi
}

function remove_lock_file {
  rm -f $lock_file
}

#
# Folders
#

function check_if_exists {
        if [[ ! -d $1 ]]
        then
                mkdir -p $1
        fi
}

function check_folder_structure {
        for i in $working $archive $reports
        do
                check_if_exists $i
        done
}

# getopts
function usage {
	echo "Usage: $0 [ -f DATE1 ] [ -s DATE2] " 1>&2
	echo ""
	echo "Date format must be YYYY-MM-DD"
	echo ""
	remove_lock_file
	exit

}

function check_date_format {
	if [[ ! $1 =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]
	then
		echo "Invalid date format"
		remove_lock_file
		exit 1
	fi
}

function reformat_date {
	echo $1 | tr -d '-'
}

function add_day {
	if [[ $(uname -a | awk '{print $1}') == "Darwin" ]]
	then
		echo $(date -j -v +1d -f "%Y%m%d" "$1" +%Y%m%d)
	else
		echo $(date -d "$1 - 1 days" +%Y%m%d)
	fi
}

function remove_day {
	if [[ $(uname -a | awk '{print $1}') == "Darwin" ]]
	then
		echo $(date -j -v -1d -f "%Y%m%d" "$1" +%Y%m%d)
	else
		echo $(date -d "$1 - 1 days" +%Y%m%d)
	fi
}

function manage_dates {
	date1=$(reformat_date $1)
	date2=$(reformat_date $2)

	echo date1 = $date1, date2 = $date2
}

function unfix_date {
	echo $(echo "$1" | sed 's/^\(.\{4\}\)/\1-/' | sed 's/^\(.\{7\}\)/\1-/')
}

# Check the percentage change in the delivered files

function check_percentage_change_in_files {
        # $1 = today
        # $2 = yesterday
        if [[ $1 == 0 || $1 == "" ]]
        then
                echo "-100"
        elif [[ $2 == 0 || $2 == "" ]]
        then
                echo "+100"
        elif [[ $1 == $2 ]]
        then
                echo "0"
        else
                change=$(bc <<< "scale=10; ((($1-$2)/$1)*100)")
                percent=$(printf "%0.10f\n" $change)
                echo $percent
        fi
}

# If the percentage change is greater than the amount we need to worry about
# we need to fail the files and, probably, send a notification email.
function do_we_need_to_worry {
        if [[ $percentage_change_whole_number -ge $percent_to_worry_about ]]
        then
                echo 1
        else
                echo 0
        fi
}

# Tidy up
function tidy_up {
	new_file=Experian_Report_${first_date}_${second_date}.txt
	new_file_csv=Experian_File_Report_${first_date}_${second_date}.csv
	new_counts_csv=Experian_Records_HHID_Counts_Report_${first_date}_${second_date}.csv
	new_attr_csv=Experian_Attribute_Record_Counts_Report_${first_date}_${second_date}.csv
	new_data_csv=Experian_Attribute_Data_Record_Counts_Report_${first_date}_${second_date}.csv
	new_error=Experian_Errors_${first_date}_${second_date}.txt

	if [[ $1 ]]
	then
		echo "$(date "+%Y-%m-%d %H:%M:%S") - Sending reports email to ${email}."
		if [[ $(uname -a | awk '{print $1}') == "Darwin" ]]
		then
			echo "$(date "+%Y-%m-%d %H:%M:%S") - Can't really send a report from here."
		else
			if [[ -f $experian_report_file ]]
			then
				mv $experian_report_file ${reports}/${new_file}
				mv $experian_file_report_csv ${reports}/${new_file_csv}
				mv $experian_record_counts_csv ${reports}/${new_counts_csv}
				mv $experian_attr_report_csv ${reports}/${new_attr_csv}
				mv $experian_attr_data_report_csv ${reports}/${new_data_csv}
				mailx -a "${reports}/${new_file}" -s "Experian Report File" -r $reply_to $email
			fi
			if [[ -f $experian_error_file ]]
			then
				mv $experian_error_file $reports/${new_error}
				mailx -a "${reports}/${new_error}" -s "Experian Error File" -r $reply_to $email
			fi
			
		fi
	else
		if [[ -f $experian_report_file ]]
		then
			mv $experian_report_file ${reports}/${new_file}
			mv $experian_file_report_csv ${reports}/${new_file_csv}
			mv $experian_record_counts_csv ${reports}/${new_counts_csv}
			mv $experian_attr_report_csv ${reports}/${new_attr_csv}
			mv $experian_attr_data_report_csv ${reports}/${new_data_csv}
		fi
		if [[ -f $experian_error_file ]]
		then
			mv $experian_error_file $reports/${new_error}
		fi

	fi

#	rm -r $working
}
