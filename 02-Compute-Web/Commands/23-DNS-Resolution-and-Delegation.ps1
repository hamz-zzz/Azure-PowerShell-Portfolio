C:\Users\Hamza> Resolve-DnsName windows.systemsbyhamza.com -Type A

Name                                           Type   TTL   Section    IPAddress
----                                           ----   ---   -------    ---------
windows.systemsbyhamza.com                     A      262   Answer     40.70.207.116

C:\Users\Hamza> Resolve-DnsName linux.systemsbyhamza.com -Type A

Name                                           Type   TTL   Section    IPAddress
----                                           ----   ---   -------    ---------
linux.systemsbyhamza.com                       A      300   Answer     52.247.66.223

C:\Users\Hamza> Resolve-DnsName systemsbyhamza.com -Type NS

Name                           Type   TTL   Section    NameHost
----                           ----   ---   -------    --------
systemsbyhamza.com             NS     86349 Answer     ns1-06.azure-dns.com
systemsbyhamza.com             NS     86349 Answer     ns2-06.azure-dns.net
systemsbyhamza.com             NS     86349 Answer     ns3-06.azure-dns.org
systemsbyhamza.com             NS     86349 Answer     ns4-06.azure-dns.info

C:\Users\Hamza> Resolve-DnsName systemsbyhamza.com -Type SOA

Name                        Type TTL   Section    PrimaryServer               NameAdministrator           SerialNumber
----                        ---- ---   -------    -------------               -----------------           ------------
systemsbyhamza.com          SOA  3553  Answer     ns1-06.azure-dns.com        azuredns-hostmaster.microso 1
                                                                              ft.com
systemsbyhamza.com          SOA  3553  Authority  ns1-06.azure-dns.com        azuredns-hostmaster.microso 1
                                                                              ft.com