COL_LENGTH=$(tput cols)
HALF=$(($COL_LENGTH/2))
UPDATE_FILE=update.$(date +"%d%m%Y%H%M%S")
NO_FILES=1
echo $NO_FILES > /tmp/total_upgrades

pacman -Sy

printf "\n"

for i in $(eval echo {1..$COL_LENGTH})
do 
	printf "%s" "="
done

printf "\n"
tput bold
printf "%*s%*s%*s\n" 5 "Program" $(($HALF-7)) "Version" $HALF "Repository"
tput sgr0

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

for i in $(eval echo {1..$COL_LENGTH})
do 
    printf "%s" "="
done

NO_UPDATES=$(cat /tmp/total_upgrades)

if [ "$NO_UPDATES" = "1" ]
then
    printf "\n\n"
    echo "No upgrades present at the moment..."
    rm /tmp/total_upgrades
    exit 1
else
    printf "\n"
    printf "\n%s%s\n\n" $NO_UPDATES " files to be upgraded."
    rm /tmp/total_upgrades

    select result in Yes No
    do
    case $result in
            Yes ) 
            echo "Upgrading..."
            mkdir /var/cache/pacman/$UPDATE_FILE.d
            pacman -Sup > /var/cache/pacman/$UPDATE_FILE.d/$UPDATE_FILE
            sed -i 1d /var/cache/pacman/$UPDATE_FILE.d/$UPDATE_FILE
            aria2c --dir=/var/cache/pacman/$UPDATE_FILE.d/pkgs -i/var/cache/pacman/$UPDATE_FILE.d/$UPDATE_FILE -j10
            cd /var/cache/pacman/$UPDATE_FILE.d/pkgs
            pacman --noconfirm -U *
            break;;
            No ) 
            echo "Cancelling upgrade..."
            exit;;
    esac
    done
fi
