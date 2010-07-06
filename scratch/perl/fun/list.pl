#!/usr/bin/perl
use strict; use warnings;
use lib '/home/hakim/other_repos/data-thunk/lib/';
{
    package List;
    use Sub::Call::Tail;
    use Data::Thunk;
    sub new {
        my $class = shift;
        return bless \@_, $class;
    }

    sub to_string {
        my ($list, $acc) = @_;
        $acc ||= '';
        my $head = $list->head;
        my $tail = $list->tail;
        return "${acc}${head}" unless $tail;
        tail $tail->to_string( "${acc}${head}," );
    }

    sub drop {
        my ($x, $list) = @_;
        if ($x ==0) {
            return $list;
        }
        else {
            return drop($x-1, $list->tail);
        }
    }

    sub nth {
        my ($list, $n) = @_;
        if ($n) {
            return $list->tail->nth($n-1);
        }
        else {
            return $list->head;
        }
    }
    sub init {
        my $list = shift;
        if (my $tail = $list->tail) {
            return List::List::node(
                $list->head, lazy { $tail->init }
                );
        }
        else {
            return;
        }
    }
}
{
    package List::List;
    our @ISA = 'List';
    use Data::Thunk;

    sub node ($$) {
        # return bless \@_, 'List::List';
        return lazy_new 'List::List', args => \@_; # Data::Thunk
    }

    sub head {
        my $list = shift or return;
        return $list->[0];
    }
    sub tail {
        my $list = shift or return;
        return $list->[1];
    }
}
{
    package List::Array;
    our @ISA = 'List';
    sub head {
        my $self = shift;
        return $self->[0]->[ $self->[1] || 0 ];
    }
    sub maxbound {
        my $self = shift;
        my $array = $self->[0];
        return $self->[2] || $#$array;
    }
    sub tail {
        my $self = shift;
        my $array    = $self->[0];
        my $offset   = ($self->[1] || 0) + 1;
        my $maxbound = $self->maxbound;
        if ($offset <= $maxbound) {
            return bless [ $array, $offset, $maxbound ], 'List::Array';
        }
        else {
            return;
        }
    }
    sub init {
        my $self = shift;
        my $array    = $self->[0];
        my $offset   = ($self->[1] || 0);
        my $maxbound = $self->maxbound;
        if ($maxbound > $offset) {
            return bless [ $array, $offset, $maxbound-1 ], 'List::Array';
        }
        else {
            return;
        }
    }
    sub nth {
        my ($self, $n) = @_;
        my ($list, $offset) = @$self;
        my $maxbound = $self->maxbound;
        die if $offset+$n > $maxbound;
        return $list->[$offset + $n];
    }
    sub to_string {
        my $self = shift;
        my ($list, $offset) = @$self;
        my $maxbound = $self->maxbound;
        my @list = @$list[$offset..$maxbound];
        return join ',' => @list;
    }
}

package main;
use Data::Dumper;
use feature 'say';
# use Variable::Lazy;
use Data::Thunk;
# use Scalar::Defer; # too fucking slow, deep recursion in global destruction
# use Scalar::Lazy; # doesn't defer to methods

sub node ($$) {
    # return bless \@_, 'List::List';
    return lazy_new 'List::List', args => \@_; # Data::Thunk
}
sub list {
    my ($head, @tail) = @_
        or return;
    # lazy my $tail = { list(@tail) };   # Variable::Lazy
    # my $tail = lazy { list(@tail) }; # Scalar::Lazy, and the others.  Caveats
    my $tail = lazy_object { list(@tail) } class=>'List::List'; # Data::Thunk
    # my $tail = list(@tail);          # none (blows stack)
    return node $head, $tail;
}
sub array {
    return bless [\@_, 0], 'List::Array';
}

my $test = list(1..10);
say $test->to_string;
say $test->init->to_string;
my $test2 = array(1..10);
say $test2->to_string;
say $test2->init->to_string;

my @list = (1..10_000);
my $list  = list(@list);
my $array = array(@list);
say $list->to_string;
say $array->to_string;

$list->to_string eq $array->to_string or die "EEEK!";

warn $array->nth(50);
warn $list->nth(50);

use Benchmark 'cmpthese';
my $ITERATIONS = -2; # run for 2 seconds
cmpthese $ITERATIONS => { # 8333, 14286
    list_create  => sub { my $list  = list(@list);  },
    array_create => sub { my $array = array(@list); },
};
cmpthese $ITERATIONS => {
    list_to_string  => sub { $list->to_string },
    array_to_string => sub { $array->to_string },
};
cmpthese $ITERATIONS => {
    list_nth  => sub { $list->nth(50) },
    array_nth => sub { $array->nth(50) },
};
