# cWaitForADDomain
By default, the [MSFT_xWaitForADDomain](https://gallery.technet.microsoft.com/scriptcenter/xActiveDirectory-f2d573f3) resource
has to be run on a machine with the Active Directory Remote Server Administration Tools (RSAT) installed. This resource can be
run on a domain member - without RSAT - and will wait until the AD domain LDAP port 389 becomes available. This is great for
AD domain setup in a lab build!

cWaitForADDomain resource has following properties:

* DomainName: Active Directory FQDN to wait for.
* RetryIntervalSec: Number of seconds between retries.
* RetryCount: Maximum number of attempts to retry.
