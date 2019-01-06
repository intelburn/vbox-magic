#!/bin/bash
#Change the separator from space to newline
OldIFS=$IFS
IFS=$'\n'
while true; do
	#Make User select from VMs
	#vboxmanage outputs the list of VMs in the following format:
	#"VM Name" {UUID}
	#I am using cut to get the human readable name from inside the quotes even if there are spaces in the name.
	echo "Which VM do you want to modify?"
	select VMName in $(vboxmanage list vms | cut -d'"' -f 2); do
		#Due to failures in the prototype of this script I am using the UUID for the actual final version
		#I am using grep to get the UUID based on then name that the user selected.
		#The two cuts are simply to extract the UUID without any quotes or spaces.
		#The UUID will be after the second ", and after a space
		VMUUID=$(vboxmanage list vms | grep \"$VMName\"| cut -d'"' -f 3 | cut -d' ' -f 2)
		#set up the loop so that the user config multiple NICs for the selected VM
		while true; do
			#Depending on the chipset in use there could be either 8 or 36 NICs on a single VM.
			#To account for this I am using showvminfo to get the actual number of NICs on the VM.
			#The egrep is to actually get a list of NICs from the large amount of data returned by the showvminfo
			#The cut is to get the output into the format of NIC [number]
			echo "Which NIC do you want to configure on $VMName?"
			select NICName in $(vboxmanage showvminfo $VMUUID | egrep "NIC [0-9]+:" | cut -d':' -f 1); do

				NIC=$(vboxmanage showvminfo $VMUUID | grep $NICName:)
				echo "$NICName is configured as $(echo -n $NIC | cut -d':' -f 2- | sed  's/^[[:space:]]*//g')"
				NICNum=$(echo -n $NIC | cut -d':' -f 1 | cut -d' ' -f 2)
				#Ask the user for the type of nic to use
				echo "What type of connection do you want? (None to remove NIC from VM)"
				select NICType in NAT Bridge Internal None; do
					#Switch based on user input
					case $NICType in
						#Make the NAT NIC
						NAT)
							vboxmanage modifyvm $VMUUID --nic$NICNum nat
							#Change the adapter type, feel free to comment out if not wanted
							vboxmanage modifyvm $VMUUID --nictype$NICNum 82543GC
							break
							;;
						#Remove the NIC from the the VM
						None)
							vboxmanage modifyvm $VMUUID --nic$NICNum none
							break
							;;
						Bridge)
							echo "What do you want to bridge to?"
							select iface in $(ip a | grep mtu | cut -d' ' -f 2 | cut -d ':' -f 1 | cut -d'@' -f 1); do
								vboxmanage modifyvm $VMUUID --nic$NICNum bridged
								vboxmanage modifyvm $VMUUID --bridgeadapter$NICNum $iface
								echo "Which promisc mode?"
								select promisc in deny allow-vms allow-all; do
									vboxmanage modifyvm $VMUUID --nicpromisc$NICNum $promisc
									break
								done
								break
							done
							break
							;;
						Internal)
							#Create loop for error checking
							while true; do
								echo "Create new internal network y/n?"
								read new
								if [ $new == 'y' ] || [ $new == 'Y' ]; then
									echo "Enter the name of the internal network:"
									read net
									vboxmanage modifyvm $VMUUID --nic$NICNum intnet
									vboxmanage modifyvm $VMUUID --intnet$NICNum "$net"
									break
								elif [ $new == 'n' ] || [ $new =='N' ]; then
									echo "Which network to connect to?"
									select net in $(vboxmanage list intnets | cut -d':' -f 2 | sed -e 's/^[[:space:]]*//'); do
										vboxmanage modifyvm $VMUUID --nic$NICNum intnet
										vboxmanage modifyvm $VMUUID --intnet$NICNum "$net"
										break
									done
									break
								else
									echo "You broke it"
								fi
							done
							break
							;;
						*)
							echo "Something broke."
							break
							;;
					esac
				done
				echo "What kind of NIC hardware do you want? (If you selected a type of None then this doesn't matter)"
				select HWType in "PCNet PCI II (Am79C970A)" "PCNet FAST III (Am79C973)" "Intel PRO/1000 MT Desktop (82540EM)" "Intel PRO/1000 T Server (82543GC)" "Intel PRO/1000 MT Server (82545EM)" "Paravirtualized network adapter (virtio-net)"; do
					HWString=$(echo -n $HWType | cut -d"(" -f 2 | tr -d ")")
					vboxmanage modifyvm $VMUUID --nictype$NICNum $HWString
					break
				done
			break
			done
			echo "Configure another NIC Y/n?"
			read NICSelect
			if [ $NICSelect == 'n' ] || [ $NICSelect == 'N' ]; then
				break
			fi
			done
			break
		done
		echo "Manage another VM Y/n?"
		read VMSelect
		if [ $VMSelect == 'n' ] || [ $VMSelect == 'N' ]; then
			break
		fi
	done
IFS=$OldIFS
