{%- from "mongodb/map.jinja" import server with context -%}

{%- if database_defs.get('enabled', False) %}
  db = db.getSiblingDB("{{ database_name }}");
  {%- for user_info in database_defs.users %}
    db.addUser({ user: "{{ user_info['name'] }}", pwd: "{{ user_info['password'] }}", roles: {{ user_info['roles'] | json }} });
  {%- endfor %}
{%- endif %}
