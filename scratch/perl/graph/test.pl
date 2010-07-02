#!/usr/bin/perl
use strict; use warnings;
use Data::Dumper;

# using the lazy "cyclic" programming technique from 
# http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.47.5723
# to turn an adjacency list into a graph, purely functionally

my @adj = (
    [ foo => 'bar', 'baz' ],
    [ bar => 'baz' ],
    [ baz => 'foo' ],
);

# actually this bit isn't quite purely functional, as we're updating $pos and %seen.  Perhaps
# should use a state monad...
my @adj2 = do {
    my $pos = 0;
    my %seen;
    map {
        my ($k, @v) = @$_;
        $seen{$k} //= $pos++;
        my @v2 = map {
            $seen{$_} //= $pos++;
        } @v;
        [$k => @v2];
    } @adj
    };

use Scalar::Lazy;
my @adj3;
@adj3 = map {
    my ($k, @v) = @$_;
    {
        name  => $k,
        links => [ map { my $i = $_; lazy { $adj3[$i] } } @v ],
    }
} @adj2;

use Test::More 'no_plan';
my $foo = $adj3[0];
is $foo->{name}, 'foo';

my $bar = $foo->{links}[0];
is $bar->{name}, 'bar';

my $baz = $bar->{links}[0];
is $baz->{name}, 'baz';

my $foo2 = $baz->{links}[0];
is $foo2->{name}, 'foo';
