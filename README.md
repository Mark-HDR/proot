# PRoot - Virtual Root Filesystem for Linux

`proot` is a tool that allows you to create and run a virtual root filesystem without requiring root privileges. It is commonly used for running software and emulating environments in a way that mimics a true root filesystem.

## Why Use PRoot?

PRoot provides a flexible and safe way to:

- **Run a Linux distribution inside another distribution**: You can run an Ubuntu-based system inside a CentOS, or even a different architecture like ARM on an x86 machine.
- **Create isolated environments (sandboxing)**: PRoot allows you to isolate applications or processes within a virtual environment without requiring root access.
- **Test software**: Developers can use PRoot to quickly set up different environments for testing without modifying the main system.
- **Run root-required applications**: Some applications require root access to run, and PRoot enables running them safely within a confined environment.

## Features

- **No Root Access Needed**: You can run a full Linux environment without needing `sudo` or root privileges.
- **Cross-architecture Emulation**: Supports running ARM binaries on x86_64, or other architectures.
- **Filesystem Redirection**: Redirects system calls to different root filesystems, enabling running of programs with different root filesystems.
- **Customizable Environments**: You can mount directories and bind resources, and run software in an isolated environment with its own set of libraries and dependencies.

## Installation

To use PRoot, follow these simple steps:

1. **Download PRoot** for your architecture. You can download it directly or compile from source.

   Example (download):
   ```bash
   wget https://raw.githubusercontent.com/foxytouxxx/freeroot/main/proot-${ARCH} -O /usr/local/bin/proot
   chmod +x /usr/local/bin/proot
