#!/usr/bin/perl
# Creates a symlink named bin in $HOME pointing here.
use strict;
use warnings;
use FindBin qw($Bin);
use lib $Bin . '/install_lib';
use Path::Class qw(file dir);
use Getopt::Long;

my $bin_dir = dir($ENV{'HOME'})->subdir('bin');
my $local_bin_dir = dir($ENV{'HOME'})->subdir('local_bin');

my $force = 0;
my $git_directory = dir($Bin)->parent->absolute();
GetOptions("-f!" => \$force,
           "-d=s"  => \$git_directory);

my $bin_clone = dir($git_directory);
die $bin_clone  . " DNE" unless -d $bin_clone;

# Move the bin to an alternative location if it already exists.
if(-e $bin_dir and not -l $bin_dir) {
    if(not $force) {
        print "$bin_dir exists, and will be moved (in)to $local_bin_dir. Continue (y/n): ";
        my $should_continue = <>;
        if($should_continue) {
            exit -1;
        }
    }
    
    my $cmd = "mv $bin_dir $local_bin_dir/";
    print $cmd . "\n";
    `$cmd`;
}

# Given above logic, guard ensure taht -l $bin_dir.
if(-e $bin_dir) {
    print "$bin_dir was a symlink.\n";
    print "rm $bin_dir\n";
    `rm $bin_dir`;
}

# Create symlink between clone and directory.
my $cmd = "ln -s $bin_clone $bin_dir";
print $cmd . "\n";
`$cmd`;
