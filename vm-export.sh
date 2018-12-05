#!/bin/bash
OldIFS=$IFS
IFS=$'\n'

#Change this if your environment needs that
ExportDir=/home/$(whoami)/Documents

#Get the group to export from the user
echo "Which group do you want to export?"
select group in $(vboxmanage list groups); do
	ExportGroup=$(echo $group | sed -e 's/"//g')
	break
done

for VM in $(vboxmanage list vms); do
	VMName=$(echo "$VM" | cut -d' ' -f 1 | sed -e 's/"//g')
	VMUUID=$(echo "$VM" | cut -d' ' -f 2)
	VMGroups=$(vboxmanage showvminfo $VMUUID | grep "Groups" | cut -d':' -f 2 | sed -e 's/^[[:space:]]*//g')
	echo "Found VM $VMName that belongs to $VMGroups"
	if [ $ExportGroup == $VMGroups ]; then
		ExportName=$(echo -n "$ExportDir/$VMName.ova")
		if [ -f $ExportName ]; then
			echo "$ExportName already exists. Overwrite y/N?"
			read Overwrite
			if [ $Overwrite == 'y' ] || [ $Overwrite == 'Y' ]; then
				rm $ExportName
			else
				continue
			fi
		fi
		vboxmanage export $VMUUID -o $ExportName --ovf10
	fi

done
IFS=$OldIFS
