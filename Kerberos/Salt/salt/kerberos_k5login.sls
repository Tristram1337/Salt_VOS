# /srv/salt/kerberos/kerberos_k5login.sls
# Upravuje /root/.k5login na základě "deny" a "allow" z Pillar.

{%- set k5login_data = salt['pillar.get']('kerberos:k5login', {}) %}

{%- set deny_list = [] %}
{%- set allow_list = [] %}

# Vytvoření seznamů z Pillar
{%- for kdeny, princs_deny in k5login_data.get('deny', {}).items() %}
  {%- for princ in princs_deny %}
    {%- do deny_list.append(princ) %}
  {%- endfor %}
{%- endfor %}

{%- for kallow, princs_allow in k5login_data.get('allow', {}).items() %}
  {%- for princ in princs_allow %}
    {%- do allow_list.append(princ) %}
  {%- endfor %}
{%- endfor %}

# 1) Ensure /root/.k5login exists
ensure-k5login-exists:
  file.managed:
    - name: /root/.k5login
    - user: root
    - group: root
    - mode: 0600
    - contents: ""
    - unless: test -f /root/.k5login

# 2) Smazat deny
{% for principal in deny_list %}
remove-deny-{{ principal|replace('/', '_')|replace('@','_at_') }}:
  file.replace:
    - name: /root/.k5login
    - pattern: '^{{ principal|regex_escape }}$'
    - repl: ''
    - backup: True
    - show_changes: true
    - require:
      - file: ensure-k5login-exists
{% endfor %}

# 3) Přidat allow
{% for principal in allow_list %}
add-allow-{{ principal|replace('/', '_')|replace('@','_at_') }}:
  file.append:
    - name: /root/.k5login
    - text: '{{ principal }}'
    - require:
      - file: ensure-k5login-exists
{% endfor %}
