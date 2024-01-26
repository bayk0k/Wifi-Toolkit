#!/bin/bash

# Ensure the script is run with root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Function for Wi-Fi Scanning
wifi_scan() {
    read -p "Enter your wireless interface in monitor mode (e.g., wlan0mon): " interface
    echo "Scanning for wireless access points... Press Ctrl+C to stop."
    airodump-ng $interface --write /tmp/scan_results --output-format csv
    sleep 5  # Allows the user to stop the scan with Ctrl+C
    cat /tmp/scan_results-01.csv | grep -E -o "([[:xdigit:]]{2}:){5}[[:xdigit:]]{2},[^,]*,[^,]*,[^,]*" | while IFS=, read bssid power essid; do
        echo "BSSID: $bssid, Power: $power dBm, ESSID: $essid"
    done
    rm /tmp/scan_results-*
}

# Function for Packet Capturing
capture_packets() {
    read -p "Enter the BSSID of the target AP: " bssid
    read -p "Enter the channel of the target AP: " channel
    read -p "Enter your wireless interface in monitor mode: " interface
    echo "Capturing packets on $interface. Press Ctrl+C to stop."
    airodump-ng --bssid $bssid --channel $channel --write /tmp/captured_packets $interface
}

# Function for Network Scanning
network_scan() {
    read -p "Enter the network range to scan (e.g., 192.168.1.0/24): " network_range
    echo "Scanning the network range $network_range. This might take a while..."
    nmap -sP $network_range
}

# Main menu
echo "Wi-Fi Toolkit Menu:"
echo "1. Wi-Fi Scan"
echo "2. Capture Packets"
echo "3. Network Scan"
echo "4. Exit"
read -p "Select an option: " option

case $option in
    1) wifi_scan ;;
    2) capture_packets ;;
    3) network_scan ;;
    4) exit 0 ;;
    *) echo "Invalid option. Exiting..."; exit 1 ;;
esac
