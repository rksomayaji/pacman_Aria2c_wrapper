COL_LENGTH=$(tput cols)
ONE_THIRD=$(($COL_LENGTH/3))
HALF=$(($COL_LENGTH/2))
TEMP_FILE=update.$(date +"%d%m%Y%H%M%S")
NO_FILES=1
echo $TEMP_FILE

pacman -Sy

for i in $(eval echo {1..$COL_LENGTH})
do 
	printf "%s" "="
done

printf "\n"

pacman -Sup --print-format "%n %v %r" | while read line
do 
	NAME="$NO_FILES) $(echo $line | cut -d ' ' -f 1)"
	VERSION=$(echo $line | cut -d ' ' -f 2)
	REPOS=$(echo $line | cut -d ' ' -f 3)
	if [ "$NAME" = "1) ::" ]
	then
		for i in $(eval echo {1..$COL_LENGTH})
		do
        		printf "%s" "="
		done
	else
		printf "%s%*s%*s\n" "$NAME" $(($HALF-${#NAME})) $VERSION $HALF $REPOS
		echo $NO_FILES > /tmp/total_upgrades
		NO_FILES=$(($NO_FILES+1))
	fi
done

printf "\n%s%s\n\n" $(cat /tmp/total_upgrades) " files to be upgraded."
rm /tmp/total_upgrades

select result in Yes No
do
case $result in
       	Yes ) 
		echo "Upgrading..."
		mkdir /var/cache/pacman/$TEMP_FILE.d
		pacman -Sup > /var/cache/pacman/$TEMP_FILE.d/$TEMP_FILE
		sed -i 1d /var/cache/pacman/$TEMP_FILE.d/$TEMP_FILE
		aria2c --dir=/var/cache/pacman/$TEMP_FILE.d/pkgs -i/var/cache/pacman/$TEMP_FILE.d/$TEMP_FILE -j10
		cd /var/cache/pacman/$TEMP_FILE.d/pkgs
		pacman --noconfirm -U *
		break;;
       	No ) 
		echo "Cancelling upgrade..."
		exit;;
esac
done
