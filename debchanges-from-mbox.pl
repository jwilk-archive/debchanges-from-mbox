#!/usr/bin/perl

# Copyright © 2012, 2023 Jakub Wilk <jwilk@jwilk.net>
# SPDX-License-Identifier: MIT

use strict;
use warnings;

use feature qw(say);

use MIME::QuotedPrint;

my $message;
{
    local $/ = undef;
    $message = <STDIN>;
}

$message =~ s/\r//g;
$message =~ s/^.*?\n\n//s;
$message = decode_qp($message);
$message =~ s/\s+$/\n/;

my ($source) = ($message =~ /^Source:\s+(\S+)\s*$/m);
die if $source =~ m{/};
my ($version) = $message =~ /^Version:\s+(\S+)\s*$/m;
die if $version =~ m{/};
my $no_epoch_version = $version;
$no_epoch_version =~ s/^.*?://;

my ($architectures) = $message =~ /^Architecture:\s+(.+\S)\s*$/m;
my %architectures = map { $_ => 1 } split(/\s+/, $architectures);
my $pseudoarch = 'multi';
if (scalar(keys %architectures) > 1) {
    delete $architectures{source};
}
if (scalar(keys %architectures) > 1) {
    delete $architectures{all};
}
if (scalar(keys %architectures) == 1) {
    ($pseudoarch) = keys %architectures; 
}
die if $pseudoarch =~ m{/};

my $filename = "${source}_${no_epoch_version}_${pseudoarch}.changes";
say STDERR $filename;
open(my $fh, '>', $filename) or die;
print $fh $message;
close($fh) or die;

# vim:ts=4 sts=4 sw=4 et
