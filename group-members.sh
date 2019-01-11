#!/bin/bash
OldIFS=$IFS
IFS=$'\n'

#Get the group to export from the user
echo "Which group do you want to see membership for??"
#Cut out the quotes from the group name
select group in $(vboxmanage list groups | cut -d'"' -f 2); do
	break
done

for VM in $(vboxmanage list vms); do
	#cut the name of the VM out of the "s
	VMName=$(echo "$VM" | cut -d'"' -f 2)
	#Extract the UUID of the VM
	VMUUID=$(echo "$VM" | cut -d'"' -f 3 | cut -d' ' -f 2)
	#Get the groups that the VM belongs to
	VMGroups=$(vboxmanage showvminfo $VMUUID | grep "Groups:" | cut -d':' -f 2 | sed -e 's/^[[:space:]]*//g')
	#Check to see if the VM belongs to the group for export
	if [ $group == $VMGroups ]; then
		echo "\"$VMName\" $VMUUID"
	fi

done
IFS=$OldIFS
