{%- from "mongodb/map.jinja" import server with context %}

{%- if server.get('enabled', False) %}

{%- if grains['os_family'] == 'Debian' %}

{%- set os   = salt['grains.get']('os') | lower() %}
{%- set code = salt['grains.get']('oscodename') %}
mongodb_repo:
  pkgrepo.managed:
    - humanname: MongoDB.org Repository
    - name: deb http://repo.mongodb.org/apt/{{ os }} {{ code }}/mongodb-org/{{ server.version }} {{ server.repo_component }}
    - file: /etc/apt/sources.list.d/mongodb-org.list
    - keyid: {{ server.keyid }}
    - keyserver: keyserver.ubuntu.com

{%- elif grains['os_family'] == 'RedHat' %}

mongodb_repo:
  pkgrepo.managed:
    {%- if server.version == 'stable' %}
    - name: mongodb-org
    - humanname: MongoDB.org Repository
    - gpgkey: https://www.mongodb.org/static/pgp/server-3.2.asc
    - baseurl: https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/{{ server.version }}/$basearch/
    - gpgcheck: 1
    {%- elif server.version == 'oldstable' %}
    - name: mongodb-org-{{ server.version }}
    - humanname: MongoDB oldstable Repository
    - baseurl: http://downloads-distro.mongodb.org/repo/redhat/os/$basearch/
    - gpgcheck: 0
    {%- else %}
    - name: mongodb-org-{{ server.version }}
    - humanname: MongoDB {{ server.version | capitalize() }} Repository
    - gpgkey: https://www.mongodb.org/static/pgp/server-{{ server.version }}.asc
    - baseurl: https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/{{ server.version }}/$basearch/
    - gpgcheck: 1
    {%- endif %}
    - disabled: 0
  {%- endif %}

{%- endif %}

mongodb_packages:
  pkg.installed:
  - names: {{ server.pkgs }}

/etc/mongodb.conf:
  file.managed:
  - source: salt://mongodb/files/mongodb.conf
  - template: jinja
  - require:
    - pkg: mongodb_packages

{%- if server.shared_key is defined %}
/etc/mongodb.key:
  file.managed:
  - contents_pillar: mongodb:server:shared_key
  - mode: 600
  - user: mongodb
  - require:
    - pkg: mongodb_packages
  - watch_in:
    - service: mongodb_service
{%- endif %}

{{ server.data_dir }}:
  file.directory:
    - user: mongodb
    - group: mongodb
    - mode: 770
    - makedirs: true

{{ server.lock_dir }}:
  file.directory:
    - user: mongodb
    - group: mongodb
    - mode: 777
    - makedirs: true

{{ server.logging.log_dir }}:
  file.directory:
    - user: mongodb
    - group: mongodb
    - mode: 775
    - makedirs: true

mongodb_service:
  service.running:
  - name: {{ server.service }}
  - enable: true
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - require:
    - file: {{ server.lock_dir }}
    - pkg: mongodb_packages
  - watch:
    - file: /etc/mongodb.conf

{%- endif %}
