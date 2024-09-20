[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](http://www.gnu.org/licenses/gpl-3.0)

<div align="center">
  <span align="center"> <img width="128" height="128" class="center" src="data/icons/128.svg" alt="App Generator Icon"></span>
  <h1 align="center">App Generator</h1>
  <h3 align="center">Create an elementary OS app using one of the pre-made app templates</h3>
</div>

![Screenshot](https://raw.githubusercontent.com/elementary-community/app-generator/refs/heads/main/data/io.github.elementary-community.app-generator.png)

## Building and Installation

You'll need the following dependencies:
* glib-2.0
* gobject-2.0
* libgranite-7-dev
* libgtk-4-dev
* libadwaita-1-dev
* meson
* valac

Run `meson build` to configure the build environment. Change to the build directory and run `ninja` to build

```bash
meson build --prefix=/usr
cd build
ninja
```

To install, use `ninja install`, then execute with `io.github.elementary-community.app-generator`

```bash
ninja install
io.github.elementary-community.app-generator
```