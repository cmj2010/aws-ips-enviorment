Content-Type: multipart/mixed; boundary="===============0086047718136476635=="
MIME-Version: 1.0

--===============0086047718136476635==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="config"

config system global
set hostname ${fgt_id}
set admintimeout 30
end

config router static
edit 1
set gateway 10.0.1.1
set device port1
end

config system interface
edit "port1"
set mode static
set ip ${port1} 255.255.255.0
set allowaccess ping https ssh fgfm
next
edit "port2"
set mode static
set ip ${port2} 255.255.255.0
set allowaccess ping https ssh fgfm
next
end


config firewall vip
edit "vip-8009"
set extintf "port1"
set portforward enable
set mappedip "${ubuntuip}"
set extport 8009
set mappedport 8009
next
edit "vip-8080"
set extintf "port1"
set portforward enable
set mappedip "${ubuntuip}"
set extport 8080
set mappedport 8080
next
edit "vip-2222"
set extintf "port1"
set portforward enable
set mappedip "${ubuntuip}"
set extport 2222
set mappedport 22
next
end

config firewall policy
edit 1
set name "vpc-internet_access"
set srcintf "port2"
set dstintf "port1"
set srcaddr "all"
set dstaddr "all"
set action accept
set schedule "always"
set service "ALL"
set utm-status enable
set logtraffic all
set av-profile "default"
set webfilter-profile "default"
set ips-sensor "default"
set application-list "default"
set ssl-ssh-profile "certificate-inspection"
set nat enable
next

edit 2
set name "internet_access_server"
set srcintf "port1"
set dstintf "port2"
set srcaddr "all"
set dstaddr "vip-8009" "vip-2222"
set action accept
set schedule "always"
set service "ALL"
set utm-status enable
set logtraffic all
set ips-sensor "default"
set ssl-ssh-profile "certificate-inspection"
next
end



--===============0086047718136476635==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="license"

${fgt_byol_license}

--===============0086047718136476635==--