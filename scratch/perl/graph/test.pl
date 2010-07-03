#!/usr/bin/perl
use strict; use warnings;
use Scalar::Lazy;
use feature 'say';
use Data::Dumper;

# using the lazy "cyclic" programming technique from 
# http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.47.5723
# to turn an adjacency list into a graph, purely functionally

my @adj = (
    [ foo => 'bar', 'baz' ],
    [ bar => 'baz' ],
    [ baz => 'foo' ],
);
my $adj = list_to_stream( @adj );

sub get_pos {
    my ($item, $state) = @_;
    my %pos = %{ $state->{pos} };
    if (defined (my $pos = $pos{$item})) {
        return ($pos, $state)
    }
    else {
        my $pos     = $state->{count};
        return ($pos, { count => $pos+1, pos => { %pos, $item => $pos } });
    }
}

map_with_state(
    sub {
        my ($item, $state) = @_;
        my ($k, @v) = @$item;
        my (undef, $state2) = get_pos($k, $state);
        my ($v, $state3) = map_with_state(
            \&get_pos,
            list_to_stream(@v),
            $state2,
            [],
            sub {
                my ($list, $state) = @_;
                return ($list, $state);
            },
            );
        return ([$k, $v], $state3);
    },
    $adj,
    { count => 0, pos => {} },
    [],
    sub {
        my ($list, $state) = @_;
        my @adj3;
        @adj3 = map {
            my ($k, $v) = @$_;
            {
                name  => $k,
                links => [ map { my $i = $_; lazy { $adj3[$i] } } @$v ],
            }
        } @$list;

        use Test::More 'no_plan';
        my $foo = $adj3[0];
        is $foo->{name}, 'foo';

        my $bar = $foo->{links}[0];
        is $bar->{name}, 'bar';

        my $baz = $bar->{links}[0];
        is $baz->{name}, 'baz';

        my $foo2 = $baz->{links}[0];
        is $foo2->{name}, 'foo';
    });

##### various FP stuffs we have to define

# basic node/stream things

sub head { my $i = shift; $i->[0] }
sub tail { my $i = shift; $i->[1] }

# conversion functions, for convenience
sub list_to_stream {
    my ($head, @tail) = @_ or return;
    return [$head, lazy { list_to_stream(@tail) } ];
}
sub stream_to_list {
    my ($s) = @_;
    my @list;
    iterate( $s, sub { push @list, shift } );
    return @list;
}

sub iterate {
    my ($s, $f) = @_;
    return unless $s;
    $f->( head($s) );
    my $s2 = tail($s);
    iterate( $s2, $f );
}

# a monad-like thing to get the state (position counters) intermingled in a map
sub map_with_state { 
    my ($f, $s, $state, $list, $next) = @_;
    if ($s) {
        my ($head, $new_state) = $f->( head($s), $state );
        return map_with_state($f, tail($s), $new_state, [@{ $list || [] }, $head], $next);
    }
    else {
        return $next->( $list, $state );
    }
}

