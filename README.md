# Intro

This is where automation for Orcale VirtualBox will live.
Scripts assume a Linux Host OS

## nic-magic.sh

This script is designed to help with managing the extra NICs that are not exposed in the VirtualBox GUI.
NOTE: If you are using the PIIX3 chipset for the VM you will only be able to use 8 NICs at a time. If you use the ICH9 chipset then you can use up 36 NICs

## vm-export.sh

This script is designed to bulk export all of the VMs belonging to a group as individual OVAs