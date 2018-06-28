{%- from "mongodb/map.jinja" import server with context %}

{%- if server.get('enabled', False) %}

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

mongodb_setup_cluster:
  cmd.run:
  - name: 'mongo localhost:27017 /var/tmp/mongodb_cluster.js && mongo localhost:27017 --quiet --eval "rs.conf()" | grep -i object -q'
  - unless: 'mongo localhost:27017 --quiet --eval "rs.conf()" | grep -i object -q'
  - require:
    - service: mongodb_service_running
    - file: /var/tmp/mongodb_cluster.js

{%- endif %}

{%- if server.members is not defined or server.get('is_master', False) %}

{%- if server.authorization.get('enabled', False) %}
/var/tmp/mongodb_user.js:
  file.managed:
  - source: salt://mongodb/files/user.js
  - template: jinja
  - mode: 600
  - user: root

{%- if not file.file_exists('{{ server.lock_dir }}/mongodb_password_changed') %}
mongodb_change_root_password:
  cmd.run:
  - name: 'mongo localhost:27017/admin /var/tmp/mongodb_user.js && touch {{ server.lock_dir }}/mongodb_password_changed'
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - require:
    - file: /var/tmp/mongodb_user.js
    - service: mongodb_service_running
  - creates: {{ server.lock_dir }}/mongodb_password_changed
{% endif %}

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

{%- if not file.file_exists('{{ server.lock_dir }}/mongodb_user_{{ database_name }}_created') %}
mongodb_{{ database_name }}_fix_role:
  cmd.run:
  - name: 'mongo localhost:27017/admin -u admin -p {{ server.admin.password }} /var/tmp/mongodb_user_{{ database_name }}.js && touch {{ server.lock_dir }}/mongodb_user_{{ database_name }}_created'
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
{% endif %}

{%- endfor %}

{%- endif %}

{%- endif %}

{%- endif %}
