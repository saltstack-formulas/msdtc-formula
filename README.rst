========
msdtc
========

Formula to enable and configure the Microsoft Distributed Transaction Coordinator.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Status
======

* This formula has been tested on salt-minion 2015.5.8, running under Windows Server 2008r2 SP1 and Windows Server 2012r2.

Available states
================

.. contents::
    :local:

``msdtc``
----------
Meta-state which includes the following states, in order::

    msdtc.registry
    msdtc.service  

``msdtc.registry``
----------
Toggles various Security and Transaction Manager Communication settings. Settings are configurable via the pillar.

``msdtc.service``
-----------
Ensures the MSDTC service is running.

Defaults
========

See ``msdtc/defaults.yml``.

