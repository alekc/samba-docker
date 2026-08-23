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

Images are published to `ghcr.io/alekc/samba-docker`. Releases used to go to Docker Hub; that stopped after `v1.0.0` and everything now lands in one place.

Every tag below is produced by the same release build, so they are all immutable except `latest`, which moves.

* `latest`: the most recent release. Previously a daily build of unpinned packages; the Dockerfile pins alpine, samba, python and s6, so a scheduled rebuild produced an identical image and that workflow was removed.
* `v1.x`: newest release in that major series, no breaking changes within it
* `v1.1.x`: newest patch in that minor series, no new features within it
* `v1.1.0`: one exact release, never moves

Pin `v1.1.0` for anything you care about. Pull requests also publish `pr-N` for testing, but those are mutable and are cleaned up when the PR closes.
