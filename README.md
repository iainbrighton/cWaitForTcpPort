Included Resources
==================
* cWaitForLDAPDomain

cWaitForLDAPDomain
================
By default, the [MSFT_xWaitForADDomain](https://gallery.technet.microsoft.com/scriptcenter/xActiveDirectory-f2d573f3) resource
has to be run on a machine with the Active Directory Remote Server Administration Tools (RSAT) installed. This resource can be
run on a domain member - without RSAT - and will wait until the AD domain LDAP port 389 becomes available. This is great for member server deployment in a lab build!
###Syntax
```
cWaitForLDAPDomain [string]
{
    DomainName = [string]
    [RetryIntervalSec = [int]]
    [RetryCount = [int]]
```
The DomainName property can be the Active Directory's FQDN, a domain controller's FQDN or the IP address of a domain controller.

The defaults are set to retry every 30 seconds with a maximum retry count of 10 - totalling 5 minutes.

###Configuration
```
Configuration cWaitForLDAPDomainExample {
    Import-DscResource -ModuleName cWaitForLDAPDomain
    cWaitForLDAPDomain MyExampleDomain {
        DomainName = 'myFQDNdomain.local'
        RetryIntervalSec = 30
        RetryCount = 10
    }
}
```
