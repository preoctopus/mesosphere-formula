{% set p  = salt['pillar.get']('mesosphere', {}) %}
{% set pm = p.get('mesos', {}) %}
{% set pma = p.get('marathon', {}) %}
{% set pc = pm.get('config', {}) %}
{% set pcm = pc.get('master', {}) %}
{% set pcs = pc.get('slave', {}) %}
{% set pcma = pma.get('config', {}) %}

{% set g  = salt['grains.get']('mesosphere', {}) %}
{% set gm = g.get('mesos', {}) %}
{% set gma = g.get('marathon', {}) %}
{% set gc = gm.get('config', {}) %}
{% set gcm = gc.get('master', {}) %}
{% set gcs = gc.get('slave', {}) %}
{% set gcma = gma.get('config', {}) %}

{% set zk_role = pc.get('zookeeper_role', 'zookeeper') %}
{% set mm_role = pc.get('mesos_master_role', 'mesos-master') %}
{% set ms_role = pc.get('mesos_slave_role', 'mesos-slave') %}
{% set ma_role = pc.get('mesos_marathon_role', 'marathon') %}
{% set zm = salt['mine.get']('roles:'+zk_role, 'network.ip_addrs', expr_form='grain') %}
{% set mm = salt['mine.get']('roles:'+mm_role, 'network.ip_addrs', expr_form='grain') %}

{%- set zklist = [] %}
{%- for server, addrs in zm.items() %}
{%-   do zklist.append(addrs[0] + ':2181') %}
{%- endfor %}
{%- if zklist|length ==  0 %}
{%-   do zklist.append('localhost:2181') %}
{%- endif %}

{%- set mmquorum = 1 %}
{%- if mm|length < 1 %}
{%-   set mmquorum = mm|length // 2 %}
{%- endif %}

{%- set mesos = {} %}
{%- do mesos.update( {
  'version'      : pm.get('version', '0.20.0'),
  'ma_version'   : pma.get('version', '0.8.1'),
  'zk_role'      : zk_role,
  'mm_role'      : mm_role,
  'ms_role'      : ms_role,
  'ma_role'      : ma_role,
  'log_dir'      : gc.get('log_dir', pc.get('log_dir', '/var/log/mesos')),
  'config_dir'   : gc.get('config_dir', pc.get('config_dir', '/etc/mesos')),
  'config_dir_master'   : gc.get('config_dir_master', pc.get('config_dir_master', '/etc/mesos-master')),
  'config_dir_slave'   : gc.get('config_dir_slave', pc.get('config_dir_slave', '/etc/mesos-slave')),
  'config_dir_marathon' : gma.get('config_dir', pma.get('config_dir', '/etc/marathon/conf')),
  'zookeeper_server_list' : gc.get('zookeeper_server_list', pc.get('zookeeper_server_list', zklist)),
  'zookeeper_path'        : pcm.get('zookeeper_path', pc.get('zookeeper_path', 'mesos')),  
  'zookeeper_path_marathon'        : gma.get('zookeeper_path', pma.get('zookeeper_path', 'marathon')),  
}) %}

{# master/slave config item, merged in later #}
{%- set mesos_conf = {} %}
{%- do mesos_conf.update({
    'ip'  : grains['ip_interfaces'][gc.get('interface', pc.get('interface', 'eth0'))][0],
    'hostname' : grains['fqdn']
}) %}
{%- for config_item in ['logging_level', 'port'] %}
{%-   do mesos_conf.update({ config_item : gc.get(config_item, pc.get(config_item, None)) }) %}
{%- endfor %}

{# master config items #}
{%- set mesos_conf_master = {} %}
{%- do mesos_conf_master.update(mesos_conf) %}
{%- for config_item in ['acls', 'allocation_interval', 'allocator', 'authenticate', 'authenticate_slaves', 'authenticators', 'credentials', 'external_log_file', 'framework_sorter', 'hostname', 'offer_timeout', 'rate_limits', 'roles', 'weights'] %}
{%-   do mesos_conf_master.update({ config_item : gcm.get(config_item, gc.get( config_item, pcm.get(config_item, pc.get( config_item, None)))) }) %}
{%- endfor %}
{%- do mesos_conf_master.update({ 
    'quorum'   : mmquorum,
    'work_dir' : pcm.get('work_dir', pc.get('work_dir', '/var/lib/mesos')),
    'cluster'  : pcm.get('cluster', pc.get('cluster', 'mycluster'))
}) %}

{# slave config items #}
{%- set mesos_conf_slave = {} %}
{%- do mesos_conf_slave.update(mesos_conf) %}
{%- for config_item in ['attributes', 'containerizers', 'credential', 'docker', 'docker_remove_delay', 'docker_sock', 'docker_sandbox_directory', 'docker_stop_timeout', 'executor_registration_timeout', 'hostname', 'resources'] %}
{%-   do mesos_conf_slave.update({ config_item : gcs.get(config_item, gc.get(config_item, pcs.get( config_item, pc.get( config_item, None)))) }) %}
{%- endfor %}

{# marathon config items #}
{%- set mesos_conf_marathon = {} %}
{%- for config_item in ['event_subscriber', 'access_control_allow_origin', 'framework_name', 'ha', 'webui_url', 'mesos_role', ] %}
{%-   do mesos_conf_marathon.update({ config_item : gcma.get(config_item, pcma.get(config_item, None))}) %}
{%- endfor %}
