#!/bin/bash

# Contributors: Riley Easton
# Colorado State University
# ! Requires real tabs for indentation, heredoc used. !

# DEBUG flag enables mock printer to test transfer/delete scripts
DEBUG=false

##########################
# FUNCTIONS DEFINED HERE #
##########################

function usage {
	cat <<-EOF

	$0: a script to print to the CS Department printers
	Requires you to have an account with the CSU CS Dept.
	Requires connection to campus.

	Guidelines from the SNA website:
	Do not print large voluminous manuals. Large on-line manuals should be perused 
	on-line. Users who print exceptionally large volumes of output will be asked to
	pay the costs of the printing. Try not to print something unless you REALLY
	need a hard-copy. Do not use the printers as copy machines.

	The soft limits for undergraduates are 35 pages per print job and 75 pages per 
	week. These are limits of excess, not allocations. You should try to keep your 
	printing well below these limits.

	usage: $0 username file [labmachine]
	       username -- your username for the CS Dept.
	       file -- the file to transfer and print (PDF, PostScript, or plain text)
	       labmachine -- the name of the computer to print from. defaults to albany
	
	EOF
}

# printer options should be updated as new equipement is deployed
# you can find the list of printers at https://sna.cs.colostate.edu/printing/
function print_list_of_printers {
	if $DEBUG; then
		echo "999 - debug      mock printer              testing only"
	fi
	cat <<-EOF
		470 - mandolin   HP LaserJet 4515x         in hallway
		450 - dobro      HP Color LaserJet M553dn  in hallway
		450 - conch      HP LaserJet 4515x         in hallway
		350 - guitar     HP Color LaserJet M553dn  in hallway 
		350 - fiddle     HP LaserJet M602x         in hallway
		250 - rabaab     HP LaserJet 4515x         in hallway
		250 - kazoo      HP LaserJet 4515x         in hallway
		211 - ukulele    HP LaserJet 4515x         at reception
		120 - tuba       HP LaserJet 4515x         in lab
		120 - banjo      HP LaserJet 4515x         in lab
		110 - washboard  HP LaserJet 4515x         in lab
		EOF
}

function check_prereq {
	if ! command -v "$1" &> /dev/null; then
		echo "$1 is required, but it's currently missing. Please install it."
		exit 1
	fi
}

function select_printer {
	printer="$(print_list_of_printers | fzf --tac | awk '{print $3}')"
	if [ -z "$printer" ]; then
		echo "No printer selected. Exiting."
		exit 2
	fi
}

function verify_printer {
	if [ "$printer" == "debug" ]; then
		return
	fi
	local printerstatus
	printerstatus=$(sshpass -p "$password" ssh "$username"@"$labmachine".cs.colostate.edu "lpstat -p $printer -l" 2>&1)
	check_ssh_failure
	echo "$printerstatus"
	if [[ $printerstatus == *"disabled"* ]]; then
		echo "Printer $printer is disabled."
		printf "Select another printer? y/n: "
		read -n 1 -r
		echo
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			select_printer
			verify_printer
			return
		else
			printf "Exiting.\n\n"
			exit 3
		fi
	fi
	return
}

function check_ssh_failure {
	if [ $? -ne 0 ]; then
	cat <<-EOF

		A connection failure occurred.
		Please verify your username and password.
		ssh $userhost

		EOF
		exit 4
	fi
}

function check_host_exists {
	if ! dig +short "$host" | grep -q .; then
		cat <<-EOF

			$host does not resolve.
			Please make sure you are connected to the CSU network.

			EOF
		exit 5
	fi
}

function check_host_known {
	if ! ssh-keygen -F "$host" &> /dev/null; then
		cat <<-EOF

			$host is not in your known_hosts file.
			Please ssh into $host one time prior to using this.
			Alternatively, you can select a lab machine you have connected to before.

			ssh $userhost
			-OR-
			$0 $username $file [known lab machine]

			EOF
		exit 6
	fi
}

function check_mime_type {
	local mimetype
	mimetype=$(file --mime-type -b "$file")
	if [ "$mimetype" != "application/pdf" ] && [ "$mimetype" != "application/postscript" ] && [ "$mimetype" != "text/plain" ]; then
		cat <<-EOF

			$file is not a valid file type.
			Please convert it to PDF, PostScript, or plain text before printing.

			EOF
		exit 7
	fi
}

#########################
# EXECUTION STARTS HERE #
#########################

# parse arguments' count

if [ $# -lt 2 ] || [ $# -gt 3 ]; then
	usage
	exit 1
fi

# check if prereqs are installed
# most of these should be installed by default
# fzf, sshpass were the problem ones on MacOS

check_prereq realpath
check_prereq basename
check_prereq uuidgen
check_prereq date
check_prereq file
check_prereq dig
check_prereq grep
check_prereq cat
check_prereq ssh-keygen
check_prereq echo
check_prereq fzf
check_prereq awk
check_prereq printf
check_prereq read
check_prereq sshpass
check_prereq ssh
check_prereq scp

username="$1"
file=$(realpath "$2")
basename=$(basename "$file")
pcfile="printcache_$(uuidgen)$(date +%s)"
labmachine="${3:-albany}"
printer=""
host="$labmachine.cs.colostate.edu"
userhost="$username@$host"

# verify file is supported
check_mime_type

# verify that host actually exists and is known
check_host_exists
check_host_known

# select printer
select_printer

printf "%s@%s.cs.colostate.edu's password: " "$username" "$labmachine"
read -s -r password
printf "\n"

# ssh-keyscan "$host" >> ~/.ssh/known_hosts
sshpass -p "$password" ssh "$userhost" "mkdir -p ~/.printcache/"
check_ssh_failure

# update printer based on status check
verify_printer


echo "Transferring $basename to $username@$labmachine.cs.colostate.edu..."
sshpass -p "$password" scp "$file" "$username@$host:~/.printcache/$pcfile"
check_ssh_failure

if [ "$printer" == "debug" ]; then
	echo "Debug printer selcted. Not actually printing $basename..."
	lpcommand=""
else
	echo "Printing $basename to $printer..."
	lpcommand="lp -d $printer ~/.printcache/$pcfile;"
fi

sshpass -p "$password" ssh "$username"@"$labmachine".cs.colostate.edu "$lpcommand echo \"rm -- ~/.printcache/$pcfile\" | at now + 10 minutes > /dev/null 2>&1"
check_ssh_failure
