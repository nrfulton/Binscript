#!/usr/bin/perl
# Creates a symlink to each RC file in user's home directory.
# You probably want to run install/install.pl, which is a wrapper around this.
use strict;
use warnings;
use FindBin qw/$Bin/;
use lib $Bin . "/../install/install_lib";
use Path::Class qw/dir file/;
use Getopt::Long;

# Ensure that the home directory exists.
die unless -e $ENV{'HOME'};

my $force; # ignore warnings.
my $help;
GetOptions("f!" => \$force,
           "h!" => \$help);

# Display help message if requested.
if($help) {
    print "Usage: " . file($0)->cleanup->basename . " [-fh]\n" .
          "\t-h : Show this message.\n" .
          "\t-f : Skip confirmation dialogs.\n";
    exit;
}

copy_config_directory( dir($Bin) );
print "\nDone creating symlinks.\n";

# Re-source bashrc, since it might've changed.
print "Sourcing .bashrc\n";
`. ~/.bashrc 2> /dev/null`;

exit 0;

# Create symlinks to each file in $HOME, prompting if the file exists 
# unless --force has been requested.
sub copy_config_directory {
    my $directory = shift; # Directory to be copied.

    # All nodes except those with names matching this script.
    my @nodes = 
    grep { 
        $_->basename ne file($0)->cleanup->basename 
    } map { 
        -f $_ ? file($_) : dir($_) 
    } $directory->children;

    foreach my $node (@nodes) {
        if(not $node->is_dir) {
            # Find the target path based on the rel. location of directory in
            # $Bin
            my $target_path = $ENV{'HOME'} . relative_to($directory, dir($Bin));
            `mkdir -p $target_path`;

            # This is the symlink destination.
            my $target = dir($target_path)->file($node->basename);

            # Handle the case where the target already exists.
            if(-e $target) {
                if(should_delete_file($target)) {
                    print "rm -f $target\n";
                    `rm -f $target`;
                }
                else {
                    print "Skipping $target as requested.\n";
                    next; # Do not create the symlink.
                }
            }

            # Finally, create the symlink.
            my $cmd = "ln -s " . $node->absolute . " " . $target->absolute;
            print $cmd . "\n";
            `$cmd`;
        }
        else {
            copy_config_directory($node);
        }
    }
}

sub should_delete_file {
    my $target = shift;
    if($force) {
        return 1;
    }
    else {
        if(-e $target) {
            my $in = 'n';
            print "$target exists. Overwrite (y/n)? ";
            $in = <>; chomp $in;
            return ($in eq "y");
        }
        else {
            return 0;
        }
    }
}

sub relative_to {
    my($left, $right) = @_;

    my $left_text = $left->cleanup->absolute;
    my $right_text = $right->cleanup->absolute;

    $left_text =~ s/^$right_text//;
    return $left_text;
}

