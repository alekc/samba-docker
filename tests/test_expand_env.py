"""Tests for ${VAR} expansion in the config generator.

Runnable either with pytest or directly: python3 tests/test_expand_env.py
"""
import importlib.util
import os
import pathlib
import sys

import yaml

_SRC = pathlib.Path(__file__).resolve().parents[1] / "rootfs/etc/config-gen/config.py"
_spec = importlib.util.spec_from_file_location("config_gen", _SRC)
assert _spec is not None and _spec.loader is not None, f"cannot load {_SRC}"
config_gen = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(config_gen)
expand_env = config_gen.expand_env

TEMPLATE = 'users:\n  - name: "u"\n    password: "${PW}"\n'


def _roundtrip(value):
    """Parse the config template, then expand, and return the password."""
    os.environ["PW"] = value
    config = expand_env(yaml.load(TEMPLATE, Loader=yaml.SafeLoader))
    return config["users"][0]["password"]


def test_values_survive_yaml_metacharacters():
    """A value must reach smbpasswd byte for byte.

    These three broke when expansion ran on the raw text: a quote and a
    backslash raised parser errors, and a newline was silently folded to a
    space, which supplies a different password than intended.
    """
    for value in ['pa"ss', "pa\\ss", "pa\nss", "pa#ss", "pa: ss", "pa]ss", ""]:
        assert _roundtrip(value) == value, f"mangled {value!r}"


def test_plain_alphanumeric_value():
    assert _roundtrip("Abc123") == "Abc123"


def test_multiple_references_in_one_string():
    os.environ["A"], os.environ["B"] = "one", "two"
    config = expand_env({"k": "${A}-${B}"})
    assert config["k"] == "one-two"


def test_expands_inside_nested_structures():
    os.environ["PW"] = "secret"
    config = expand_env({"users": [{"password": "${PW}"}], "n": 1, "b": True})
    assert config["users"][0]["password"] == "secret"
    assert config["n"] == 1 and config["b"] is True


def test_unset_variable_exits_5_naming_all_of_them():
    os.environ.pop("NOPE_ONE", None)
    os.environ.pop("NOPE_TWO", None)
    try:
        expand_env({"a": "${NOPE_ONE}", "b": "${NOPE_TWO}"})
    except SystemExit as exc:
        assert exc.code == 5
    else:
        raise AssertionError("expected SystemExit(5)")


def test_bare_dollar_is_left_alone():
    """Only the braced form is substituted, so a literal $ is safe."""
    os.environ["HOME"] = "/Users/x"
    assert expand_env({"k": "a$HOME-b"})["k"] == "a$HOME-b"


if __name__ == "__main__":
    failures = 0
    for name, fn in sorted(globals().items()):
        if name.startswith("test_") and callable(fn):
            try:
                fn()
                print(f"PASS {name}")
            except Exception as exc:
                failures += 1
                print(f"FAIL {name}: {exc}")
    sys.exit(1 if failures else 0)
