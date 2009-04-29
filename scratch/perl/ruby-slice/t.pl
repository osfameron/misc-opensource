#!/usr/bin/perl
use strict; use warnings;
use Data::Dumper;

use feature 'switch';

package STRING;
use Scalar::Util 'looks_like_number';
our $RET;
sub slice :lvalue {
    my $string = shift;

    my ($start, $end, $length);
    given (my $index = shift) {
        when (ref eq 'Regexp') {
            warn "RE";
            if ($string=~/$_/) {
                ($start, $end) = ($-[0], $+[0]);
                $length = $end-$start;
            }
        }
        when (looks_like_number $_) {
            warn "NUM";
            ($start, $end) = ($_, shift);
            $length = $end ? $end-$start+1 : 1;
        }
        default {
            warn "DEF";
            # assume it's a string;
            if (my $start = index $string, $_) {
                $length = length $_;
            }
        }
    }
    if ($length) {
        substr $string, $start, $length; # lvalue
    } else {
        warn "EEEK";
        return
    }
}

use autobox STRING => 'STRING';
use Test::More tests => 5;

RANGE: {
    my $string = "Oh hello World";
    my $slice = $string->slice(3,7);
    is $slice, 'hello';
    $slice = 'hai';
    is $string, 'Oh hai world';
    $string->slice(3,7) = 'hai';
    is $string, 'Oh hai world';
}

INSTR: {
    my $string = "Oh hello World";
    my $slice = $string->slice('hello');
    is $slice, 'hello';
    $slice = 'hai';
    is $string, 'Oh hai world';
}

REGEXP: {
    my $string = "Oh hello World";
    my $slice = $string->slice(qw/h\w+/);
    is $slice, 'hello';
    $slice = 'hai';
    is $string, 'Oh hai world';
}
