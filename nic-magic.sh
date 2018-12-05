#!/bin/bash
#Change the separator from space to newline
OldIFS=$IFS
IFS=$'\n'
echo "about to enter VM loop"
while true; do
	echo "entered VM loop"
	#Make Usere select from VMs
	echo "Which VM do you want to modify?"
	select VMName in $(vboxmanage list vms | cut -d' ' -f 1); do
		VMUUID=$(vboxmanage list vms | grep $VMName |  cut -d' ' -f 2)
		#set up the loop so that the user config multiple NICs for the selected VM
		while true; do
			#Get NIC to configure from user
			#Using While for input validation
			echo "Which NIC (1-8) do you want to configure on $VMName?"
			while true; do
				read NICNum
				#chech for correct input
				if [ $NICNum -gt 0 ] && [ $NICNum -lt 9 ]; then
					break
				else
					echo "Invalid NIC number"
					echo "Enter a number greater than 0 but less than 9"
				fi
			done
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
						echo "case none"
						vboxmanage modifyvm $VMUUID --nic$NICNum none
						break
						;;
					Bridge)
						echo "case Bridged"
						echo "What do you want to bridge to?"
						select iface in $(ip a | grep mtu | cut -d' ' -f 2 | cut -d ':' -f 1 | cut -d'@' -f 1); do
							vboxmanage modifyvm $VMUUID --nic$NICNum bridged
							vboxmanage modifyvm $VMUUID --bridgeadapter$NICNum $iface
							echo "Which promisc mode?"
							select promisc in deny allow-vms allow-all; do
								vboxmanage modifyvm $VMUUID --nicpromisc$NICNum $promisc
								break
							done
							#Change the adapter type, feel free to comment out if not wanted
							vboxmanage modifyvm $VMUUID --nictype$NICNum 82543GC
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
								#Change the adapter type, feel free to comment out if not wanted
								vboxmanage modifyvm $VMUUID --nictype$NICNum 82543GC
								break
							elif [ $new == 'n' ] || [ $new =='N' ]; then
								echo "Which network to connect to?"
								select net in $(vboxmanage list intnets | cut -d':' -f 2 | sed -e 's/^[[:space:]]*//'); do
									vboxmanage modifyvm $VMUUID --nic$NICNum intnet
									vboxmanage modifyvm $VMUUID --intnet$NICNum "$net"
									#Change the adapter type, feel free to comment out if not wanted
									vboxmanage modifyvm $VMUUID --nictype$NICNum 82543GC
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
						echo "Something broke. NICType is $NICType"
						break
						;;
				esac

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
