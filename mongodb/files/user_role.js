{%- from "mongodb/map.jinja" import server with context -%}

{%- if database.get('enabled', False) %}
  db = db.getSiblingDB("{{ database_name }}");
  {%- for user_info in database.users %}
    db.addUser({ user: "{{ user_info['name'] }}", pwd: "{{ user_info['password'] }}", roles: {{ user_info['roles'] }} });
  {%- endfor %}
{%- endif %}
