import subprocess
import sys
import logging
import yaml
import jinja2
import pwd
from jinja2 import FileSystemLoader


def render_init_config():
    env = jinja2.Environment(
        loader=FileSystemLoader('./'),
    )
    # load template
    try:
        int_template = env.get_template(f"{sys.path[0]}/smb.conf.j2")
    except jinja2.TemplateNotFound as err:
        print(f" The template {err} does not exist")
        exit(1)

    try:
        with open(file=f"{sys.path[0]}/config.yaml") as f:
            config = yaml.load(f, Loader=yaml.FullLoader)
    except FileNotFoundError as err:
        print(f"File {err} not found")
        exit(2)

    logging.info("writing smb.conf")
    with open(file="/etc/samba/smb.conf", mode="w") as f:
        if not f.writable():
            logging.error("smb.conf is not writable")
            exit(4)
        f.write(int_template.render(config))

    if len(config["users"]) > 0:
        for user in config["users"]:
            user_add(user)




def user_add(user_config):
    try:
        pwd.getpwnam(user_config['name'])
        # user already exist, let's delete it from samba share and re add it just in case
        # todo: handle it in a better way
        cmd = ["smbpasswd", "-x", user_config['name']]
        exec_cmd(cmd)

    except KeyError:
        logging.info(f"user {user_config['name']} doesn't exist, creating")
        cmd = ["adduser", "--no-create-home", "-D"]

        # do we want to define the uid?
        if "id" in user_config:
            cmd.append("--uid")
            cmd.append(str(user_config["id"]))

        if "group" in user_config:
            cmd.append("--ingroup")
            cmd.append(str(user_config["group"]))

        cmd.append(user_config["name"])
        exec_cmd(cmd)

    # assign password
    # cmd = ["passwd", user_config["name"], "-d", user_config["password"]]
    # exec_cmd(cmd)

    cmd = ["smbpasswd", "-s", "-a", user_config["name"]]
    exec_cmd(cmd, f"{user_config['password']}\n{user_config['password']}\n")


def exec_cmd(cmd, input_arg=None):
    logging.info(f"Running {cmd}")
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=subprocess.PIPE, encoding="utf-8")
    output, error = p.communicate(input=input_arg)
    if p.returncode != 0:
        print(f"Error running {cmd}\nReturn Code: {p.returncode}\nError: {error}\nOutput: {output}")
        exit(3)

    return output

if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)
    render_init_config()
