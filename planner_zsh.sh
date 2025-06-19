#!/bin/bash

if [[ -d "$HOME/Desktop" ]]; then
    if [[ -d "$HOME/Desktop/PLANNERAPPBASH" ]]; then
        BASEDIR="$HOME/Desktop/PLANNERAPPBASH"
    else
        mkdir -p "$HOME/Desktop/PLANNERAPPBASH"
        BASEDIR="$HOME/Desktop/PLANNERAPPBASH"
    fi
else
    # Fallback if Desktop doesn't exist
    mkdir -p "$HOME/PLANNERAPPBASH"
    BASEDIR="$HOME/PLANNERAPPBASH"
    echo "Warning: Desktop not found. Using $BASEDIR instead."
fi

cd "$BASEDIR"

# WELCOME MESSAGE --------------------------------------
clear
year=`date | sed -E 's/.* ([0-9]{4})$/\1/'`
dayoftheweek=`date | sed -E 's/^([A-z]{3}) .*/\1/'`
todaydate=`date | awk '{print $2, $3}'`
echo -e "Welcome to Planner App!\nYear: $year"

options=("My Profile (info, progress)" "To-do List (main page)" "Edit Tasks (yearly, weekly, daily)")

while true
do
	echo -e "Where would you like to go to?: \n"

	tempnum=1
	for i in "${options[@]}"
	do
		echo "$tempnum) $i"
		tempnum=$(($tempnum+1))
	done
	echo "0) EXIT"
	
	echo -en "\nOption: "
	read option

	case $option in
	# EXIT APP ------------------------------------------------
	0) clear
	echo "You selected exit the app"
	echo "Thank you for using MAPA app, come plan here again! :)"
	echo "------------------------"
	break
	;;

	# PROFILE ------------------------------------------------
	1) clear 
	echo "You selected to go to ${options[0]}"
	cd "$BASEDIR"
	if [[ -d "myprofile" ]]
	then
		cd myprofile
		cat info.txt
		cat progress.txt
	else
		echo "You did not have a profile yet, let's create one..."
		
		mkdir myprofile
		cd "$BASEDIR"/myprofile

		touch info.txt progress.txt
		echo -n "Provide your name: "
		read -r name
		echo -n "Provide your occupation: "
		read -r occupation
		echo -n "Provide your date of birth (month, day, year: ##/##/####): "
		read -r birthdate

		echo -e "\nName: $name" >> info.txt
		echo "Occupation: $occupation" >> info.txt
		echo -e "Birthdate: $birthdate\n" >> info.txt
		
		cat info.txt		
		touch progress.txt
	fi	
	echo -n "Press enter to continue..."
	read
	clear
	;;

	# TODOLIST ------------------------------------------------
	2) clear
	echo "You selected to go to ${options[1]}"
	cd "$BASEDIR"
	if [[ -d todolist ]]
	then
		cd "$BASEDIR"/todolist
		if [[ "$dayoftheweek $todaydate $year" != `awk 'NR==1{print $0}' specific.txt` ]]
		then
			# SPECIFIC
        	echo "Would you like to do something specific today? Do the same like before, just"
        	echo "press ctrl+d when you finish or if you don't want to do anything specific"
        	date | awk '{print $1, $2, $3, $6}' > specific.txt
        	cat >> specific.txt
		fi
		echo -e "\nDAILY TODO"
		cat daily.txt
		echo -e "\n(specifically today)"
		cat specific.txt
		echo -e "\nWEEKLY TODO ($dayoftheweek)"
		cd "$BASEDIR"/todolist/weekly
		cat "$dayoftheweek.txt"
		cd "$BASEDIR"/todolist
		echo -e "\nYEARLY TODO (GOALS)"
		cat yearly.txt
	else
		# YEARLY
		echo "You did not have a todo list yet, let's create one..."
		mkdir todolist
		cd "$BASEDIR"/todolist
		echo "What are your yearly goals? (Like resolutions, after you finish press ctrl+d): "
		cat > yearly.txt

		# WEEKLY
		mkdir weekly
		cd "$BASEDIR"/todolist/weekly
		echo "Let's make your weekly to-dos, they will renew automatically on the main page..."
		days=(Mon Tue Wed Thu Fri Sat Sun)
		for day in ${days[@]}
		do
			echo "What do you want to do on $day? (Press ctrl+d after you finish):"
			cat > "$day.txt"
		done
		cd "$BASEDIR"/todolist

		# DAILY
		echo "Let's make your daily to-dos, they will renew automatically on the main page..."
		echo "Press ctrl+d after you finish..."
		cat > daily.txt
		
		# SPECIFIC
		echo "Would you like to do something specific today? Do the same like before, just"
		echo "press ctrl+d when you finish or if you don't want to do anything specific"
		date | awk '{print $1, $2, $3, $6}' > specific.txt
		cat >> specific.txt		
	fi
	echo
	echo -n "Press enter to continue..."
	read
	clear
	;;

	# EDIT ------------------------------------------------
	3) clear
	echo "You selected to go to ${options[2]}"
	cd "$BASEDIR"

	if [[ -d todolist ]]; then

		files=("yearly.txt" "weekly" "daily.txt" "specific.txt")

    	while true; do
			cd "$BASEDIR"/todolist
			echo "Which one do you want to edit?:"
        	echo "1) Yearly"
        	echo "2) Weekly"
        	echo "3) Daily"
        	echo "4) Specific (for today)"
        	echo "0) Exit"
        	read file_choice
			clear

        	[[ "$file_choice" == "0" ]] && break
			
			filename="${files[$((file_choice-1))]}"
        	if [[ -z "$filename" || ( ! -f "$filename" && ! -d "$filename" ) ]]; then
            	echo "Invalid choice or file/directory doesn't exist."
				sleep 2
            	continue
        	fi
			
			if [[ "$filename" == "weekly" ]]
			then
				if [[ ! -d "weekly" ]]; then
					echo "You don't have weekly folder set up yet. Please choose option 2 before 3."
					sleep 2
					clear
					continue
				fi
				cd "$BASEDIR"/todolist
				days=(Mon Tue Wed Thu Fri Sat Sun)
				echo "Which day's file would you like to edit?"
    			select dayfile in "${days[@]}" "Go back"; do
    			    if [[ "$REPLY" -ge 1 && "$REPLY" -le 7 ]]; then
            			filename="$dayfile.txt"
						break
        			elif [[ "$REPLY" == "8" ]]; then
            			filename=""
        				break
        			else
            			echo "Invalid selection. Try again."
        			fi
    			done
				clear

    			[[ -z "$filename" ]] && continue

    			echo "What would you like to do with $filename?"
    			echo "1) Delete a line"
    			echo "2) Add a new line"
    			echo "3) Edit a line"
    			echo "0) Go back"
    			read action
    			clear

    			[[ "$action" == "0" ]] && continue

    			cat -n "$filename"

    			case $action in
    			1)
    			    echo -n "What line number you want to delete?: "
        			read line
        			sed -i '' "${line}d" "$filename"
        			;;
    			2)
        			echo "What would you like to add? (Press ctrl+d when you finish): "
        			cat >> "$filename"
        			;;
    			3)
        			echo -n "What line number you want to replace?: "
        			read line
        			echo -n "What would you like to replace it with?: "
        			read newline
        			sed -i '' "${line}s/.*/${newline}/" "$filename"
        			;;
    			*)
        			echo "Invalid action."
        			;;
    			esac

			else
				echo "What would you like to do with $filename?"
				echo "1) Delete a line"
				echo "2) Add a new line"
				echo "3) Edit a line"
				echo "0) Go back"
				read action
				clear

        		[[ "$action" == "0" ]] && continue

        		cat -n "$filename"

        		case $action in
        		1)
            		echo -n "What line number you want to delete?: "
            		read line
            		sed -i '' "${line}d" "$filename"
            		;;
        		2)
            		echo "What would you like to add? (Press ctrl+d when you finish): "
					cat >> $filename
            		;;
        		3)
            		echo -n "What line number you want to replace?: "
            		read line
            		echo -n "What would you like to replace it with?: "
            		read newline
            		sed -i '' "${line}s/.*/${newline}/" "$filename"
            		;;
        		*)
            		echo "Invalid action."
            		;;
        		esac
			fi
			echo -n "Press enter to continue..."
			read
			clear
    	done
	else
		echo "You do not have a list to edit, please choose option 2 before choosing 3"
		sleep 2
	fi
	;;
	esac
done
