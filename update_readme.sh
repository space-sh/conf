#!/usr/bin/env sh

space -m autodoc /export/ -- Spacefile.sh && \
    mv Spacefile.sh_README README.md && printf "README.md has been overwritten\n"
