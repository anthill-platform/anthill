
Puppet Configuration
====================

.. |component| image:: images/component.png
   :width: 13px

.. note:: This document provides documentation on Puppet classes and defines
    for ease use in order to deploy Anthill Platform on any Linux system.
    Please refer to :doc:`installation` for the actual installation instructions.

All the examples below are related to ``init.pp`` document inside of your Puppet environment.
Please refer to :ref:`puppet-init` for additional information about that file.

Components
----------

The Puppet Configuration consists of a different components you may use
and may not (that depends on your use case):

|component| Anthill Core
~~~~~~~~~~~~~~~~~~~~~~~~

This code will install the core of the Anthill Platform, including
required packages, setup necessary directories and will install ‘core’
python packages required for every service:

.. code-block:: puppet

    class { anthill:
      debug => true,
      external_domain_name => "example.com",
      internal_domain_name => "example.internal"
    }

|component| PuppetDB
~~~~~~~~~~~~~~~~~~~~

PuppetDB is required to run “exported resources” the Puppet language
offers.

.. code-block:: puppet

    include anthill::puppetdb

This will allow the resources on one node (for example, internal IP of
the node ``A``) to appear on another node (for example, as an entry in
``/etc/hosts`` file on the node ``B``, so node ``B`` would know how to
communicate node ``A``).

.. note:: This component is only required on the Puppet Master node,
    therefore, if you do not plan to deploy the Anthill Platform on the same
    machine with the Puppet Master, separate the PuppetDB instead:

.. code-block:: puppet

    node 'puppet.example.com' {
      include anthill::puppetdb
    }

    node 'therest.example.com' {
      class { anthill: }
    }

|component|  Authentication Keys
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Please see :ref:`authentication-keys` documentation for more information about this component.

To deploy both public and private keys to the node, use this:

.. code-block:: puppet

    class { anthill::keys:
      authentication_public_key => "puppet:///modules/keys/anthill.pub",
      authentication_private_key => "puppet:///modules/keys/anthill.pem",
      authentication_private_key_passphrase => "anthill"
    }

To deploy just the public key to the node, use this instead:

.. code-block:: puppet

    class { anthill::keys:
      authentication_public_key => "puppet:///modules/keys/anthill.pub"
    }

**Note**: The submodule of your environment ``modules/keys`` is required
to hold the actual keys. See puppet-anthill-dev for the example.

|component| External Services
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

These Puppet classes will install, configure and setup the external
services you would need

.. code-block:: puppet

    # reverse proxy to handle users requests
    class { anthill::nginx: }

    # primary storage database
    class { anthill::mysql: }

    # run, monitor and control of the Anthill services
    class { anthill::supervisor: }

    # messaging system
    class { anthill::rabbitmq: }

    # fast key/value storage (primarily for caching)
    class { anthill::redis: }

|component| DNS Management
~~~~~~~~~~~~~~~~~~~~~~~~~~

This will make sure you services cat reach each other out, in convenient
way

.. code-block:: puppet

    class { anthill::dns: }

PuppetDB component is required for this feature to work.

|component| Commons Library
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This will pull the source code of the Anthill Commons library, required
by every Anthill Service.

.. code-block:: puppet

    class { anthill::common: 
      repository_remote_url => "https://github.com/anthill-platform/anthill-common.git"
    }

Aside from the source code, you wold also need to checkout a certain
commit of the source code as a certain version of the library, so other
services would be able to use the right version of the library:

.. code-block:: puppet

    anthill::common::version { "<version of the library>": 
      source_commit => "<certain commit hash from the repository>" 
    }

For example,

.. code-block:: puppet

    anthill::common::version { "0.2": 
      source_commit => "87d139808837db6bd5ec6e888b4e75ea2ce2be03" 
    }

|component| Anthill Services
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Like the Anthill Commons library, you can checkout the source code of
some service first:

.. code-block:: puppet

    class { anthill_<service name>: 
      repository_remote_url => "repository url",
      default_version => "<default version>"
    }

And then setup certain version of that service for user’s use:

.. code-block:: puppet

    anthill_<service name>::version { "<version of the service>": 
      source_commit => "<certain commit hash from the repository>"
    }

For example, the Discovery Service might be installed like so:

.. code-block:: puppet

    # pull the source code first
    class { anthill_discovery: 
      default_version => "0.2",
      repository_remote_url => "https://github.com/anthill-platform/anthill-discovery.git"
    }

    # and then checkout a certain version (0.2) of the service
    anthill_discovery::version { "0.2": 
      source_commit => "630b7526d1619c76150cd2107edf8d7a2b16bacd" 
    }

SSH Keys
^^^^^^^^

If you would like to pull the source code through SSH
(``git@github.com:...``), you would need to configure your SSH keys:

1. Generate SSH key pair: ``ssh-keygen``
2. Upload your public key (``id_rsa.pub``) to your repository provider.
3. Add your private key (``id_rsa``) to your puppet configuration
   (``environment/<environment>/modules/keys/files/ssh.pem``)
4. Update ``anthill::keys`` class:

.. code-block:: puppet

    class { anthill::keys:
      ssh_private_key => "puppet:///modules/keys/ssh.pem"
    }

Multiple Versions At The Same TIme
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can have multiple versions of services to be installed at the same
time:

.. code-block:: puppet

    # pull the source code first
    class { anthill_login: 
      default_version => "0.2",
      repository_remote_url => "https://github.com/anthill-platform/anthill-login.git"
    }

    # version 0.2 (default)
    anthill_discovery::version { "0.2": 
      source_commit => "1020132daf294ec306db8a46425e8cb5e04e34f0" 
    }

    # also checkout "0.3" version of the Anthill Commons library
    anthill::common::version { "0.3": 
      source_commit => "<some hash pointing to version 0.3 on the Anthill Commons>" 
    }

    # checkout version 0.3
    anthill_discovery::version { "0.3": 
      source_commit => "<some hash pointing to version 0.3 on the commit history>" 
    }

The users will decide which version to use (or simply prefer to have the
default one)

|component| VPN
~~~~~~~~~~~~~~~

Once you will have multiple nodes, you would need to install Virtual
Private Network to have secure connection between them.

Simply add ``anthill::vpn`` with ``mode=server`` to the node that is
going to be the Server:

.. code-block:: puppet

    # node Server
    class { anthill::vpn:
      mode => 'server',
      vpn_tag => 'main',
      server_country => 'US',
      server_province => 'TX',
      server_city => 'Austin',
      server_organization => 'example.com',
      server_email => 'admin@example.com'
    }

And ``anthill::vpn`` with ``mode=clinet`` to the nodes that are going to
be the Clients:

.. code-block:: puppet

    # node ClientA
    class { anthill::vpn:
      mode => 'client',
      vpn_tag => 'main',
      client_index => 0,
      client_server_fqdn => "vpn-dev.example.com"
    }

.. code-block:: puppet

    # node ClientB
    class { anthill::vpn:
      mode => 'client',
      vpn_tag => 'main',
      client_index => 1,
      client_server_fqdn => "vpn-dev.example.com"
    }

**Notes**:

1. PuppetDB component is required for this feature to work.
2. You should ensure there is no two client nodes with same
   ``client_index``
3. To successfully setup the VPN connection you would need to run puppet
   agent several times: first, ont the client node, then on the server
   node, then on the client not again several times. These limitations
   are related to the way exported resources work.

|component| HTTPS
~~~~~~~~~~~~~~~~~

If you would like to serve your services through https:

1. Generate the SSL Bundle file and the Private Key file for your domain
   (for example, ``example_com.ssl-bunlde`` and ``example_com.key``)
2. Add these files to your puppet configuration:

::

    environments/
        <environment>/
            modules/
                keys/
                    files/
                        example_com.key
                        example_com.ssl-bunlde

3. Update your ``anthill::keys`` class like follows:

.. code-block:: puppet

    class { anthill::keys:
      https_keys_bundle_contents => "puppet:///modules/keys/example_com.ssl-bundle",
      https_keys_private_key_contents => "puppet:///modules/keys/example_com.key"
    }

4. Enable HTTPS, with ``anthill`` class:

.. code-block:: puppet

    class { anthill:
      enable_https => true,
      protocol => 'https'
    }

|component| Monitoring
~~~~~~~~~~~~~~~~~~~~~~

If you need to keep track on what’s happening on the services, you might
want to enable monitoring:

.. code-block:: puppet


    # Make services to report stats
    class { anthill:
      services_enable_monitoring => true
    }

    # Install necessary monitoring components
    class { anthill::monitoring::grafana: }
    class { anthill::monitoring::influxdb: }
    class { anthill::monitoring::collectd: }

-  The `InfluxDB <https://docs.influxdata.com/influxdb>`__ component
   will store your monitoring time series;
-  The `Collectd <https://collectd.org/>`__ component will collect
   important statictics of a particular node its insalled on, and send
   them to InfluxDB;
-  The `Grafana <https://grafana.com/>`__ component will display all
   collected information from InfluxDB in beautiful charts, with alerts,
   if neccessary.
-  If ``anthill::services_enable_monitoring`` is enabled, the services
   themselves will also report some informations, like requests rate,
   etc.

These components are independent, and you can place them on difference
machines, if you want to. In that case, you would need to define:

-  ``collectd::influxdb_location`` so Collectd would know where to send
   the stats;
-  ``influxdb::grafana_location`` so Grafana would know where to pull
   the stats from;
-  ``anthill::monitoring_location`` like with Collectd, so each service
   would know in which InfluxDB push the stats into

A good practive would be to place Grafana and InfluxDB on the same node
so it would be dedicated to the monitoring only, and then put Collectd
on another nodes (and enable ``anthill::services_enable_monitoring``
there).

**Note**: Due to dependency limitations, if you’re deploying all three
components on a same machine, the ``grafana`` component should be
mentioned first.

Examples
--------

All Anthill Services onto a single machine:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. toggle-header::
    :header: Example 1 **Show/Hide Code**

    .. code-block:: puppet

        node 'vm.anthillplatform.org' {

          include anthill::puppetdb

          class { anthill:
            debug => true
          }

          class { anthill::keys:
            authentication_public_key => "puppet:///modules/keys/anthill.pub",
            authentication_private_key => "puppet:///modules/keys/anthill.pem",
            authentication_private_key_passphrase => "anthill"
          }

          # core libraries/services
          class { anthill::nginx: }
          class { anthill::mysql: }
          class { anthill::supervisor: }
          class { anthill::rabbitmq: }
          class { anthill::redis: }

          # internal dns management
          class { anthill::dns: }

          # Anthill Commons library
          class { anthill::common: }

          # Anthill Services themselves
          class { anthill_admin: default_version => "0.2" }
          class { anthill_config: default_version => "0.2" }
          class { anthill_discovery: default_version => "0.2" }
          class { anthill_dlc: default_version => "0.2" }
          class { anthill_environment: default_version => "0.2" }
          class { anthill_event: default_version => "0.2" }
          class { anthill_exec: default_version => "0.2" }
          class { anthill_game_master: default_version => "0.2" }
          class { anthill_game_controller: default_version => "0.2" }
          class { anthill_leaderboard: default_version => "0.2" }
          class { anthill_login: default_version => "0.2" }
          class { anthill_message: default_version => "0.2" }
          class { anthill_profile: default_version => "0.2" }
          class { anthill_promo: default_version => "0.2" }
          class { anthill_report: default_version => "0.2" }
          class { anthill_social: default_version => "0.2" }
          class { anthill_static: default_version => "0.2" }
          class { anthill_store: default_version => "0.2" }

          # Anthill Commonts library versions
          anthill::common::version { "0.2": source_commit => "87d139808837db6bd5ec6e888b4e75ea2ce2be03" }

          # Anthill Services versions assigned to appropriate commits
          anthill_admin::version { "0.2": source_commit => "ccb5b47432d9b040212d940823b2da0cef8c5a03" }
          anthill_config::version { "0.2": source_commit => "def49544f7db7cf422e4b23f054f3ec713ac59c7" }
          anthill_discovery::version { "0.2": source_commit => "630b7526d1619c76150cd2107edf8d7a2b16bacd" }
          anthill_dlc::version { "0.2": source_commit => "95041ad4cfa037318704a01cefe640a52aa346e3" }
          anthill_environment::version { "0.2": source_commit => "773401a968317469c85e4f8efdf3068ce4c9dde8" }
          anthill_event::version { "0.2": source_commit => "cf99af35d5835e44f884ba82180154e20bdcad9a" }
          anthill_exec::version { "0.2": source_commit => "5510b1fb9fb81f318c2030549674c7c3d26be585" }
          anthill_game_master::version { "0.2": source_commit => "9acfe29d6bf9f59c2baa3d0438c4296a01f8dc89" }
          anthill_game_controller::version { "0.2": source_commit => "f1fa1f166e2e4a19bf00dee72137e282f46f4af0" }
          anthill_leaderboard::version { "0.2": source_commit => "339dacba3d47179c2e26f1c5e0622ad95d2aa5fb" }
          anthill_login::version { "0.2": source_commit => "1020132daf294ec306db8a46425e8cb5e04e34f0" }
          anthill_message::version { "0.2": source_commit => "0378351628d2ceffc9796b9a255a74181f1fb325" }
          anthill_profile::version { "0.2": source_commit => "c193846dd866f22efe0e6edaee17c5f1561cc838" }
          anthill_promo::version { "0.2": source_commit => "17dcb5493c09f06c9abfc602fc3344cbbe3e72e7" }
          anthill_report::version { "0.2": source_commit => "0cab78eaeefc7a8740c0f2f321724812a754cc1d" }
          anthill_social::version { "0.2": source_commit => "e1fc582396315bd764909990f009908de4fd7b46" }
          anthill_static::version { "0.2": source_commit => "14a2de5f2c3f44d02b9733a4a845a0e86dcbd709" }
          anthill_store::version { "0.2": source_commit => "9e6afd0fb8b4fd5e944765a8646177ce02561475" }

        }

Game Controller Service On A Separate Machine From The Rest Services:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. toggle-header::
    :header: All Services **Show/Hide Code**

    .. code-block:: puppet

        node 'vm.anthillplatform.org' {

          include anthill::puppetdb

          class { anthill:
            debug => true
          }

          class { anthill::keys:
            authentication_public_key => "puppet:///modules/keys/anthill.pub",
            authentication_private_key => "puppet:///modules/keys/anthill.pem",
            authentication_private_key_passphrase => "anthill"
          }

          class { anthill::vpn:
            mode => 'server',
            vpn_tag => 'main',
            server_country => 'US',
            server_province => 'TX',
            server_city => 'Austin',
            server_organization => 'anthillplatform.org',
            server_email => 'admin@anthillplatform.org'
          }

          # core libraries/services
          class { anthill::nginx: }
          class { anthill::mysql: }
          class { anthill::supervisor: }
          class { anthill::rabbitmq: }
          class { anthill::redis: }

          # internal dns management
          class { anthill::dns: }

          # Anthill Commons library
          class { anthill::common: }

          # Anthill Services themselves
          class { anthill_admin: default_version => "0.2" }
          class { anthill_config: default_version => "0.2" }
          class { anthill_discovery: default_version => "0.2" }
          class { anthill_dlc: default_version => "0.2" }
          class { anthill_environment: default_version => "0.2" }
          class { anthill_event: default_version => "0.2" }
          class { anthill_exec: default_version => "0.2" }
          class { anthill_game_master: default_version => "0.2" }
          class { anthill_leaderboard: default_version => "0.2" }
          class { anthill_login: default_version => "0.2" }
          class { anthill_message: default_version => "0.2" }
          class { anthill_profile: default_version => "0.2" }
          class { anthill_promo: default_version => "0.2" }
          class { anthill_report: default_version => "0.2" }
          class { anthill_social: default_version => "0.2" }
          class { anthill_static: default_version => "0.2" }
          class { anthill_store: default_version => "0.2" }

          # Anthill Commonts library versions
          anthill::common::version { "0.2": source_commit => "87d139808837db6bd5ec6e888b4e75ea2ce2be03" }

          # Anthill Services versions assigned to appropriate commits
          anthill_admin::version { "0.2": source_commit => "ccb5b47432d9b040212d940823b2da0cef8c5a03" }
          anthill_config::version { "0.2": source_commit => "def49544f7db7cf422e4b23f054f3ec713ac59c7" }
          anthill_discovery::version { "0.2": source_commit => "630b7526d1619c76150cd2107edf8d7a2b16bacd" }
          anthill_dlc::version { "0.2": source_commit => "95041ad4cfa037318704a01cefe640a52aa346e3" }
          anthill_environment::version { "0.2": source_commit => "773401a968317469c85e4f8efdf3068ce4c9dde8" }
          anthill_event::version { "0.2": source_commit => "cf99af35d5835e44f884ba82180154e20bdcad9a" }
          anthill_exec::version { "0.2": source_commit => "5510b1fb9fb81f318c2030549674c7c3d26be585" }
          anthill_game_master::version { "0.2": source_commit => "9acfe29d6bf9f59c2baa3d0438c4296a01f8dc89" }
          anthill_leaderboard::version { "0.2": source_commit => "339dacba3d47179c2e26f1c5e0622ad95d2aa5fb" }
          anthill_login::version { "0.2": source_commit => "1020132daf294ec306db8a46425e8cb5e04e34f0" }
          anthill_message::version { "0.2": source_commit => "0378351628d2ceffc9796b9a255a74181f1fb325" }
          anthill_profile::version { "0.2": source_commit => "c193846dd866f22efe0e6edaee17c5f1561cc838" }
          anthill_promo::version { "0.2": source_commit => "17dcb5493c09f06c9abfc602fc3344cbbe3e72e7" }
          anthill_report::version { "0.2": source_commit => "0cab78eaeefc7a8740c0f2f321724812a754cc1d" }
          anthill_social::version { "0.2": source_commit => "e1fc582396315bd764909990f009908de4fd7b46" }
          anthill_static::version { "0.2": source_commit => "14a2de5f2c3f44d02b9733a4a845a0e86dcbd709" }
          anthill_store::version { "0.2": source_commit => "9e6afd0fb8b4fd5e944765a8646177ce02561475" }

        }

.. toggle-header::
    :header: The Game Controller Node Code **Show/Hide Code**

    .. code-block:: puppet

        node 'game-ctl-1-vm.anthillplatform.org' {

          class { anthill:
            debug => true
          }

          class { anthill::keys:
            authentication_public_key => "puppet:///modules/keys/anthill.pub"
          }

          class { anthill::vpn:
            mode => 'client',
            vpn_tag => 'main',
            client_index => 0,
            client_server_fqdn => "vpn-vm.anthillplatform.org"
          }

          # core libraries/services
          class { anthill::nginx: }
          class { anthill::supervisor: }
          class { anthill::redis: }

          # internal dns management
          class { anthill::dns: }

          # Anthill Commons library
          class { anthill::common: }

          class { anthill_game_controller:
            default_version => "0.2",
            domain => "game-ctl-1-vm",
            gs_host => "game-ctl-1-vm.example.com",
            internal_broker => "amqp://anthill:anthill@rabbitmq-vm.example.internal:5672/${environment}",
            pubsub => "amqp://anthill:anthill@rabbitmq-vm.example.internal:5672/${environment}"
          }

          # Anthill Commonts library versions
          anthill::common::version { "0.2":
            source_commit => "87d139808837db6bd5ec6e888b4e75ea2ce2be03"
          }

          # Anthill Services versions assigned to appropriate commits
          anthill_game_controller::version { "0.2":
            source_commit => "f1fa1f166e2e4a19bf00dee72137e282f46f4af0"
          }
        }

.. seealso::
   `Source Code <https://github.com/anthill-platform/puppet-anthill>`_ for these Puppet modules
