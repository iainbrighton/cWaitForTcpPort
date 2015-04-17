$here = Split-Path -Parent $MyInvocation.MyCommand.Path;
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".");
. "$here\$sut";

Describe 'cWaitForTcpPort\Get-TargetResource' {
    $resourceParams = @{
        Hostname = '127.0.0.1';
        Port = 135;
    }

    It 'returns a System.Collections.Hashtable type.' {
        $targetResource = Get-TargetResource @resourceParams;
        $targetResource -is [System.Collections.Hashtable] | Should Be $true;
    }
    
    It 'defaults to 10 retries with a 30 second retry timeout.' {
        $targetResource = Get-TargetResource @resourceParams;
        $targetResource.RetryIntervalSec | Should Be 30;
        $targetResource.RetryCount | Should Be 10;
    }

} #end describe cWaitForTcpPort\Get-TargetResource

Describe 'cWaitForTcpPort\Test-TargetResource' {
    $resourceParams = @{
        Hostname = '127.0.0.1';
        Port = 135;
    }
    
    It 'returns a System.Boolean type.' {
       # Mock -CommandName TestTcpPort -MockWith { return $true; }
        $targetResource = Test-TargetResource @resourceParams;
        $targetResource -is [System.Boolean] | Should Be $true;
    }

    It 'returns false when host and port are are available' {
        $targetResource = Test-TargetResource @resourceParams;
        $targetResource | Should Be $false;
    }

    It 'returns true when host and port are not available' {
        $resourceParams['Hostname'] = 'MyRandomHost';
        $targetResource = Test-TargetResource @resourceParams;
        $targetResource | Should Be $true;
    }

} #end describe cWaitForTcpPort\Test-TargetResource

Describe 'cWaitForTcpPort\Set-TargetResource' {

    It 'waits for an existing available port.' {
        $resourceParams = @{
            Hostname = '127.0.0.1';
            Port = 135;
        }
        { Set-TargetResource @resourceParams } | Should Not Throw;
    }

    It 'throws on timeout for an unavailable port.' {
        $resourceParams = @{
            Hostname = 'MyRandomHost';
            Port = 135;
            RetryIntervalSec = 1;
            RetryCount = 1;
        }
        { Set-TargetResource @resourceParams } | Should Throw;
    }
}