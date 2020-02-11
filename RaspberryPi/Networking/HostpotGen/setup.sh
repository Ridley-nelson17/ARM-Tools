###################################################
############## Remove previous files ##############
###################################################

{ # try
    sudo rm wpa_supplicant.conf
    sudo rm dhcpcd.conf
    sudo rm dnsmasq.conf
    sudo rm hostapd
} || { # catch
    rm wpa_supplicant.conf
    rm dhcpcd.conf
    rm dnsmasq.conf
    rm hostapd
}

####################################################
################ Write to the files ################
####################################################

cat <<EOT >> wpa_supplicant.conf
country=US
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
EOT

cat <<EOT >> dhcpcd.conf
# A sample configuration for dhcpcd.
# See dhcpcd.conf(5) for details.

# Allow users of this group to interact with dhcpcd via the control socket.
#controlgroup wheel

# Inform the DHCP server of our hostname for DDNS. 
# CHANGE THIS ->
hostname

# Use the hardware address of the interface for the Client ID.
clientid
# or
# Use the same DUID + IAID as set in DHCPv6 for DHCPv4 ClientID as per RFC4361.
# Some non-RFC compliant DHCP servers do not reply with this set.
# In this case, comment out duid and enable clientid above.
#duid

# Persist interface configuration when dhcpcd exits.
persistent

# Rapid commit support.
# Safe to enable by default because it requires the equivalent option set
# on the server to actually work.
option rapid_commit

# A list of options to request from the DHCP server.
option domain_name_servers, domain_name, domain_search, host_name
option classless_static_routes
# Most distributions have NTP support.
option ntp_servers
# Respect the network MTU. This is applied to DHCP routes.
option interface_mtu

# A ServerID is required by RFC2131.
require dhcp_server_identifier

# Generate Stable Private IPv6 Addresses instead of hardware based ones
slaac private

# Example static IP configuration:
#interface eth0
#static ip_address=192.168.0.10/24
#static ip6_address=fd51:42f8:caae:d92e::ff/64
#static routers=192.168.0.1
#static domain_name_servers=192.168.0.1 8.8.8.8 fd51:42f8:caae:d92e::1

# It is possible to fall back to a static IP if DHCP fails:
# define static profile
#profile static_eth0
#static ip_address=192.168.1.23/24
#static routers=192.168.1.1
#static domain_name_servers=192.168.1.1

# fallback to static profile on eth0
#interface eth0
fallback static_eth0

interface wlan0
static ip_address=192.168.4.1/24
EOT

cat <<EOT >> dnsmasq.conf
interface=wlan0
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h
dhcp-option=3,192.168.4.1
dhcp-option=6,192.168.4.1

address=/#/192.168.4.1
address=/apple.com/192.168.4.1
address=/captive.apple.com/192.168.4.1
address=/appleiphonecell.com/192.168.4.1
address=/airport.us/192.168.4.1
address=/akamaiedge.net/192.168.4.1
address=/akamaitechnologies.com/192.168.4.1
address=/microsoft.com/192.168.4.1
address=/msftncsi.com/192.168.4.1
address=/msftconnecttest.com/192.168.4.1
address=/google.com/192.168.4.1
address=/gstatic.com/192.168.4.1
address=/googleapis.com/192.168.4.1
address=/android.com/192.168.4.1
EOT

cat <<EOT >> hostapd
# Defaults for hostapd initscript
#
# See /usr/share/doc/hostapd/README.Debian for information about alternative
# methods of managing hostapd.
#
# Uncomment and set DAEMON_CONF to the absolute path of a hostapd configuration
# file and hostapd will be started during system boot. An example configuration
# file can be found at /usr/share/doc/hostapd/examples/hostapd.conf.gz
#
#DAEMON_CONF=""

# Additional daemon options to be appended to hostapd command:-
#       -d   show more debug messages (-dd for even more)
#       -K   include key data in debug messages
#       -t   include timestamps in some debug messages
#
# Note that -B (daemon mode) and -P (pidfile) options are automatically
# configured by the init.d script and must not be added to DAEMON_OPTS.
#
#DAEMON_OPTS=""
DAEMON_CONF="/etc/hostapd/hostapd.conf"
EOT

#############################################################
################ Enable the Wireless network ################
#############################################################
{ # try
    sudo cp config/hostapd /etc/default/hostapd
    sudo cp config/dhcpcd.conf /etc/dhcpcd.conf
    sudo cp config/dnsmasq.conf /etc/dnsmasq.conf
    sudo cp wpa.conf /etc/wpa_supplicant/wpa_supplicant.conf
    sudo reboot now
} || { # catch
    cp config/hostapd /etc/default/hostapd
    cp config/dhcpcd.conf /etc/dhcpcd.conf
    cp config/dnsmasq.conf /etc/dnsmasq.conf
    cp wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
    
    reboot now
}
