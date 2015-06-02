{%- from 'mesosphere/settings.sls' import mesos, mesos_conf_slave with context %}

include:
  - mesosphere

mesos-slave:
  service:
    - require:
      - pkg: mesos
{%- if mesos.ms_role in grains['roles'] %}
    - running
{%- else %}
    - dead
{%- endif %}
    - watch:
      - file: {{ mesos.config_dir }}/*
      - file: {{ mesos.config_dir_slave }}/*

{%- for mfile, val in mesos_conf_slave.items() %}
{%- if val %}
mesos-slave-{{ mfile }}-file:
  file.managed:
    - name: {{ mesos.config_dir_slave }}/{{ mfile }}
    - contents: {{ val }}
    - makedirs: True
{%- endif %}
{%- endfor %}
