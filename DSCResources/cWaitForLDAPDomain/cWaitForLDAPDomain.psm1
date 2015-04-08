# The Get-TargetResource function is used to fetch the status of AD domain.
function Get-TargetResource {
	[OutputType([System.Collections.Hashtable])]
	param (
		[Parameter(Mandatory)] [System.String] $DomainName,
		[Parameter()] [System.UInt64] $RetryIntervalSec = 30,
		[Parameter()] [System.UInt32] $RetryCount = 10
	)
	return @{
		DomainName = $DomainName;
		RetryIntervalSec = $RetryIntervalSec;
		RetryCount = $RetryCount;
	};
} #end function Get-TargetResource

# The Set-TargetResource function is used to wait until the AD domain is available on LDAP port 389.
function Set-TargetResource {
    [CmdletBinding()]
    param (
		[Parameter(Mandatory)] [System.String] $DomainName,
		[Parameter()] [System.UInt64] $RetryIntervalSec = 30,
		[Parameter()] [System.UInt32] $RetryCount = 10
    )
    $isDomainFound = $false;
    Write-Verbose -Message "Checking for domain '$DomainName' ...";
    for ($count = 0; $count -lt $RetryCount; $count++) {
        $isDomainFound = TestTcpPort -HostName $DomainName -Port 389;
        if ($isDomainFound) {
            break;
        }
        else {
            Write-Verbose -Message "Domain '$DomainName' not found. Will retry again after $RetryIntervalSec sec";
            Start-Sleep -Seconds $RetryIntervalSec;
        }
    } #end foreach
    if (-not $isDomainFound) { Write-Verbose "Domain '$DomainName' not found after $count attempts with $RetryIntervalSec sec interval"; }
    return $isDomainFound;
} #end function Set-TargetResource

# The Test-TargetResource function is used to validate the AD domain is available on LDAP port 389.
function Test-TargetResource {
    [CmdletBinding()]
    param (
		[Parameter(Mandatory)] [System.String] $DomainName,
		[Parameter()] [System.UInt64] $RetryIntervalSec = 30,
		[Parameter()] [System.UInt32] $RetryCount = 10
    )
    Write-Verbose -Message "Checking for domain '$DomainName' ...";
    return TestTcpPort -HostName $DomainName -Port 389;
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
        $tcpPort.Connect($DomainName, $Port);
        if ($tcpPort.Connected) {
            Write-Verbose -Message "Found hostname '$HostName' listening on port '$Port'";
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

Export-ModuleMember -Function *-TargetResource;
