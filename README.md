# Samba-Docker

## Description
Stateless samba container. 

This container permits you to perform bootstrapping logic by mounting a bash file in `/bootstrap.sh`

## Configuration

`smb.conf` is generated at startup from `/etc/config-gen/config.yaml`, so mount your own file over that path.

### Using environment variables

Any `${VAR}` in a string value of `config.yaml` is replaced with that environment variable. This keeps secrets out of the config file itself, which usually lives in a git repository or a Kubernetes ConfigMap.

```yaml
# config.yaml
users:
  - name: "timemachine"
    password: "${TIMEMACHINE_PASSWORD}"
    id: 550
```

```bash
docker run \
  -e TIMEMACHINE_PASSWORD="..." \
  -v ./config.yaml:/etc/config-gen/config.yaml \
  ghcr.io/alekc/samba-docker
```

On Kubernetes the value can come from a Secret, so it never appears in the ConfigMap:

```yaml
env:
  - name: TIMEMACHINE_PASSWORD
    valueFrom:
      secretKeyRef:
        name: samba-passwords
        key: timemachine
```

Two things worth knowing:

* Only the braced form `${VAR}` is substituted. A bare `$VAR` is left alone, so a password containing a literal `$` is safe.
* Expansion happens **after** the YAML is parsed, so the value is inserted into the parsed structure rather than the document text. A password can therefore contain quotes, backslashes, newlines or `#` without breaking the parse or being altered. Run `python3 tests/test_expand_env.py` to check this.
* If the config references a variable that is not set, the container exits with code `5` and names the variable. It deliberately does not fall through, because an unexpanded placeholder would be accepted as a literal password and would then fail authentication in a way that is tedious to trace.

## Tags

* `latest`: daily build, will have the latest version of the alpine and samba package, however can break at any moment. Use at your own risk
* `v1.x`: release version, should not bring any breaking changes
* `v1.0.x`: minor versions, new features introduced, no breaking changes
* `v1.0.0`: minor patches, no new features.
