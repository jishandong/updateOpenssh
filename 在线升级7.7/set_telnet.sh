#!/bin/bash
#########################
# by: jisd      
# at: 2018.6.14        
# in: jinan 
#########################
setenforce 0
status=`rpm -aq| grep telnet-server|wc -l`
if [ $status = 0 ]
then
    yum install telnet telnet-server xinetd -y
fi

#systemctl enable xinetd.server
systemctl enable telnet.socket

systemctl start telnet.socket
systemctl start xinetd.service
if [ -e /etc/xinetd.d/telnet ]
then
    sed -i '/disable/d' /etc/xinetd.d/telnet
    sed -i '/log_on_failure/a disable  = no' /etc/xinetd.d/telnet
fi
chkconfig xinetd on
cat /etc/pam.d/login | grep pam_securetty.so >/etc/pam_bak_2017
sed -i '/pam_securetty.so/d'  /etc/pam.d/login	
echo "#auth [user_unknown=ignore success=ok ignore=ignore default=bad] pam_securetty.so" >> /etc/pam.d/login
if [ `cat /etc/securetty |grep pts|wc -l ` -le 8 ]
then
	echo "pts/0">>/etc/securetty
	echo "pts/1">>/etc/securetty
	echo "pts/2">>/etc/securetty
	echo "pts/3">>/etc/securetty
	echo "pts/4">>/etc/securetty
	echo "pts/5">>/etc/securetty
	echo "pts/6">>/etc/securetty
	echo "pts/8">>/etc/securetty
	echo "pts/9">>/etc/securetty
	echo "pts/10">>/etc/securetty
	echo "pts/11">>/etc/securetty
	echo "pts/12">>/etc/securetty
fi

tail /var/log/secure| grep "ROOT LOGIN ON"|awk '{print $(NF-2)}'|awk '{print $1}'|sort -rn|uniq -i>> /etc/securetty
service xinetd restart
	
if [ `netstat -an | grep ":::23"|wc -l` == 1 ] || [ `netstat -an | grep "0.0.0.0:23"|wc -l` == 1 ]
then
	echo -e "\033[42;37m telnet install ok \033[0m"
else
	echo -e "\033[45;37m telnet install error \033[0m"
fi

