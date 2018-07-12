{%- from "mongodb/map.jinja" import server, config with context %}

{%- if config.security.get('authorization', 'disabled') == 'enabled' %}

/var/tmp/mongodb_users.js:
  file.managed:
  - source: salt://mongodb/files/user_role.js
  - template: jinja
  - mode: 600
  - user: root
  - defaults:
      database: {{ server.get('database', {}) }}

mongodb_fix_role:
  cmd.run:
  - name: 'mongo localhost:{{ config.net.port }} /var/tmp/mongodb_users.js && touch {{ server.lock_dir }}/mongodb_users_created'
  - unless: 'stat {{ server.lock_dir }}/mongodb_users_created > /dev/null 2>&1'
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - require:
    - file: /var/tmp/mongodb_users.js
    - service: mongodb_service_running
  - creates: {{ server.lock_dir }}/mongodb_users_created
  {%- if server.members is defined %}
  require:
    - cmd: mongodb_setup_cluster
  {%- endif %}

{%- endif %}
