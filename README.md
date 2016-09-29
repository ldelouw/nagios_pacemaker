nagios_pacemaker
================

Icinga/Nagios-Script for Pacemaker/Corosync

Installation
============

Copy the Script to your Nagios-Plugin Directory. Set executable bit and allow the Nagios-User to execute the PCS Command via sudo. While the CRM Shell is available on Suse, PCS is used for RHEL. This current version is using PCS only (at the moment)

Usage
=====

Usage: $PROGNAME [action]
    
    Actions:
             
             maintenance: Checks if maintenance property is set to true

             standby    : Checks if one more more nodes are on Standby
             
             move       : Checks if there are manually moved resources

	     offline    : Checks if there are Offline nodes
             
             failed     : Checks if there are failed actions
             
             inactive   : Checks if there are inactive resources
