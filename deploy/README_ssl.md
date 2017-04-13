Autolab
------

keys.sh is a bash file which creates a local Root Authority. It makes
certificates for Main Server, Execution Nodes and Load Balancer, which
are signed by the Root Authority.

The OpenSSL CONF library can be used to read configuration files. It is
used for the OpenSSL master configuration file openssl.cnf and in a few
other places like SPKAC files and certificate extension files for the x509 utility.

For more information on conf file refer https://www.openssl.org/docs/man1.0.2/apps/config.html

The organizational information of the certificates can be changed by modifying _keys.conf_.
The cryptographic requirements of the certificates can be changed by modifying _openssl.conf_.    

To generate the certificates, execute the following command.
```shell
$bash keys.sh
```
