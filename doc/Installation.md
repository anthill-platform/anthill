# How To Install Anthill Platform

**Note**: If you need to install Anthill Platform on Mac OS X, 
<a href="https://github.com/anthill-platform/anthill/tree/dev#hack-in">see this instruction</a> instead.
This page describes installation steps on Linux (Debian 8).

Along with actual services, Anthill Platform consists of a lot of external components. 
Configuring them might be quite challenging, so using Puppet in recommended:

1. **Nginx** as a reverse proxy and a load balancer
2. **MySQL 5.7** database for primary content storage
3. **Redis** for fast key/value
4. **RabbitMQ** for internal communication across services
5. **Supervisor** to roll actual services
6. **Python 2.7** with bunch of packages
7. Bunch of debian packages itself

Puppet can handle all of these dependencies for you. 
If you don't know what Puppet is, please follow [here](https://puppet.com/product/how-puppet-works). 
For mode detailed steps (if would be necessary) please see 
[this article](https://www.digitalocean.com/community/tutorials/how-to-install-puppet-4-in-a-master-agent-setup-on-ubuntu-14-04).

## Multi-Node vs Single-Node environment

Depending on your current requirements, you can either have all of the services on a single node,
or split them among multiple instances.

On a multi-node environment you would need to install Puppet Master on some node, and just 
Puppet Agents on the rest of them.

# Installation Steps

## 1. Install Debian
Setup Debian 8 operating system on the target machine with SSH server running. Currently, Puppet configuration supports only Debian 8. This tutorial assumes that you have apt updated and working with root privilages.

## 2. (Optional) Add SSH keys
Upload your public SSH key to target machine so login would go faster: 
```
ssh-copy-id <username>@<hostname>
```
If you haven't generated your keys yet, do `ssh-keygen`.
## 3. Install Puppet

First of all, add the puppet's `deb` package to the apt:

```
cd ~ && wget https://apt.puppetlabs.com/puppetlabs-release-pc1-jessie.deb
dpkg -i puppetlabs-release-pc1-jessie.deb
apt-get update
```

Puppet is primarily made of two components: `Puppet Server` and `Puppet Agent`. Puppet Server used to hold 
configurations (like "we need database and nginx"). Puppet Agent actually applies these configurations 
(like "install database or nginx using Puppet Server configuration").

Practically, a system have one Puppet Server node, and many Puppet Agent nodes, so once applied on the Server,
 all Agents will install those configurations on machines they running. 
 A minimal setup is to have both Puppet Server and Puppet Agent on a same machine. 

| Single-Node environment | Multi-Node environment | 
|-------------------------|------------------------|
| `apt-get -y install puppetserver` to install both Puppet Server and Agent | `apt-get -y install puppetserver` on the "Master node", `apt-get -y install puppet-agent` for the "Agent nodes" |


## 4. Configure the Puppet Server
```
/etc/init.d/puppetserver start
```
Then make sure it's running using this:
```
/etc/init.d/puppetserver status
```
If it's running, run this to make sure puppet starts when the systems boots:
```
/opt/puppetlabs/bin/puppet resource service puppetserver ensure=running enable=true
```
## 5. Pick your domain
In order you clients to reach your servers, a domain name (like `example.com`) should be bound to this machine's IP address. 
Simplest way would be to create `A` record for `*.<domain>.com`, for example `*.example.com`. 
That would make go any of subdomains requests to this machine (like `foo.example.com/test` or `bar.example.com/test`).

## 6. Configure your environment

Fork this repository: <a href="https://github.com/anthill-platform/puppet-anthill-dev">https://github.com/anthill-platform/puppet-anthill-dev</a>

The repository above has a minimal configuration required for a dev environment. It consists of a two main parts:

### The `environments/` folder

This folder contains all of your environments you need. For example, you may need two environments: `dev` for a 
development and early-testing of new features and `production` for actual production releases.

Every environment folder should have such structure:

```
environments/
    dev/
        manifests/
            init.pp
        modules/
            keys/
                anthill.pem
                anthill.pub
                * other keys *
```

File `manifests/init.pp` is the main configuration file for the environment. According to the Puppet language,
it tells which service belongs to each node. Please see <a href="Puppet.md">Puppet Configuration</a> for details.

The submodule `modules/keys` is a special module for your private keys. Anthill Platform uses asymmetric cryptography 
to authenticate users. To do so, an encrypted private/public key pair should be generated 
(`anthill.pem` and `anthill.pub` from the example above). 

Please see <a href="Keys.md">How To Generate Keys</a> for a simple instruction on how to generate your keys.

### The `modules/` folder

This folder contains all modules Puppet needs, including modules for Anthill Platform itself, and some external modules
from open-source developers.

## 7. Deploy your Puppet Configuration repository onto the Puppet Server node

The configuration repository need to be placed at `/etc/puppetlabs/code` folder:

```
cd /etc/puppetlabs
rm -rf code
git clone https://<your fork>.git code
cd /etc/puppetlabs/code
git submodule update --init --recursive
```

## 8. Configure the Puppet Agent
Once Puppet Server is configured, Puppet Agents can be used to install your environment on the actual machines. 

If you're installing the Puppet Agent on a different machine from Puppet Server, do this:
```
apt-get -y install puppet-agent
```

Once you have Puppet Agent package installed, the Puppet Agent will need to know where puppet Server is located, 
and what environment to work on:
```
nano /etc/puppetlabs/puppet/puppet.conf
```
Set these options:
```
[main]
environment = <environment>
server = <hostname>
```

The `<hostname>` option is the Puppet Server location. 
In a minimal installations, it's a current machine hostname.
 
The `<environment>` option dictates what environment this Puppet Agent belongs to.

## 9. Fire the Puppet Agent
To install actual software, run the following command
```
/opt/puppetlabs/puppet/bin/puppet agent --test --certname=<domain name of the machine> --environment=<environment>
```

**A note for Multi-Node Environment setup**: If you're trying to run puppet on a different
machine from Puppet Server, the first run of the Agent might just return 
with `Exiting; no certificate found and waitforcert is disabled` error due to Agent certificate not being signed. 
To fix this, sign the Puppet Agent's certificate on a Puppet Server node:
`/opt/puppetlabs/puppet/bin/puppet cert sign <domain name of the puppet agent's machine>` and re-run.

**Known Puppet SSL issue**: If you're experience the problem related to SSL, please see 
<a href="https://docs.puppet.com/puppet/4.5/ssl_regenerate_certificates.html">SSL: Regenerating all Certificates in a Puppet deployment</a>. 

From now on, if you need something changed, just commit these changes into your Puppet Configuration repository, 
pull it on place, and apply with `puppet agent --test` again like described above.

The actual installation will take a while (up to several hours), and if everything goes fine, you will have such things configured:
* mysql-server 5.7 installed and configured 
* databases created for each service along with database accounts
* nginx installed and configured to reverse-proxy each service at a different location
* nginx vhost record is created for each service
* rabbitmq installed and configured
* redis installed and configured
* supervisor installed and configured
* each service is registered in supervisor as a program that can be turned on or off

## 10. Done
* Reboot the system. From that point you should have a fully configured service running on one machine.
* Open `http://admin-<environment>.<external domain>/` in your browser.
* Login using username `root` and password `anthill`.
