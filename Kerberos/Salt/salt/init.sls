# salt://kerberos/init.sls

include:
  - kerberos.kerberos_config
  - kerberos.kerberos_k5login
#  - kerberos.kerberos_keytab
