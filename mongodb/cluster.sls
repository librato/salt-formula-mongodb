{%- from "mongodb/map.jinja" import server, config with context %}

mongodb_service_running:
  service.running:
  - name: {{ server.service }}
  - enable: true
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}

{%- if server.members is defined and server.get('is_master', False) %}

/var/tmp/mongodb_cluster.js:
  file.managed:
  - source: salt://mongodb/files/cluster.js
  - template: jinja
  - mode: 600
  - user: root
  - require:
    - service: mongodb_service_running

{%- if not salt['file'].file_exists('{{ server.lock_dir }}/mongodb_cluster_setup') %}
mongodb_setup_cluster:
  cmd.run:
  - name: 'mongo localhost:{{ config.net.port }} /var/tmp/mongodb_cluster.js && mongo localhost:{{ config.net.port }} --quiet --eval "rs.conf()" | grep -i object -q'
  - unless: 'mongo localhost:{{ config.net.port }} --quiet --eval "rs.conf()" | grep -i object -q'
  - require:
    - service: mongodb_service_running
    - file: /var/tmp/mongodb_cluster.js
  - creates: {{ server.lock_dir }}/mongodb_cluster_setup
{%- endif %}

{%- endif %}

{%- if config.security.get('authorization', 'disabled') == 'enabled' %}

{%- for database_name, database in server.get('database', {}).iteritems() %}

/var/tmp/mongodb_user_{{ database_name }}.js:
  file.managed:
  - source: salt://mongodb/files/user_role.js
  - template: jinja
  - mode: 600
  - user: root
  - defaults:
      database_name: {{ database_name }}
      database_defs: {{ database }}

mongodb_{{ database_name }}_fix_role:
  cmd.run:
  - name: 'mongo localhost:{{ config.net.port }} /var/tmp/mongodb_user_{{ database_name }}.js && touch {{ server.lock_dir }}/mongodb_user_{{ database_name }}_created'
  - unless: 'stat {{ server.lock_dir }}/mongodb_user_{{ database_name }}_created > /dev/null 2>&1'
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - require:
    - file: /var/tmp/mongodb_user_{{ database_name }}.js
    - service: mongodb_service_running
  - creates: {{ server.lock_dir }}/mongodb_user_{{ database_name }}_created
  {%- if server.members is defined %}
  require:
    - cmd: mongodb_setup_cluster
  {%- endif %}

{%- endfor %}

{%- endif %}
