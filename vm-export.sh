#!/bin/bash
OldIFS=$IFS
IFS=$'\n'

#Change this if your environment needs that
ExportDir=/home/$(whoami)/Documents

#Get the group to export from the user
echo "Which group do you want to export?"
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
	echo "Found VM $VMName that belongs to $VMGroups"
	#Check to see if the VM belongs to the group for export
	if [ $group == $VMGroups ]; then
		#Make the full absolute path and filename combo for export
		ExportName=$(echo -n "$ExportDir/$VMName.ova")
		#Check if the file to export exists
		if [ -f $ExportName ]; then
			#Prompt the user if they want to overwrite
			echo "$ExportName already exists. Overwrite y/N?"
			read Overwrite
			if [ $Overwrite == 'y' ] || [ $Overwrite == 'Y' ]; then
				#If the user wants to overwrite, then delete the conflicing file
				rm $ExportName
			else
				#If the user does not want to overwrite, then skip the export
				continue
			fi
		fi
		#Actually export the VM
		vboxmanage export $VMUUID -o $ExportName --ovf10
	fi

done
IFS=$OldIFS
