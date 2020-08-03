@echo off 
cls 
ECHO connecting over TCP/IP 
 
REM load packet driver at interrupt vector 0x60 
3C509 0x60 
 
REM set network information in environment variables as parameters for trumpet 
 
set IP=192.168.1.5 
set GATEWAY=192.168.1.1 
set NETMASK=255.255.255.0 
set DOMAIN=  
set DNS=192.168.1.1 
  

ECHO load Trumpet TCP/IP stack 
tcpdrv 
  

ECHO testing network with ping
ping 192.168.1.3
 
ECHO if ping was successful, you're on 