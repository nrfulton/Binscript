Binscript
=========

This is my hack for replicating settings and useful bin scripts across
linux machines using git.

This repo contains the infrastructure for copying over configuration files
(e.g. .rc's) as well as your bin directory.

It's a hack that works well for me.

Dependencies
------------
 * Perl5
   * File::pushd and Path::Class, but these are replicated for easy of
     install.
 * git

Usage
-----
To setup:
 * Copy this source
 * Add your rc files to the rcfiles directory.
 * Modify the .gitconfig in the rcfiles directory.
 * Add your local bin to the root of this directory.
