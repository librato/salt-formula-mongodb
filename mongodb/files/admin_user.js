{%- from "mongodb/map.jinja" import server with context -%}
db.addUser("{{ server.admin.user }}","{{ server.admin.password }}")
db.auth("{{ server.admin.user }}","{{ server.admin.password }}")
