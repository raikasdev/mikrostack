
# μstack (mikrostack)

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/)

A [Bun](https://bun.sh)-powered WordPress toolkit for setupping new projects and themes inspired by [Trellis](https://roots.io/trellis/) and [dudestack](https://github.com/digitoimistodude/dudestack).

Specialized for the needs for the one-man WordPress-agency [Mikroni.fi](https://mikroni.fi). Utilizes [Bedrock](https://github.com/roots/bedrock) and [Sage](https://github.com/roots/sage).

I used Trellis before, but I did not like the way it virtualized the servers (with VirtualBox and Vagrant). I have specialized this utility to my personal needs in development, so it might not be suitable for use by others.

But if you find this toolkit useful in any way, feel free to use it. I have licensed it under MIT.

## Requirements

- Docker
- Bun.sh*
- PHP 8.2 and Composer (you might need to install php-xml, php-mysqli, php-curl, php-mbstring and other extensions that Composer and WordPress need)
- mkcert*

\* = will be installed by the script if not installed on Ubuntu

## Usage

- Download the repository
- Add `bin` to PATH
- Run `./generate-certs.sh` to generate SSL certs
- Use `wp start` to start the environment

## Why bun?

[Bun](https://bun.sh) is an **incredibly fast** JavaScript runtime, almost a drop-in replacement for Node.js.

I haven't written many bash scripts before, but I do know JavaScript. `yargs` allows me to create CLI tools easily.

I also wanted to experiment more with Bun. Bunx is 100x times than npx, and the package manager is 30x faster.

## Why not run the services locally (like [dude's LEMP stack](https://github.com/digitoimistodude/macos-lemp-setup))

I code other stuff that WordPress websites, where I have to run databases and proxies (usually with nginx), and I like them in container instead of running them on my machine, instead of having to configure ports everywhere and stuff like that.

## License

[MIT](https://choosealicense.com/licenses/mit/)
