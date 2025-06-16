# rpc

`rpc` is a lightweight command-line tool for storing, listing, checking, and
retrieving named RPC endpoints.

---

## Features

- `rpc --add <name>`: Save a new RPC by name
- `rpc <name>`: Print the saved RPC URL. If called in a non-tty (like `$(rpc <name>)`, it will omit the trailing newline character)
- `rpc --list`: Show a list of saved RPCs.
- Fully local: all data saved in a plain text file at `$XDG_CONFIG_HOME/rpc/list` (or `$HOME/.config/rpc/list` if `$XDG_CONFIG_HOME` is not set)

---

## Install

> Built with Zig. You can build from source or download a binary from the releases section (coming soon).

```sh
git clone https://github.com/Mouradif/rpc-cli
cd rpc-cli
zig build --release=fast
cp zig-out/bin/rpc ~/.local/bin # Or any directory in your $PATH
```

---

## Usage

```sh
$ rpc --add eth   # prompts for URL and saves it as "eth"
```

```sh
$ rpc eth         # prints the previously saved RPC URL with a trailing newline character
```

```sh
$ rpc --list      # shows list of all saved RPCs
```

---

## File Format

Your saved RPCs are stored line-by-line in:

```
~/.config/rpc/list
```

Each line has the format:

```
name|url
```

Example:
```
mainnet|https://mainnet-url
sepolia|https://sepolia-url
```

---

## Example with `cast`

Use `rpc` in shell scripts or with tools like [`cast`](https://getfoundry.sh/cast/overview#cast):

```sh
$ cast chain-id -r $(rpc mainnet)
```

---

## Clean. Minimal. Yours.

No tracking, no dependencies, no network requests — just a nice wrapper around your favorite endpoints.

## License

MIT
