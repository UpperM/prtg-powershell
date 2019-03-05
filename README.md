# PRTG-PowerShell
PowerShell script to add device to PRTG from a CSV files

Introduction

This script use "PrtgAPI" https://github.com/lordmilko/PrtgAPI

    .SYNOPSIS
        Name: New-PRTGDevice.ps1
        Adding device to PRTG
        
    .DESCRIPTION
        Adding device to PRTG from a CSV file

    .PARAMETER PRTGServer
        The adress of your PRTG server
    
    .PARAMETER CsvPath
        The full path of your CSV file

    .NOTES
        Release Date: 2019-03-05
    
        Author: Matthieu Courtois

    .EXAMPLE
        Run the Get-Example script to add a device 
        New-PRTGDevice -PRTGServer 10.0.0.1 -CsvPath C:\PRTG_Devices.csv
