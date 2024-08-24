import json
import sys
import lupa
from lupa import LuaRuntime


def convert_packer_to_lazy(packer_config):
    lazy_config = {"variables": {}, "builders": [], "provisioners": []}

    # Convert variables
    if "variables" in packer_config:
        lazy_config["variables"] = dict(packer_config["variables"])

    # Convert builders
    if "builders" in packer_config:
        for builder in packer_config["builders"]:
            lazy_builder = {
                "name": builder.get("name", "default"),
                "type": builder.get("type", ""),
                "source": builder.get("source_ami", ""),
                "instance_type": builder.get("instance_type", ""),
                "ssh_username": builder.get("ssh_username", ""),
                "ami_name": builder.get("ami_name", ""),
            }
            lazy_config["builders"].append(lazy_builder)

    # Convert provisioners
    if "provisioners" in packer_config:
        for provisioner in packer_config["provisioners"]:
            lazy_provisioner = {
                "type": provisioner.get("type", ""),
                "inline": provisioner.get("inline", []),
                "script": provisioner.get("script", ""),
            }
            lazy_config["provisioners"].append(lazy_provisioner)

    return lazy_config


def load_lua_config(file_path):
    lua = LuaRuntime(unpack_returned_tuples=True)

    with open(file_path, "r") as file:
        lua_code = file.read()

    # Create a sandbox environment
    sandbox = lua.eval("{" + lua_code + "}")
    return sandbox


def main():
    if len(sys.argv) != 3:
        print("Usage: python script.py <input_packer_lua> <output_lazy_json>")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    try:
        packer_config = load_lua_config(input_file)
        lazy_config = convert_packer_to_lazy(packer_config)

        with open(output_file, "w") as f:
            json.dump(lazy_config, f, indent=2)

        print(f"Conversion complete. Lazy configuration saved to {
              output_file}")

    except Exception as e:
        print(f"An error occurred: {str(e)}")
        sys.exit(1)


if __name__ == "__main__":
    main()
