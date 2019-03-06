<#
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
#>

param(
    [System.String]$PRTGServer      = "10.0.0.1",
    [System.String]$CsvPath         = "C:\PRTG_Devices.csv",
    [System.String]$SNMPCommunity   = "MySNMP"
)

Function Test-Data {
    param(
        [System.String]$DeviceName,
        [System.String]$PRTGTemplate,
        [System.String]$PRTGGroup
    )
    $Validation         = $True
    $GetPRTGTemplate    = (Get-DeviceTemplate).Name
    $GetPRTGGroups      = (Get-Group).Name

    if($GetPRTGTemplate -notcontains $PRTGTemplate) {
        Write-Warning "The template $PRTGTemplate does not exist on PRTG"
        Write-Host "List of available template :"
        $GetPRTGTemplate | ForEach-Object {Write-Host $_}
    }

    if (!$PRTGGroup) {
        Write-Error -Message "You need to specify a group"
        $Validation = $false   
    } elseif ($GetPRTGGroups -notcontains $PRTGGroup) {
        Write-Warning "The group $PRTGGroup does not exist on PRTG"
        $Validation = $false
    }

    Return $Validation
}

if(!(Test-Path $CsvPath)) {
    Write-Error -Message "The CSV file path is incorrect" -Category InvalidArgument
    exit
}

if ($Null -eq (Get-PrtgClient)) {
    try {
        Write-Output "Connection to the PRTG Server ..."
        $PRTGCredentials = Get-Credential
        Connect-PrtgServer -Server $PRTGServer -IgnoreSSL -Credential $PRTGCredentials
    }
    catch {
        Write-Error -Message "An error occurred while connecting to the PRTG server ($PRTGServer)"
        exit
    }
}

foreach ($i in Import-Csv -Path $CsvPath -Delimiter (';')) {

    $DeviceName     = $i.DeviceName
    $PRTGGroup      = $i.PRTGGroup
    $PRTGTemplate   = $i.PRTGTemplate
    $IPAddress      = $i.IPAddress
    
    if (Test-Data -DeviceName $DeviceName -PRTGTemplate $PRTGTemplate -PRTGGroup $PRTGGroup) {     

        Write-Output "The following device will be added with the following parameters :
         Hostname   : $DeviceName 
         IP Address : $IPAddress
         Group      : $PRTGGroup
         Template   : $PRTGTemplate
         "

        $PRTGGroup      = Get-Group -Name $PRTGGroup
        $PRTGTemplate   = Get-DeviceTemplate -Name $PRTGTemplate

        $Params = @{
            Destination = $PRTGGroup 
            Name = $DeviceName 
            Host = $IPAddress 
        }


        if ($Null -ne $PRTGTemplate) {
            
            $SNMPTest = Get-SnmpData -IP $IPAddress -Community $SNMPCommunity -OID .1.3.6.1.2.1.1.1.0 -WarningAction SilentlyContinue

            if ($SNMPTest) {
                Write-Host "Adding template to parameters"
                $Params.Add('Template',$PRTGTemplate)
                $Params.Add('AutoDiscover',$True)
            } else {
                Write-Warning "The SNMP is not configured on the device $DeviceName"
            }
           
        }
        
        try {
            # Create the device
            Write-Host "Adding device $DeviceName to PRTG ..."
            $Device = Add-Device @Params
        }
        catch {
            Write-Error -Message "An error occurred while adding  the device $DeviceName"
            exit
        }
                
        $DeviceId = $Device.Id     
        
        # Wait unitl the auto-discovery is not finish
        while (((Get-Device -Id $DeviceId).Condition).Count -ne 0) {
            (Get-Device -Id $DeviceId).Condition
            Start-Sleep -Seconds 5
        }
        
        # Rename the device after the auto-discovery to avoid FQDN
        Get-Device -Id $DeviceId | Rename-Object -Name $DeviceName
        
        # There is an example to rename a sensor
        # Get-Device -id $DeviceId | Get-Sensor | Where-Object {$_.Name -like "*Disk Free: C:\*"} | Rename-Object -Name "Disk Free (OS)"
        # Get-Device -id $DeviceId | Get-Sensor | Where-Object {$_.Name -like "Disk Free: *:\* Label*"} | Rename-Object -Name "Disk Free (Data)"

        
        Write-Output "The device $DeviceName has been added successfully"
    }
}
