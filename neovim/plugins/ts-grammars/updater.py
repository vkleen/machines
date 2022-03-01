import json, re, os, subprocess
from urllib.request import urlopen

grammars_path = os.path.join(os.getcwd(), "ts-grammars/grammars")
nix_prefetch_cmd = ["@nixPrefetchGit@", "--quiet", "--no-deepClone"]

lockfile_url = "https://raw.githubusercontent.com/nvim-treesitter/nvim-treesitter/master/lockfile.json"
lockfile_body = urlopen(lockfile_url).read()
lockfile_data = json.loads(lockfile_body.decode("utf-8"))

parsers_url = "https://raw.githubusercontent.com/nvim-treesitter/nvim-treesitter/master/lua/nvim-treesitter/parsers.lua"
parsers_re = re.compile(r'list.(\w+)\s=.*\s.*\s*url\s=\s"([^,]+)",',
                        re.MULTILINE)
parsers_body = urlopen(parsers_url).read()
parsers_code = parsers_body.decode("utf-8")

# contains parser name, and repo
parsers_data = parsers_re.findall(parsers_code)

parsers_data += [('norg_meta', 'https://github.com/nvim-neorg/tree-sitter-norg-meta')]
lockfile_data['norg_meta'] = {'revision': '8d9792bf94a22e4a1d0fdf6de52e099c471bf26e'}
parsers_data += [('norg_table', 'https://github.com/nvim-neorg/tree-sitter-norg-table')]
lockfile_data['norg_table'] = {'revision': '644fcd618463103566768e996e79b11c84cdfcd8'}

grammars_file_path = os.path.join(grammars_path, "default.nix")
with open(grammars_file_path, "w") as grammars_file:

    grammars_file.write("{\n")
    # phpdoc require tree-sitter-php as a node dependency, too much effort
    # todotxt is not in lockfile as of now (1.3.22)
    problematic_parsers = ["phpdoc", "todotxt"]

    for data in parsers_data:
        parser_name, parser_repo = data
        if parser_name in problematic_parsers:
            continue
        parser_rev = lockfile_data[parser_name]['revision']
        parser_file_path = os.path.join(grammars_path,
                                        f"tree-sitter-{parser_name}.json")

        grammars_file.write(f"  tree-sitter-{parser_name} = "
                            + "("
                            + "builtins.fromJSON ("
                            + f"builtins.readFile ./tree-sitter-{parser_name}.json"
                            + "));\n")

        try:
            with open(parser_file_path, "r") as f:
                old_rev = json.load(f)["rev"]
        except FileNotFoundError:
            old_rev = ""

        if old_rev == parser_rev:
            continue
        print(f"{parser_name}: {old_rev} -> {parser_rev}")

        nix_prefetch_args = ["--url", parser_repo, "--rev", parser_rev]
        with open(parser_file_path, "w") as f:
            subprocess.run(nix_prefetch_cmd + nix_prefetch_args, stdout=f)

    grammars_file.write("}")

abiVersion = open("@abiVersion@", "r").read()
with open(os.path.join(grammars_path, "abi-version.nix"), "w") as abiVersionFile:
    abiVersionFile.write(f"{{ abi-version = \"{abiVersion}\"; }}")
