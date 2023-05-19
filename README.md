
# μstack (mikrostack)

**Notice!**
Some parts of this will be rewritten. Using Docker to implement this seems to cause some permission issues with the files, and also caused some other problems.

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/)

WordPress CLI tool for setupping new projects and themes inspired by [Trellis](https://roots.io/trellis/) and [dudestack](https://github.com/digitoimistodude/dudestack).

Specialized for the needs for the one-man WordPress-agency [Mikroni.fi](https://mikroni.fi). Utilizes [Bedrock](https://github.com/roots/bedrock) and [Sage](https://github.com/roots/sage) for now.

I used Trellis before, but I did not like the way it virtualized the servers (with VirtualBox and Vagrant). I have customized this utility to my personal preferences in development, so it might not be suitable for use by others, at least without modifications.

But if you find this toolkit useful in any way, feel free to use it. I have licensed it under MIT.

## Requirements

- Nginx
- MariaDB (if you want, you can use Docker with `docker compose up`)
- PHP 8.2 and Composer (you might also need php-xml, php-mysqli, php-curl, php-mbstring and other extensions that Composer and WordPress need)
- mkcert
  - libnss3-tools
- Node (16+ recommended) and NPM (or yarn)

If you are running Ubuntu (forks might work), you can just run: `scripts/ubuntu-setup.sh`.

## Usage

Coming soon.

## License

[MIT](https://choosealicense.com/licenses/mit/)
