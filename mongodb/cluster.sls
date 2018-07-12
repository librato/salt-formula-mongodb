{%- from "mongodb/map.jinja" import server, config with context %}

mongodb_service_running:
  service.running:
  - name: {{ server.service }}
  - enable: true
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}

{%- if server.members is defined %}

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
  - name: 'mongo localhost:{{ config.net.port }} /var/tmp/mongodb_cluster.js && mongo localhost:{{ config.net.port }} --quiet --eval "rs.status()" | grep -i members -q'
  - unless: 'stat {{ server.lock_dir }}/mongodb_cluster_setup > /dev/null 2>&1'
  - require:
    - service: mongodb_service_running
    - file: /var/tmp/mongodb_cluster.js
  - creates: {{ server.lock_dir }}/mongodb_cluster_setup

{%- endif %}
