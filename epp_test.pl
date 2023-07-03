#!/usr/bin/perl

# $Id: epp_test.pl 2023-05-19 06:10:47Z elp $
# $Author: DDNvR -#Cyberops... 

# Epp-ZACR-Connect
#This perl file is a combination of command line soap xml objects using the epp / srs protocl 
#for testing and or live system testing for the ZACR registry system. It will display the greeting and grant access 
#- it will check for a domain - and also check if there are any messages from the registry for the account 
#- it will create a new contact and a new domain 
#- this is all done automatically so no need to modify the code except for the hostname and port. 
#-make sure you have a ote account with ZACR first before testing

## Install recommendation

#TO USE --- PLEASE INSTALL --- on ubuntu ---
#root@localhost >>> perl -v
#root@localhost >>> sudo apt install perl
#root@localhost >>> sudo apt install libnet-epp-perl

## Usage Case
#root@localhost >>> perl epp_test.pl
#################################################
use Net::EPP::Client;
use strict;
use warnings;
use Term::ANSIColor;

#---------------------------------------
#settings
my $hostname = 'ote.zarc.net.za'; #epp.zarc.net.za
my $port = '700'; #3121 or 700

#---------------------------------------
#display help or start script
system qq(clear);
print <<_EOM;
SRS EPP connection client tester.
Author: DDNvR #Cyberops
_EOM
print colored( '=====================================', 'red' ), "\n";
print colored( 'CONNECTED:: '.$hostname.':'.$port.'', 'red' ), "\n";
print colored( 'STATUS:: RUNNING TESTS...please wait', 'red' ), "\n";
print colored( '=====================================', 'red' ), "\n\n";

#---------------------------------------
#connection settings for system
##Server Certificate Verification
my $epp = Net::EPP::Client->new(
        host    => $hostname,
        port    => $port,
#        host    => 'epp.coza.net.za',
#        port    => 3121,
        verify  => 1,
        ssl     => 1,
        frames  => 1,
        ca_file => './ssl/epp.crt',
        ca_path => './ssl/',
);

#functions
my $contactid = int(rand(10000000));
my @set = ('a' .. 'z');#use alphabet
my $domainname = join '' => map $set[rand @set], 1 .. 8; #random name generater

#---------------------------------------
##Soap Objects Functions 
#LOGIN SECTION 
my $loginframe = '<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
   <command>
      <login>
         <clID>yourusername</clID>
         <pw>yourpassword</pw>
         <options>
            <version>1.0</version>
            <lang>en</lang>
         </options>
         <svcs>
            <objURI>urn:ietf:params:xml:ns:domain-1.0</objURI>
            <objURI>urn:ietf:params:xml:ns:contact-1.0</objURI>
         </svcs>
      </login>
      <clTRID>DDNvR-'.int(rand(10000000)).'</clTRID>
   </command>
</epp>';

#check a domain
my $checkdomainframe = '<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <check>
      <domain:check xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>domainalreadycreated.co.za</domain:name>
      </domain:check>
    </check>
    <clTRID>DDNvR-'.int(rand(10000000)).'</clTRID>
  </command>
</epp>';


#poll frame ask registry fro message
my $pollframe = '<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <poll op="ack" msgID="FMS-EPP-12A18BE965E-6D25E"/>
    <clTRID>DDNvR-'.int(rand(10000000)).'</clTRID>
  </command>
</epp>';


#poll ack frame ask registry fro message
my $pollackframe = '<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <poll op="req"/>
    <clTRID>DDNvR-'.int(rand(10000000)).'</clTRID>
  </command>
</epp>';


#create a contact on registry
my $createcontactframe = '<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
  <command>
    <create>
      <contact:create xmlns:contact="urn:ietf:params:xml:ns:contact-1.0" xsi:schemaLocation="urn:ietf:params:xml:ns:contact-1.0 contact-1.0.xsd">
        <contact:id>'.$contactid.'</contact:id>
        <contact:postalInfo type="loc">
          <contact:name>I was here</contact:name>
          <contact:addr>
            <contact:street>1 Registrant-Heights</contact:street>
            <contact:street>2 Registrant Avenue</contact:street>
            <contact:city>Registrant Ville</contact:city>
            <contact:pc>90210</contact:pc>
            <contact:cc>ZA</contact:cc>
          </contact:addr>
        </contact:postalInfo>
        <contact:voice>+27.125551234</contact:voice>
        <contact:fax x="01">+86.5551234</contact:fax>
        <contact:email>a_registrant@tester.co.za</contact:email>
        <contact:authInfo>
          <contact:pw>'.$domainname.'</contact:pw>
        </contact:authInfo>
      </contact:create>
    </create>
    <clTRID>DDNvR-'.int(rand(10000000)).'</clTRID>
  </command>
</epp>';


#create a domain on registry
my $createdomainframe = '<epp:epp xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:epp="urn:ietf:params:xml:ns:epp-1.0" xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
  <epp:command>
    <epp:create>
      <domain:create xmlns:domain="urn:ietf:params:xml:ns:domain-1.0" xsi:schemaLocation="urn:ietf:params:xml:ns:domain-1.0 domain-1.0.xsd">
        <domain:name>testdomain-'.$domainname.'.co.za</domain:name>
        <domain:period unit="y">1</domain:period>
        <domain:ns>
            <domain:hostAttr>
                <domain:hostName>ns1.exampledomain.test.dnservices.co.za</domain:hostName>
            </domain:hostAttr>
            <domain:hostAttr>
                <domain:hostName>ns2.exampledomain.test.dnservices.co.za</domain:hostName>
            </domain:hostAttr>
        </domain:ns>
        <domain:registrant>'.$contactid.'</domain:registrant>
        <domain:contact type="admin">'.$contactid.'</domain:contact>
        <domain:contact type="tech">'.$contactid.'</domain:contact>
        <domain:contact type="billing">'.$contactid.'</domain:contact>
        <domain:contact type="reseller">'.$contactid.'</domain:contact>
        <domain:authInfo>
          <domain:pw>coza</domain:pw>
        </domain:authInfo>
      </domain:create>
        </epp:create>
  </epp:command>
</epp:epp>';


##eof functions
#---------------------------------------
##Start Script
#---------------------------------------
my $greeting = $epp->connect;
#send the login to srs server
$epp->send_frame($loginframe );
my $loginfr = $epp->get_frame;
#send the check domain 
$epp->send_frame($checkdomainframe );
my $checkdomafr = $epp->get_frame;
#poll message from registry
$epp->send_frame($pollframe);
my $pollfr = $epp->get_frame;
#poll ack message from registry
$epp->send_frame($pollackframe);
my $pollackfr = $epp->get_frame;
#create contact object
$epp->send_frame($createcontactframe);
my $contactfr = $epp->get_frame;
#create domain object
$epp->send_frame($createdomainframe);
my $domainfr = $epp->get_frame;


#---------------------------------------
#send output to terminal
print "\n\n$epp\n";
print colored( 'TEST:: Received Greeting From SRS EPP Server', 'green' ), "\n\n";
print colored( '=====================================', 'green' ), "\n\n";
print "$greeting\n\n"; #greeting
print colored( 'TEST:: Send Login Access', 'green' ), "\n\n";
print colored( '=====================================', 'green' ), "\n\n";
print "$loginfr\n\n"; #login
print colored( 'TEST:: Check Domain', 'green' ), "\n\n";
print colored( '=====================================', 'green' ), "\n\n";
print "$checkdomafr\n\n"; #login
print colored( 'TEST:: Send Check for total messages', 'green' ), "\n\n";
print colored( '=====================================', 'green' ), "\n\n";
print "$pollfr\n\n"; #show how many message from registry
print colored( 'TEST:: Send request for Display messages', 'green' ), "\n\n";
print colored( '=====================================', 'green' ), "\n\n";
print "$pollackfr\n\n"; #show messages from registry
print colored( 'TEST:: Send request for Create a contact object', 'green' ), "\n\n";
print colored( '=====================================', 'green' ), "\n\n";
print "$contactfr\n\n"; #create contact
print colored( 'TEST:: Send request for Create a domain object', 'green' ), "\n\n";
print "Domain Name: testdomain-$domainname.co.za\n\n";
print colored( '=====================================', 'green' ), "\n\n";
print "$domainfr\n\n"; #create domain
print colored( '=====================================', 'red' ), "\n\n";
print colored( 'ALL TESTS COMPLETED...... ', 'red' ), "\n\n";
