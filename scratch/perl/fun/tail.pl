#!/usr/bin/perl
use strict; use warnings;
use feature 'say';
use Test::More 'no_plan';
use Sub::Call::Tail;

sub tail1 {
    my $n = shift or return '';
    return $n . tail1($n-1);
}
sub tail2 {
    my $n = shift or return '';
    return $n . tail tail2($n-1);  # naive version.  Doesn't work
}
sub tail3 {
    my ($n, $acc) = @_; # have to insert explicit accumulator
    return $acc unless $n;
    $acc ||= '';
    tail tail3($n-1, "$acc$n");
}

is tail1( 4 ), '4321';
is tail2( 4 ), '4321';
is tail3( 4 ), '4321';
