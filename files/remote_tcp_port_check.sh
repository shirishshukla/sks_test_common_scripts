#!/bin/bash
#####################################
# Prerequisite:
#   - [OPTIONAL] Download install sshpass 
#                - https://pkgs.org/download/sshpass
#                - If epel repo there 
#                    RHEL|CentOS: $ yum install sshpass 
#                    Ubuntu: apt-get install sshpass
#   - Your file must contain list of servers line by line
###

## Help Function
helps () {
        echo -e "\n------------------------------\n"
cat << EOF
    Help Section: $ $0 <options>
       -f|--file-name              File-name contains servers list
       -d|--dest-host              Destination IP
       -d|--dest-port              Destination PORT to be checked
       -u|--user                   SSH Username
       -h|--help                   Help Section
EOF
        echo -e "\n------------------------------\n"
                exit
}

## Read Options
SHORT=f:d:p:u:h
LONG=file-name:,dest-host:,dest-port:

OPTS=$(getopt --options $SHORT --long $LONG --name "$0" -- "$@")

if [ $? != 0 ] ; then echo "Failed to parse options...exiting." >&2 ; exit 1 ; fi

eval set -- "$OPTS"

## Extract options and their arguments into variables
while true ; do
    case "$1" in
        -f|--file-name)  fileName="$2" ; [[ ! -s $2 ]] && echo -e "File \"$2\" not exist or empty!!" && exit
                         shift 2 ;;
        -d|--dest-host)  destHost="$2" ; shift 2 ;;
        -p|--dest-port)  destPort="$2" ; shift 2 ;;
         -u|--ssh-user)  sshUser="$2"  ; shift 2 ;;
             -h|--help)  helps ;;
                    --) shift ; break ;;
                     *) echo "Internal error!" ; helps; exit 1 ;;
    esac
done

## Validate
[[ -z $fileName || -z $destHost || -z $destPort || -z $sshUser ]] && echo -e "\nPlease pass correct set of arguments" && helps


## sshpass
# Check if sshpass present
SSHPASS=`which sshpass 2>/dev/null`
if [[ ! -z $SSHPASS ]]; then
    ## SSH USER password
    echo -en "Enter $sshUser password: "; read -s PSW
    [[ -z $PSW ]] && echo -e "Password for user $sshUser can't be blank" && exit
    SSH="$SSHPASS -p $PSW ssh"
else
    SSH='ssh -q '
fi

## Check
SRVPORT="$destHost:$destPort"
CMD="timeout 2  bash -c \"</dev/tcp/$destHost/$destPort\" 2>/dev/null && echo TCP $SRVPORT - Port_Open || echo TCP $SRVPORT - Port_Closed"

echo -e "\nChecking TCP Connection to $SRVPORT"
for SRV in `cat $fileName`; do
   VAL=$($SSH ${sshUser}@${SRV} $CMD)
   echo -e "-> $SRV: $VAL"
done

## END ##
