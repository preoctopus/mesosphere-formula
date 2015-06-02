{%- from 'mesosphere/settings.sls' import mesos, mesos_conf_master with context %}

include:
  - mesosphere

mesos-master-directories:
  file.directory:
    - user: root
    - group: root
    - makedirs: True
    - names:
      - {{ mesos.log_dir }}
      - {{ mesos_conf_master.work_dir }}
      - {{ mesos.config_dir }}
      - {{ mesos.config_dir_master }}

mesos-master:
  service:
    - require:
      - pkg: mesos
{%- if mesos.mm_role in grains['roles'] %}
    - running
{%- else %}
    - dead
{%- endif %}
    - watch:
      - file: {{ mesos.config_dir }}/*
      - file: {{ mesos.config_dir_master }}/*

{%- for mfile, val in mesos_conf_master.items() %}
{%- if val %}
mesos-master-{{ mfile }}-file:
  file.managed:
    - name: {{ mesos.config_dir_master }}/{{ mfile }}
    - contents: {{ val }}
    - makedirs: True
{%- endif %}
{%- endfor %}
