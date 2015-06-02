{%- from 'mesosphere/settings.sls' import mesos, mesos_conf_marathon with context %}

marathon:
  pkg.installed:
    - version: {{ mesos.ma_version }}
  service:
    - require:
      - pkg: marathon
    - watch:
      - file: {{ mesos.config_dir_marathon }}/*
{%- if mesos.ma_role in grains['roles'] %}
    - running
{%- else %}
    - dead
{%- endif %}

marathon_config_dir:
  file.directory:
    - require:
      - pkg: marathon
    - user: root
    - group: root
    - makedirs: True
    - name: {{ mesos.config_dir_marathon }}

marathon-zk-file:
  file.managed:
    - name: {{ mesos.config_dir_marathon }}/zk
    - source: salt://mesosphere/conf/zk
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - makedirs: True
    - context:
      zookeeper_server_list: {{ mesos.zookeeper_server_list }}
      zookeeper_path: {{ mesos.zookeeper_path_marathon }}

{%- for mfile, val in mesos_conf_marathon.items() %}
{%- if val %}
mesos-marathon-{{ mfile }}-file:
  file.managed:
    - name: {{ mesos.config_dir_marathon }}/{{ mfile }}
    - contents: {{ val }}
    - makedirs: True
{%- endif %}
{%- endfor %}
