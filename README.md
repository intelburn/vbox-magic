# Intro

This is where automation for Orcale VirtualBox will live.
Scripts assume a Linux Host OS

## Background

VirtualBox has a robust command line. However it is rather annoying to handjam a bunch of commands in using these tools. So I am writing a series of scripts to make using VirtualBox from the command line a bit easier. See https://www.virtualbox.org/manual/ch08.html for more information.

## nic-magic.sh

This script is designed to help with managing the extra NICs that are not exposed in the VirtualBox GUI.

NOTE: If you are using the PIIX3 chipset for the VM you will only be able to use 8 NICs at a time. If you use the ICH9 chipset then you can use up 36 NICs

## vm-export.sh

This script is designed to bulk export all of the VMs belonging to a group as individual OVAs

## vm-import.sh

This script is designed to bulk import all of the OVAs in a directory into VirtualBox

## group-members.sh

This is a script that will return the same style of output as vboxmanage list vms, but only if a VM belongs to a group as input by the use.
