Included Resources
==================
* cWaitForTcpPort

cWaitForTcpPort
================
Waits for the availability of a TCP port on a host to become available before continuing.

###Syntax
```
cWaitForTcpPort [string]
{
    Hostname = [string]
    Port = [uint16]
    [RetryIntervalSec = [uint64]]
    [RetryCount = [uint32]]
}
```
###Properties
* Hostname: IP address, FQDN or NetBIOS name of the host to wait for.
* Port: TCP port number on the host to wait for.
* RetryIntervalSec: Number of seconds to wait before retrying the connection. If unspecified, this value defaults to 30 seconds.
* RetryCount: Number of rety attempts before giving up. If unspecified, this value defaults to 10 retries.

###Configuration
```
Configuration cWaitForLDAPDomainExample {
    Import-DscResource -ModuleName cWaitForTcpPort
    cWaitForTcpPort WaitForMyExampleDomain {
        Hostname = 'myFQDNdomain.local'
        Port = 389
        RetryIntervalSec = 30
        RetryCount = 10
    }
}
```
