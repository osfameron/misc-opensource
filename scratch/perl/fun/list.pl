#!/usr/bin/perl
use strict; use warnings;
{
    package List;
    use Sub::Call::Tail;

    sub to_string {
        my ($list, $acc) = @_;
        $acc ||= '';
        my $head = $list->head;
        my $tail = $list->tail;
        return "${acc}${head}" unless $tail;
        tail $tail->to_string( "${acc}${head}," );
    }
    sub to_string_it {
        my $list = shift;

        # fake tail recursion with iteration
        my $acc = '';
        {
            $acc .= $list->head;
            if (my $tail = $list->tail) {
                $acc .= ',';
                $list = $tail;
                redo
            }
        }
        return $acc;
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
}
{
    package List::List;
    our @ISA = 'List';
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
    sub tail {
        my $self = shift;
        my $array = $self->[0];
        my $offset = ($self->[1] || 0) + 1;
        if ($offset <= $#$array) {
            return bless [ $array, $offset ], 'List::Array';
        }
        else {
            return;
        }
    }
    sub nth {
        my ($self, $n) = @_;
        my ($list, $offset) = @$self;
        return $list->[$offset + $n];
    }
    sub to_string {
        my $self = shift;
        my ($list, $offset) = @$self;
        my @list = @$list[$offset..$#$list];
        return join ',' => @list;
    }
}

package main;
use Data::Dumper;
use feature 'say';
use Variable::Lazy;

sub node ($$) {
    return bless \@_, 'List::List';
}
sub list {
    my ($head, @tail) = @_
        or return;
    lazy my $tail = { list(@tail) };   # Variable::Lazy
    # my $tail = lazy { list(@tail) }; # Scalar::Lazy, and the others.  Caveats
    # my $tail = list(@tail);          # none (blows stack)
    return node $head, $tail;
}
sub array {
    return bless [\@_, 0], 'List::Array';
}

my @list = (1..1000);
my $list  = list(@list);
my $array = array(@list);
say $list->to_string;
say $array->to_string;

$list->to_string eq $array->to_string or die "EEEK!";

warn $array->nth(50);
warn $list->nth(50);

use Benchmark 'cmpthese';
my $ITERATIONS = 5_000;
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
