Import-LocalizedData -BindingVariable localizedData -FileName Resources.psd1;

function Get-TargetResource {
	[OutputType([System.Collections.Hashtable])]
	param (
		[Parameter(Mandatory)] [System.String] $Hostname,
        [Parameter(Mandatory)] [System.UInt16] $Port,
		[Parameter()] [System.UInt64] $RetryIntervalSec = 30,
		[Parameter()] [System.UInt32] $RetryCount = 10
	)
	return @{
		Hostname = $Hostname;
        Port = $Port;
		RetryIntervalSec = $RetryIntervalSec;
		RetryCount = $RetryCount;
	};
} #end function Get-TargetResource

function Set-TargetResource {
    [CmdletBinding()]
    param (
		[Parameter(Mandatory)] [System.String] $Hostname,
        [Parameter(Mandatory)] [System.UInt16] $Port,
		[Parameter()] [System.UInt64] $RetryIntervalSec = 30,
		[Parameter()] [System.UInt32] $RetryCount = 10
    )
    $isDomainFound = $false;
    Write-Verbose ($localizedData.TestingHostConnection -f $Hostname, $Port);
    for ($count = 0; $count -lt $RetryCount; $count++) {
        $isPortOpen = TestTcpPort -HostName $Hostname -Port $Port;
        if ($isPortOpen) {
            break;
        }
        else {
            Write-Verbose ($localizedData.HostNotFoundRetrying -f $Hostname, $Port, $RetryIntervalSec);
            Start-Sleep -Seconds $RetryIntervalSec;
        }
    } #end foreach
    if (-not $isPortOpen) {  Write-Verbose ($localizedData.HostNotFoundRetrying -f $Hostname, $Port, $count); }
} #end function Set-TargetResource

# The Test-TargetResource function is used to validate the AD domain is available on LDAP port 389.
function Test-TargetResource {
    [CmdletBinding()]
    param (
		[Parameter(Mandatory)] [System.String] $Hostname,
        [Parameter(Mandatory)] [System.UInt16] $Port,
		[Parameter()] [System.UInt64] $RetryIntervalSec = 30,
		[Parameter()] [System.UInt32] $RetryCount = 10
    )
    Write-Verbose ($localizedData.TestingHostConnection -f $Hostname, $Port);
    return TestTcpPort -HostName $Hostname -Port 389;
} #end function Test-TargetResource

function TestTcpPort {
    <#
        .SYNOPSIS
            Checks whether the Active Directory LDAP port is available.
    #>
    param (
        [System.String] $HostName,
        [System.UInt16] $Port
    )
    $isPortOpen = $false;
    try {
        $tcpPort = New-Object -TypeName 'System.Net.Sockets.TcpClient';
        $tcpPort.Connect($Hostname, $Port);
        if ($tcpPort.Connected) {
            Write-Verbose ($localizedData.FoundHostConnection -f $HostName, $Port);
            $isPortOpen = $true;
        }
    }
    catch [System.Management.Automation.MethodInvocationException]  {
        ## Swallow 'No such host is known' errors..
        Write-Debug $_;
    }
    catch {
        throw "Test-TargetResource failed $_";
    }
    finally {
        if ($null -ne $tcpPort) { $tcpPort.Close(); }
    }
    return $isPortOpen;
}
