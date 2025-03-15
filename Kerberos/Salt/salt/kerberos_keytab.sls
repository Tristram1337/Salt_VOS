# salt://kerberos/kerberos_keytab.sls
# Spravuje /etc/krb5.keytab

{%- set default_source = "salt://kerberos/files/keytabs/{}/krb5.keytab".format(grains['fqdn']) %}
{%- set keytab_source = salt['pillar.get']('kerberos:keytab_source', default_source) %}

manage-krb5-keytab:
  file.managed:
    - name: /etc/krb5.keytab
    - source: {{ keytab_source }}
    - user: root
    - group: root
    - mode: 0600
    - show_changes: true
    - backup: false
    - require:
      - pkg: install-kerberos-packages
