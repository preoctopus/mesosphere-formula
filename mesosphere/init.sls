{%- from 'mesosphere/settings.sls' import mesos with context %}

mesos:
  pkg.installed:
    - version: {{ mesos.version }}

zookeeper-mesos:
  service:
    - name: zookeeper
    - require:
      - pkg: mesos
{%- if mesos.zk_role in grains['roles'] %}
    - running
{%- else %}
    - dead
{%- endif %}

mesos-zk-file:
  file.managed:
    - name: {{ mesos.config_dir }}/zk
    - source: salt://mesosphere/conf/zk
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - makedirs: True
    - context:
      zookeeper_server_list: {{ mesos.zookeeper_server_list }}
      zookeeper_path: {{ mesos.zookeeper_path }}


