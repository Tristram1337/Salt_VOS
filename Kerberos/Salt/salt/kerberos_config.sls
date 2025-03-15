# /srv/salt/kerberos/kerberos_config.sls
# Spravuje /etc/krb5.conf (bez suffixu – jedna univerzální verze).

install-kerberos-packages:
  pkg.installed:
    - names:
      - krb5-config
      - krb5-doc
      - krb5-user
      - libgssapi-krb5-2
      - libkrb5-3
      - libkrb5support0
      - libpam-krb5

manage-krb5-conf:
  file.managed:
    - name: /etc/krb5.conf
    - source: salt://kerberos/files/krb5.conf
    - user: root
    - group: root
    - mode: 0644
    - show_changes: true
