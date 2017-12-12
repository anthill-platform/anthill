# How To Generate Keys

## Authentication Keys

Anthill Platform uses [Public-key cryptography](https://en.wikipedia.org/wiki/Public-key_cryptography) to authenticate users. 
The idea is goes as follows:

1. User authenticates himself in the system, giving credentials
2. The short-lived access token is issued with **Private key**

To validate the access token, the **Public key** is used. 
The public key is indeed public and can be stored at any service. 
Unlike the public key, the private key is stored securely (using passphrase) on the Login service only.
To do so, an encrypted private/public key pair should be generated.

### Pick some strong passwords

The private key is a very sensitive piece of information, so it should encrypted with a strong password.
Please generate a complex password, that will be used to encrypt the actual private key.

Edit the `environments/<environment>/manifests/init.pp` file and change this section:
```puppet
class { anthill::keys:
  authentication_private_key_passphrase => "<password A>",
  authentication_public_key => "puppet:///modules/keys/anthill.pub",
  authentication_private_key => "puppet:///modules/keys/anthill.pem",
}
```

This class will take care on actual installation of these keys. 

### Generate the key pair

Then generate the actual keys:
```
cd /etc/puppetlabs/code/environments/<environment>/modules/keys/files
openssl genrsa -des3 -out anthill.pem 2048
```

The key length depends on your situation, but at lease 2048-bit key is recommended.

You will be asked for a password, copy/paste the password A here. 
Then extract the public key:
```
openssl rsa -in anthill.pem -outform PEM -pubout -out anthill.pub
```
Using the same password. 

### Push the keys into the git repository
```
git add anthill.pem
git add anthill.pub
git commit -m "Nothing to see here"
git push
```
