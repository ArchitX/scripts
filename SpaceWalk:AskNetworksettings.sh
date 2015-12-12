host_name=""
ip=""
netmask=""
gw=""
bootproto=
answer="n"
ipok=0
nmok=0
gwok=0
validhost=0
device="eth0"
hwaddr=`ifconfig $device | grep -i hwaddr | sed -e 's#^.*hwaddr[[:space:]]*##I'`
dns1=""
dns2=""
NetworkFile="/tmp/network.ks"
DnsFile="/tmp/dns.ks"
GwFile="/tmp/gateway.ks"



ipvalid=unchecked
check_ip()
        {
        size=${#1}
        digit1=`printf "$1" | cut -d "." -f1`
        digit2=`printf "$1" | cut -d "." -f2`
        digit3=`printf "$1" | cut -d "." -f3`
        digit4=`printf "$1" | cut -d "." -f4`
        digit5=`printf "$1" | cut -d "." -f5`
		digitnr=`awk -F. '{print NF-1}' <<<"$1"`
		if [[ $1 =~ ^[0-9.]+$ ]] && [ $size -le 15 ] && [ $digitnr -eq 3 ] && [ "$digitnr" -eq "$digitnr" ] 2>/dev/null && [ $digit1 -le 255 ] && [ "$digit1" -eq "$digit1" ] 2>/dev/null && [ $digit2 -le 255 ] && [ "$digit2" -eq "$digit2" ] 2>/dev/null && [ $digit3 -le 255 ] && [ "$digit3" -eq "$digit3" ] 2>/dev/null && [ $digit4 -le 255 ] && [ "$digit4" -eq "$digit4" ] 2>/dev/null && [ -z $digit5 ]; then
                        ipvalid=0
        else
                        ipvalid=1
         fi
        }
curTTY=`tty`
exec < $curTTY > $curTTY 2> $curTTY
clear

while [ x"$answer" != "xy" ] && [ x"$answer" != "xY" ] ; do
        clear
                while [ $validhost != 1 ] ; do
                        clear
                        printf "enter full qualified domain name: "; read host_name
                        if [[ $host_name =~ ^[0-9a-z.-]+$ ]]; then
                                validhost=1
                        else
                                printf "invalid hostname: $host_name\n"
                                sleep 3
                        fi
                done

# Doe een check of hostnaam correct is
                printf "Do you want to set a static ip or use dhcp [S]tatic / [D]hcp? "; read bootproto

if [[ $bootproto == S ]]; then
        while [ $ipok != 1 ] ; do
        clear
        printf "hostname: $host_name\n\n"
        printf "\n enter ip: "; read ip
        check_ip $ip
                if [ $ipvalid -eq 0 ]; then
                        printf "ipaddress: $ip is valid\n"
                        ipok=1
                else
                        printf "ipaddress: $ip is invalid\n"
                        sleep 5
                fi
done

while [ $nmok != 1 ] ; do
        clear
        printf "hostname: $host_name"
        printf "\nipaddress: $ip\n\n "
        printf "enter netmask: "; read netmask
        check_ip $netmask
        if [ $ipvalid -eq 0 ]; then
                printf "netmask: $netmask is valid\n"
                nmok=1
        else
                printf "netmask: $netmask is invalid\n"
                sleep 5
        fi
        done

while [ $gwok != 1 ]; do
        clear
        printf "hostname: $host_name"
        printf "\nipaddress: $ip "
        printf "\nnetmask: $netmask\n\n "
        printf "enter default gateway: "; read gw
        check_ip $gw
        if [ $ipvalid -eq 0 ]; then
                printf "gateway: $gw is valid\n"
                gwok=1
        else
                printf "gateway: $gw is invalid\n"
                sleep 5
        fi
done

#doe een check of de gw in hetzelfde subnet zit als ip ingevoerd in combinatie met het ipnummer
        clear
        printf "hostname: $host_name\n"
        printf "ipaddress: $ip\n"
        printf "netmask: $netmask\n"
        printf "gateway: $gw\n"
        printf "\nenter your first preferred dns server (default is 10.10.10.2)"; read dns1
        clear
        printf "hostname: $host_name\n"
        printf "ipaddress: $ip\n"
        printf "netmask: $netmask\n"
        printf "gateway: $gw\n"
        printf "First DNS: $dns1\n"
        printf "\nenter your second preferred dns server (no default currently set)"; read dns2
        clear
        printf "You entered:\n"
        printf "\thostname: $host_name\n"
        printf "\tip: $ip\n"
        printf "\tNetmask: $netmask\n"
        printf "\tDefault gateway: $gw\n"
        printf "\tFirst DNS: $dns1\n"
        printf "\tSecond DNS: $dns2\n"
        printf "Is this correct? [y/n] "; read answer
sed -i -e 's#^\(HOSTNAME=\).*$#\1'"$host_name"'#' /etc/sysconfig/network
        printf "GATEWAY=$gw\n" >> /etc/sysconfig/network
        printf "GATEWAY=$gw\n" > $GwFile
        printf "nameserver $dns1\n" > $DnsFile
        printf "nameserver $dns2\n" >> $DnsFile
        printf "DEVICE=$device\n" > $NetworkFile
        printf "BOOTPROTO=static\n" >> $NetworkFile
        printf "ONBOOT=yes\n" >> $NetworkFile
        printf "NM_CONTROLLED=no\n" >> $NetworkFile
        printf "HWADDR=$hwaddr\n" >> $NetworkFile
        printf "IPADDR=$ip\n" >> $NetworkFile
        printf "NETMASK=$netmask\n" >> $NetworkFile
        printf "USERCTL=no\n" >> $NetworkFile
        printf "$ip $host_name\n" >> /etc/hosts
elif [[ $bootproto == D ]]; then
		dhcp_hostname=`printf host_name | awk -F . '{ print $1 }'`
        printf "DEVICE=$device\n" > $NetworkFile
        printf "BOOTPROTO=dhcp\n" >> $NetworkFile
        printf "HWADDR=$hwaddr\n" >> $NetworkFile
        printf "USERCTL=no\n" >> $NetworkFile
        printf "DHCP_HOSTNAME=$dhcp_host_name\n" >> $NetworkFile
        printf "\tYou have chosen a DHCP setup with a hostname: $host_name\n"
        printf "\tIs this correct? [y/n] "; read answer
else
        clear
        printf "Please choose a correct choice either S or D, you choosed: $bootproto"
        sleep 15
fi
done
hostname $host_name

		
