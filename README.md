# Samba-Docker

## Description
Stateless samba container. 

This container permits you to perform bootstrapping logic by mounting a bash file in `/bootstrap.sh`

## Tags

* `latest`: daily build, will have the latest version of the alpine and samba package, however can break at any moment. Use at your own risk
* `v1.x`: release version, should not bring any breaking changes
* `v1.0.x`: minor versions, new features introduced, no breaking changes
* `v1.0.0`: minor patches, no new features.

## Thanks
Inspired by https://github.com/iMartyn/helm-samba4
