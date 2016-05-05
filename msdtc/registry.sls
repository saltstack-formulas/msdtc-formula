# -*- coding: utf-8 -*-
# vim: ft=sls
{##
  Import settings from map.jinja
##}
{% from slspath ~ '/map.jinja' import msdtc with context %}
{% import_yaml slspath ~ '/lookup.yml' as lookup %}
{% set reg_msdtc = 'HKLM\\SOFTWARE\\Microsoft\\MSDTC\\' %}
{% set reg_security = reg_msdtc ~ 'Security\\' %}
{## 
  If inbound and outbound transactions are both disabled, 
  then set NetworkDtcAccessTransactions to disabled.
##}
{% set transactions_enabled = 1 %}
{% if lookup.registry.get(msdtc.security.network_access.inbound_enabled) == 0 %}
  {% if lookup.registry.get(msdtc.security.network_access.outbound_enabled) == 0 %}
    {% set transactions_enabled = 0 %}
  {% endif %}
{% endif %}
{##
  Three registry entries are each set acording to which of the three 
  possible settings is configured for the required authentication.  
##}
{% set auth_type = {} %}
{% if msdtc.security.network_access.authentication|lower == 'incoming' %}
  {% set auth_type = {
    'mutual': 0,
    'incoming': 1,
    'none': 0
    } 
  %}
{% elif msdtc.security.network_access.authentication|lower == 'none' %}
  {% set auth_type = {
    'mutual': 0,
    'incoming': 0,
    'none': 1
    }
  %}
{% else %}
  {% set auth_type = {
    'mutual': 1,
    'incoming': 0,
    'none': 0
    }
  %}
{% endif %}

msdtc-network-access-registry:
  reg.present:
    - name: {{ reg_security }}
    - vname: NetworkDtcAccess
    - vdata: {{ lookup.registry.get(msdtc.security.network_access.enabled) }}
    - vtype: REG_DWORD

{##
  Allow remote administration
##}
msdtc-network-access-admin-registry:
  reg.present:
    - name: {{ reg_security }}
    - vname: NetworkDtcAccessAdmin
    - vdata: {{ lookup.registry.get(msdtc.security.network_access.admin_enabled) }}
    - vtype: REG_DWORD

{##
  Allow remote clients
##}
msdtc-network-access-client-registry:
  reg.present:
    - name: {{ reg_security }}
    - vname: NetworkDtcAccessClients
    - vdata: {{ lookup.registry.get(msdtc.security.network_access.client_enabled) }}
    - vtype: REG_DWORD

msdtc-network-access-inbound-registry:
  reg.present:
    - name: {{ reg_security }}
    - vname: NetworkDtcAccessInbound
    - vdata: {{ lookup.registry.get(msdtc.security.network_access.inbound_enabled) }}
    - vtype: REG_DWORD

msdtc-network-access-outbound-registry:
  reg.present:
    - name: {{ reg_security }}
    - vname: NetworkDtcAccessOutbound
    - vdata: {{ lookup.registry.get(msdtc.security.network_access.outbound_enabled) }}
    - vtype: REG_DWORD

msdtc-network-access-transactions-registry:
  reg.present:
    - name: {{ reg_security }}
    - vname: NetworkDtcAccessTransactions
    - vdata: {{ transactions_enabled }}
    - vtype: REG_DWORD

{##
  SNA LU 6.2 transaction protocol:
    https://en.wikipedia.org/wiki/IBM_LU6.2
##}
msdtc-transactions-lu-registry:
  reg.present:
    - name: {{ reg_security }}
    - vname: LuTransactions
    - vdata: {{ lookup.registry.get(msdtc.security.transactions.lu_enabled) }}
    - vtype: REG_DWORD

{##
  XA Open TCP transaction protocol:
    https://en.wikipedia.org/wiki/X/Open_XA
##}
msdtc-transactions-xa-registry:
  reg.present:
    - name: {{ reg_security }}
    - vname: XaTransactions
    - vdata: {{ lookup.registry.get(msdtc.security.transactions.xa_enabled) }}
    - vtype: REG_DWORD

msdtc-secure-rpc-registry:
  reg.present:
    - name: {{ reg_msdtc }}
    - vname: AllowOnlySecureRpcCalls
    - vdata: {{ auth_type['mutual'] }}
    - vtype: REG_DWORD

msdtc-unsecure-rpc-registry:
  reg.present:
    - name: {{ reg_msdtc }}
    - vname: FallbackToUnsecureRPCIfNecessary
    - vdata: {{ auth_type['incoming'] }}
    - vtype: REG_DWORD

msdtc-no-rpc-registry:
  reg.present:
    - name: {{ reg_msdtc }}
    - vname: TurnOffRpcSecurity
    - vdata: {{ auth_type['none'] }}
    - vtype: REG_DWORD
