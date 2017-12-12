# Puppet Configuration

This document provides documentation on Puppet classes and defines implemented for ease use in order
to deploy Anthill Platform on any Linux system.

Please see <a href="https://github.com/anthill-platform/puppet-anthill">puppet-anthill<a>
repository for source code reference on those classes.

# Components

The Puppet Configuration consists of a different components you may use and may not (that depends
on your use case):

### <img src="https://user-images.githubusercontent.com/1666014/33891956-2d36f6ea-df60-11e7-8f1b-710524f0eb74.png" height="16"> Anthill Core

This code will install the core of the Anthill Platform, including required packages, setup
necessary directories and will install 'core' python packages required for every service:

```puppet
class { anthill:
  debug => true,
  external_domain_name => "example.com",
  internal_domain_name => "example.internal"
}
```

### <img src="https://user-images.githubusercontent.com/1666014/33891956-2d36f6ea-df60-11e7-8f1b-710524f0eb74.png" height="16"> PuppetDB

<a href="https://docs.puppet.com/puppetdb/">PuppetDB</a> is required to run 
"exported resources" the Puppet language offers.

```puppet
include anthill::puppetdb
```
This will allow the resources on one node (for example, internal IP of the node `A`) to appear on another node 
(for example, as an entry in `/etc/hosts` file on the node `B`, so node `B` would know how to communicate node `A`).

### <img src="https://user-images.githubusercontent.com/1666014/33891956-2d36f6ea-df60-11e7-8f1b-710524f0eb74.png" height="16"> Authentication Keys

Please see <a href="Keys.md">Keys documentation</a> for more information about this component.

To deploy both public and private keys to the node, use this:

```puppet
class { anthill::keys:
  authentication_public_key => "puppet:///modules/keys/anthill.pub",
  authentication_private_key => "puppet:///modules/keys/anthill.pem",
  authentication_private_key_passphrase => "anthill"
}
```

To deploy just the public key to the node, use this instead:

```puppet
class { anthill::keys:
  authentication_public_key => "puppet:///modules/keys/anthill.pub"
}
```

**Note**: The submodule of your environment `modules/keys` is required to hold the actual keys. 
See <a href="https://github.com/anthill-platform/puppet-anthill-dev">puppet-anthill-dev</a> for the example.

### <img src="https://user-images.githubusercontent.com/1666014/33891956-2d36f6ea-df60-11e7-8f1b-710524f0eb74.png" height="16"> External Services

These Puppet classes will install, configure and setup the external services you would need

```puppet
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
```

### <img src="https://user-images.githubusercontent.com/1666014/33891956-2d36f6ea-df60-11e7-8f1b-710524f0eb74.png" height="16"> DNS Management

This will make sure you services cat reach each other out, in convenient way
```puppet
class { anthill::dns: }
```
<a href="#-puppetdb">PuppetDB</a> component is required for this feature to work.

### <img src="https://user-images.githubusercontent.com/1666014/33891956-2d36f6ea-df60-11e7-8f1b-710524f0eb74.png" height="16"> Commons Library

This will pull the source code of the <a href="https://github.com/anthill-platform/anthill-common">Anthill Commons</a> library,
required by every Anthill Service.
```puppet
class { anthill::common: 
  repository_remote_url => "https://github.com/anthill-platform/anthill-common.git"
}
```

Aside from the source code, you wold also need to checkout a certain commit of the source code as a certain version of the
library, so other services would be able to use the right version of the library:

```puppet
anthill::common::version { "<version of the library>": 
  source_commit => "<certain commit hash from the repository>" 
}
```

For example, 

```puppet
anthill::common::version { "0.2": 
  source_commit => "87d139808837db6bd5ec6e888b4e75ea2ce2be03" 
}
```

### <img src="https://user-images.githubusercontent.com/1666014/33891956-2d36f6ea-df60-11e7-8f1b-710524f0eb74.png" height="16"> Anthill Services

Like the Anthill Commons library, you can checkout the source code of some service first:

```puppet
class { anthill_<service name>: 
  repository_remote_url => "repository url",
  default_version => "<default version>"
}
```

And then setup certain version of that service for user's use:
```puppet
anthill_<service name>::version { "<version of the service>": 
  source_commit => "<certain commit hash from the repository>"
}
```

For example, the Discovery Service might be installed like so:

```puppet
# pull the source code first
class { anthill_discovery: 
  default_version => "0.2",
  repository_remote_url => "https://github.com/anthill-platform/anthill-discovery.git"
}

# and then checkout a certain version (0.2) of the service
anthill_discovery::version { "0.2": 
  source_commit => "630b7526d1619c76150cd2107edf8d7a2b16bacd" 
}
```

#### Multiple Versions At The Same TIme

You can have multiple versions of services to be installed at the same time:

```puppet
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
```

The users will decide which version to use (or simply prefer to have the default one)

### <img src="https://user-images.githubusercontent.com/1666014/33891956-2d36f6ea-df60-11e7-8f1b-710524f0eb74.png" height="16"> List Of The Anthill Services With Their Classes

<details>
  <summary>See The List</summary>
  <p>
  
| Service | Puppet Class Name | Pull Source Code | Checkout Specific Version |
|---------|-------------------|----------|----------|
| <a href="https://github.com/anthill-platform/anthill-admin">admin</a> | `anthill_admin` | `class { anthill_admin: ... }` | `anthill_admin::version { "0.2": ... }` |
| <a href="https://github.com/anthill-platform/anthill-config">config</a> | `anthill_config` | `class { anthill_config: ... }` | `anthill_config::version { "0.2": ... }` |
| <a href="https://github.com/anthill-platform/anthill-discovery">discovery</a> | `anthill_discovery` | `class { anthill_discovery: ... }` | `anthill_discovery::version { "0.2": ... }` |
| <a href="https://github.com/anthill-platform/anthill-dlc">dlc</a> | `anthill_dlc` | `class { anthill_dlc: ... }` | `anthill_dlc::version { "0.2": ... }` |
| <a href="https://github.com/anthill-platform/anthill-environment">environment</a> | `anthill_environment` | `class { anthill_environment: ... }` | `anthill_environment::version { "0.2": ... }` |
| <a href="https://github.com/anthill-platform/anthill-event">event</a> | `anthill_event` | `class { anthill_event: ... }` | `anthill_event::version { "0.2": ... }` |
| <a href="https://github.com/anthill-platform/anthill-exec">exec</a> | `anthill_exec` | `class { anthill_exec: ... }` | `anthill_exec::version { "0.2": ... }` |
| <a href="https://github.com/anthill-platform/anthill-game-master">game master</a> | `anthill_game_master` | `class { anthill_game_master: ... }` | `anthill_game_master::version { "0.2": ... }` |
| <a href="https://github.com/anthill-platform/anthill-game-controller">game controller</a> | `anthill_game_controller` | `class { anthill_game_controller: ... }` | `anthill_game_controller::version { "0.2": ... }` |
| <a href="https://github.com/anthill-platform/anthill-leaderboard">leaderboard</a> | `anthill_leaderboard` | `class { anthill_leaderboard: ... }` | `anthill_leaderboard::version { "0.2": ... }` |
| <a href="https://github.com/anthill-platform/anthill-login">login</a> | `anthill_login` | `class { anthill_login: ... }` | `anthill_login::version { "0.2": ... }` |
| <a href="https://github.com/anthill-platform/anthill-message">message</a> | `anthill_message` | `class { anthill_message: ... }` | `anthill_message::version { "0.2": ... }` |
| <a href="https://github.com/anthill-platform/anthill-profile">profile</a> | `anthill_profile` | `class { anthill_profile: ... }` | `anthill_profile::version { "0.2": ... }` |
| <a href="https://github.com/anthill-platform/anthill-promo">promo</a> | `anthill_promo` | `class { anthill_promo: ... }` | `anthill_promo::version { "0.2": ... }` |
| <a href="https://github.com/anthill-platform/anthill-report">report</a> | `anthill_report` | `class { anthill_report: ... }` | `anthill_report::version { "0.2": ... }` |
| <a href="https://github.com/anthill-platform/anthill-social">social</a> | `anthill_social` | `class { anthill_social: ... }` | `anthill_social::version { "0.2": ... }` |
| <a href="https://github.com/anthill-platform/anthill-static">static</a> | `anthill_static` | `class { anthill_static: ... }` | `anthill_static::version { "0.2": ... }` |
| <a href="https://github.com/anthill-platform/anthill-store">store</a> | `anthill_store` | `class { anthill_store: ... }` | `anthill_store::version { "0.2": ... }` |

To see documentation about the Puppet classes, see the corresponding repositories.

  </p>
</details>

### <img src="https://user-images.githubusercontent.com/1666014/33891956-2d36f6ea-df60-11e7-8f1b-710524f0eb74.png" height="16"> VPN

Once you will have multiple nodes, you would need to install Virtual Private Network 
to have secure connection between them.

Simply add `anthill::vpn` with `mode=server` to the node that is going to be the Server:

````puppet
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
````

And `anthill::vpn` with `mode=clinet` to the nodes that are going to be the Clients:

````puppet
# node ClientA
class { anthill::vpn:
  mode => 'client',
  vpn_tag => 'main',
  client_index => 0,
  client_server_fqdn => "vpn-dev.example.com"
}
````

````puppet
# node ClientB
class { anthill::vpn:
  mode => 'client',
  vpn_tag => 'main',
  client_index => 1,
  client_server_fqdn => "vpn-dev.example.com"
}
````

**Notes**:

1. <a href="#-puppetdb">PuppetDB</a> component is required for this feature to work.
2. You should ensure there is no two client nodes with same `client_index`
3. To successfully setup the VPN connection you would need to run puppet agent several times:
first, ont the client node, then on the server node, then on the client not again several times.
These limitations are related to the way exported resources work.

# Examples

### All Anthill Services onto a single machine:

<details>
  <summary>See the code</summary>
  <p>

```puppet

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

```

  </p>
</details>

### Game Controller Service On A Separate Machine From The Rest Services:

<details>
  <summary>The Main Node Code</summary>
  <p>
  
```puppet
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
```

  </p>
</details>

<details>
  <summary>The Game Controller Node Code</summary>
  <p>
  
```puppet
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
    domain => "game-ctl-1-vm"
  }

  # Anthill Commonts library versions
  anthill::common::version { "0.2":
    source_commit => "87d139808837db6bd5ec6e888b4e75ea2ce2be03"
  }

  # Anthill Services versions assigned to appropriate commits
  anthill_game_controller::version { "0.2":
    source_commit => "f1fa1f166e2e4a19bf00dee72137e282f46f4af0",
    gs_host => "game-ctl-1-vm.anthillplatform.org",
    internal_broker => "amqp://anthill:anthill@rabbitmq-vm.anthill.internal:5672/${environment}",
    pubsub => "amqp://anthill:anthill@rabbitmq-vm.anthill.internal:5672/${environment}"
  }
}
```

  </p>
</details>
