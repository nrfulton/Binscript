#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw/$Bin/;
use lib $Bin . '/install_lib/';
use Path::Class qw/file dir/;
use File::pushd qw(pushd);

# Create a symlink $HOME/bin -> git repo.
run_in(
    cmd => dir($Bin)->file('build_bin_symlink.pl')->absolute() . " -f", 
    cwd => dir($Bin)
);

# Create symlinks $HOME/.*rc -> git repo/rc_files/.*rc.
run_in(
    cmd => dir($Bin)->parent->subdir('rc_files')->file('build_rc_symlinks.pl')->absolute() 
        .  " -f" ,
    cwd => dir($Bin)->parent->subdir('rc_files')
);

# Run additional install scripts here.


# Runs cmd in cwd.
sub run_in {
    my (%args) = @_;
    my $cwd = delete $args{'cwd'};
    my $cmd = delete $args{'cmd'};
	
    die 'Need cmd' unless defined $cmd;

    if(defined $cwd) {
        pushd($cwd);
    }

    print "$cmd\n";
    my $result = `$cmd`;
    foreach my $line (split /\n/, $result) {
        print "\t" . $line . "\n";
    }
}

