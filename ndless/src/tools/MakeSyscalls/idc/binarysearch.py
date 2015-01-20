#!/usr/bin/python2.7
# binarysearch.py
# Utility to migrate IDC files on OS upgrades
# Original author: bsl
# 
# Usage: os_from.raw os_to.raw idc_from.idc idc_to.idc
# idc_to.idc will be produced from the other files

import os
import sys
import string
import binascii
import re

phoenix = open(sys.argv[1],"rb")     # NONCAS1.7.raw or phoenix.raw
phoenixNEW = open(sys.argv[2],"rb")  # CAS1.7.raw or phoenixCAS.raw
idcfile = open(sys.argv[3],"rt")     # OS_ncas-1.7.idc or phoenix.idc
idcfilenew = open(sys.argv[4],"wt")  # OS_cas-1.7.idc   phoenixCAS.idc

oldfile = phoenix.read(0x2000000)
newfile = phoenixNEW.read(0x2000000)

while True:
  bytes = ''
  bytecount = 0
  idc = idcfile.readline()
  if len(idc) < 2 : break   # eof
  while not 'MakeName' in idc : idc = idcfile.readline()
  if "//" in idc : continue
  print idc,
  (a,b) = idc.split('(',1)
  (address,therest) = b.split(',',1)
  address = address.lower()
  while True:
   bytecount += 4
   marker = eval(address)-0x10000000
   bytes =  oldfile[marker:marker+bytecount]
   hex_string = binascii.hexlify(bytes)
# --- form the raw string ----
   hex_str = ""
   iii = 0
   while iii < len(hex_string):
    hex_str += r'\x' + hex_string[iii:iii+2] 
    iii += 2
    if iii % 8 == 0:
     if hex_str[-1] == 'A' or hex_str[-1] == 'a' or hex_str[-1] == 'B' or hex_str[-1] == 'b':
       hex_str = hex_str[0:len(hex_str)-16] + "(....)"
   #Binst   = re.compile(r'\\x..\\x..\\x..\\x.A', re.DOTALL | re.IGNORECASE )  # branch 
   #BLinst  = re.compile(r'\\x..\\x..\\x..\\x.B', re.DOTALL | re.IGNORECASE )  # branch link
   #str = BLinst.sub("(....)",hex_str,0) 
   #restr = Binst.sub("(....)",str,0) 
   restr = hex_str
   r = re.compile(restr,re.DOTALL)
   tmatch = r.search(newfile,0) 
   if tmatch: 
     indx = tmatch.start()
   else:
     indx = -1
   if bytecount >= 0x40 :   # failed to find match
     strinx = idc.find("0X")
     if strinx == -1: strinx = idc.find("0x")
     idcfilenew.write("//" + idc[0:strinx] + "0XFFFFFFFF" + idc[strinx+10:-1] + ":" + hex(0x10000000+indx) + ":" + hex(0x10000000+indx2) + "\n")
     break
   if indx >= 0:
    tmatch = r.search(newfile,indx + 1) 
    if tmatch: 
     indx2 = tmatch.start()
    else:
     indx2 = -1    
    if indx2 <0 and bytecount >= 12:     # found unique match and long enough(3 instructions)
     strinx = idc.find("0X")
     if strinx == -1: strinx = idc.find("0x")
     print idc[0:strinx] + hex(0x10000000+indx) + idc[strinx+10:]
     idcfilenew.write(idc[0:strinx] + hex(0x10000000+indx) + idc[strinx+10:])
     break
   
idcfile.close()
idcfilenew.close()
phoenix.close()
phoenixNEW.close()
