#!/usr/bin/perl
use strict; use warnings;
use Test::More tests => 1;

use Acme::Gosub::DD;

# from the Acme::Gosub POD
sub pythagoras
{
    my ($x, $y) = (@_);
    my ($temp, $square, $sum);
    $sum = 0;
    $temp = $x;
    gosub SQUARE;
    $sum += $square;
    $temp = $y;
    gosub SQUARE;
    $sum += $square;
    return $sum;

SQUARE:
    $square = $temp * $temp;
    retsub;
}

is pythagoras(3,4), 25, 'Example gosubs work';
