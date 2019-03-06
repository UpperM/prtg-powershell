## PRTG-PowerShell

PowerShell script to add device to PRTG from a CSV files

# Requirements 
PrtgAPI https://github.com/lordmilko/PrtgAPI
SNMP https://www.powershellgallery.com/packages/SNMP/1.0.0.1

## Description

    .SYNOPSIS
        Name: New-PRTGDevice.ps1
        Adding device to PRTG
        
    .DESCRIPTION
        Adding device to PRTG from a CSV file
    
    .LINK
        https://github.com/UpperM/prtg-powershell/

    .PARAMETER PRTGServer
        The adress of your PRTG server
    
    .PARAMETER CsvPath
        The full path of your CSV file

    .PARAMETER SNMPCommunity
        The SNMP community configured on your devices

    .NOTES
        Release Date: 2019-03-05
    
        Author: Matthieu Courtois

    .EXAMPLE
        Run the Get-Example script to add a device 
        New-PRTGDevice -PRTGServer 10.0.0.1 -CsvPath C:\PRTG_Devices.csv -SNMPCommunity MySNMP

    .NOTES
        This script require somes modules :
            - PrtgApi https://github.com/lordmilko/PrtgAPI
            - SNMP https://www.powershellgallery.com/packages/SNMP/1.0.0.1


