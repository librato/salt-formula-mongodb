{%- from "mongodb/map.jinja" import server with context -%}

{%- set admin = server.get('admin', {}) %}

dbh = db.getSiblingDB("admin");
dbh.createUser({ user: "{{ admin['name'] }}", pwd: "{{ admin['password'] }}", roles: {{ admin['roles'] | json }} });
db.auth("{{ admin['name'] }}", "{{ admin['password'] }}")

{%- for database_name, database_defs in database.iteritems() %}

{%- if database_defs.get('enabled', False) %}

dbh = db.getSiblingDB("{{ database_name }}");

{%- for user_info in database_defs.users %}
dbh.createUser({ user: "{{ user_info['name'] }}", pwd: "{{ user_info['password'] }}", roles: {{ user_info['roles'] | json }} });
{%- endfor %}

{%- endif %}

{%- endfor %}
