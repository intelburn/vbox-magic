#!/bin/bash
#Change the separator from space to newline
OldIFS=$IFS
IFS=$'\n'
#Prompt the user for which mode they want
echo "Do you want to compact the HDDs of a group or all of the VMs?"
select mode in group all; do
    if [ "$mode" = "group" ]; then
        #Get the group to export from the user
        echo "Which group do you want to see membership for??"
        #Cut out the quotes from the group name
        select group in $(vboxmanage list groups | cut -d'"' -f 2); do
    	    break
        #Break out of the select to choose the group
        done
    #Close the mode if statement
    fi
    for VM in $(vboxmanage list vms); do
	    #cut the name of the VM out of the "s
	    VMName=$(echo "$VM" | cut -d'"' -f 2)
	    #Extract the UUID of the VM
	    VMUUID=$(echo "$VM" | cut -d'"' -f 3 | cut -d' ' -f 2)
        #Initialize ExportUUID to an empty string
        ExportUUID=""
        #Branch depending on the mode that the script is operating in
	    case $mode in
            #If in group mode
            group)
                #Get the groups that the VM belongs to
                VMGroups=$(vboxmanage showvminfo $VMUUID | grep "Groups:" | cut -d':' -f 2 | sed -e 's/^[[:space:]]*//g')
	            #Check to see if the VM belongs to the group for compacting
	            if [ $group == $VMGroups ]; then
                    #Set the ExportUUID to the UUID of the VM
	        	    ExportUUID=$(echo "$VMUUID")
	            fi
                ;;
            #If in all mode
            all)
                #Set the Export UUID to the UUID of the VM
                ExportUUID=$(echo "$VMUUID")
                ;;
        #End the mode case statement
        esac
        #Check to see if the ExportUUID is actually filled with a string
        if [[ $(echo -n "$ExportUUID" | wc -m) -gt 2 ]]; then
            #Loop through all of the disks in a VM
            #Lines that contain HDD files have a distinctive (UUID: [actuall UUID]) format on the end of the line
            #Thus I am grep'ing for that pattern
            #I then isolate the actual UUID
            #Then finally do the looping
            for DiskUUID in $(vboxmanage showvminfo $ExportUUID | grep "(UUID" | cut -d ":" -f 3 | cut -d ")" -f 1 | cut -d " " -f 2); do
                #Tell the user which VM I am compacting
                echo "Compacting a disk from the VM \"$VMName\""
                #Actually compact the disk
                vboxmanage modifymedium {$DiskUUID} --compact
            #Close out the DiskUUID for loop
            done
        #Close out the ExportUUID if statement
        fi
    #Close out the VM for Look
    done
    #Break out of the mode select statement
    break
#Close out the mode select statement
done
IFS=$OldIFS