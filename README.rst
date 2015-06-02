=========
mesosphere - work in progress formula
=========

Formula to set up and configure a mesosphere cluster.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Available states
================

.. contents::
    :local:

``mesosphere``
-------------

Installs mesosphere and zookeeper. Zookeeper is started if `zookeeper` is present in the `roles` grain.

``mesosphere.repo``
------------------

Adds the mesosphere package repository

``mesosphere.master``
--------------------

Includes `mesosphere` to install mesosphere and runs the `mesos-master` service if present in the `roles` grain.

``mesosphere.slave``
--------------------

Includes `mesosphere` to install mesosphere and runs the `mesos-slave` service if present in the `roles` grain.

``mesosphere.marathon``
----------------------

Installs `marathon` and starts the service if present in the `roles` grain.

Tested on Ubuntu 14.04.


