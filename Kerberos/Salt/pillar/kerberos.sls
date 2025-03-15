kerberos:
  # 1) Volba suffixu pro krb5.conf ("" / "_einfra" / "_noaddresses"):
  #krb5_conf_suffix: ""

  # 2) Definice k5login -> deny/allow
  k5login:
    deny:
      any:
        - "rohovsky@ZCU.CZ"
    allow:
      "any.!(group_bacula_server|group_bacula_secondary)": []
      "any":
        - "rohovsky/root@ZCU.CZ"

  # 3) Keytab - odkud se bude stahovat
  #    Tady použijeme grains['fqdn'], nechť to je něco jako 'myhost.zcu.cz'.
  #keytab_source: "salt://kerberos/files/keytabs/{{ grains['fqdn'] }}/krb5.keytab"
