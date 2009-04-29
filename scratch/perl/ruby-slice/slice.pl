#!/usr/bin/perl
use strict; use warnings;

package STRING;
use Scalar::Util 'looks_like_number';

sub slice :lvalue {
    # we must refer to $string as $_[0] for it to be honoured outside sub!
    my ($index, $end) = @_[1,2];
    my ($start, $length);

=for GIVEN
    # This doesn't work
    use feature 'switch';
    given ($index) {
        when (ref eq 'Regexp') {
            if ($_[0]=~/$_/) {
                ($start, $end) = ($-[0], $+[0]);
                $length = $end-$start;
            }
        }
        when (looks_like_number($_)) {
            ($start, $end) = ($_, $alt);
            $length = $end ? $end-$start+1 : 1;
        }
        default {
            # assume it's a string;
            if (my $start = index $_[0], $_) {
                $length = length $_;
            }
        }
    }

=cut

    if (ref $index eq 'Regexp') {
        if ($_[0]=~/$index/) {
            ($start, $end) = ($-[0], $+[0]);
            $length = $end-$start;
        }
    }
    elsif (looks_like_number($index)) {
        ($start, $length) = ($index, $end-$index+1);
    }
    else {
        if ($start = index $_[0], $index) {
            $length = length $index;
        }
    }

    if ($length) {
        substr $_[0], $start, $length; # lvalue, so no return
    } else {
        undef
    }
}

use autobox STRING => 'STRING';
use Test::More tests => 6;

RANGE: {
    my $string = "Oh hello World";
    is $string->slice(3,7), 'hello';
    $string->slice(3,7) = 'hai';
    is $string, 'Oh hai World';
}

INSTR: {
    my $string = "Oh hello World";
    is $string->slice('hello'), 'hello';
    $string->slice('hello') = 'hai';
    is $string, 'Oh hai World';
}

REGEXP: {
    my $string = "Oh hello World";
    is $string->slice(qr/h\w+/), 'hello';
    $string->slice(qr/h\w+/) = 'hai';
    is $string, 'Oh hai World';
}

__END__

As per Ruby's crack-fueled string indexing, via Caius:

a = "hello world"

a['hello'] # => "hello"
a[/h\w+/]  # => "hello"
a[0..4]    # => "hello"
a[0...5]   # => "hello"
a[0,5]     # => "hello"

__END__

sub simple :lvalue {
    substr $_[0], $_[1], $_[2];
}

SANITY: {
    my $string = "Oh hello World";
    is $string->simple(3,5), 'hello';
    $string->simple(3,5) = 'hai';
    is $string, 'Oh hai World';
}
