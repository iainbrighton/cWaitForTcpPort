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
    if (-not $isPortOpen) {
        ThrowOperationCanceledException -ErrorId 'OperationTimeout' -ErrorMessage $localizedData.HostNotFoundTimeout;
    }
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
    return (TestTcpPort -HostName $Hostname -Port $Port);
} #end function Test-TargetResource

#region Private Functions

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
    finally {
        if ($null -ne $tcpPort) { $tcpPort.Close(); }
    }
    return $isPortOpen;
} #end function TestTcpPort

function ThrowOperationCanceledException {
    <#
    .SYNOPSIS
        Throws terminating error of category InvalidOperation with specified errorId and errorMessage.
    #>
    param(
        [Parameter(Mandatory)] [System.String] $ErrorId,
        [Parameter(Mandatory)] [System.String] $ErrorMessage
    )
    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidOperation;
    $exception = New-Object -TypeName 'System.OperationCanceledException' -ArgumentList $ErrorMessage;
    $errorRecord = New-Object -TypeName 'System.Management.Automation.ErrorRecord' -ArgumentList $exception, $ErrorId, $errorCategory, $null;
    throw $errorRecord;
} #end function ThrowOperationCanceledException

#endregion Private Functions
