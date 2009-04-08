#!/usr/bin/perl

use strict;
use warnings;

#this is the test case from Acme::Gosub
use Test::More tests => 6;

use Acme::Gosub::DD;

sub factorial
{
    my $n = shift;

    my $prod = 1;
    gosub CALC;
    
    return $prod;
CALC:
    if ($n > 1)
    {
        $prod *= ($n--);
        gosub CALC;
    }
    greturn;
}

=begin TODO handle gosub (expr)

sub factorial2
{
    my $n = shift;

    my $prod = 1;
    gosub CALC;
    
    return $prod;
CALC:
    if ($n > 1)
    {
        $prod *= ($n--);
        gosub ("CALC");
    }
    greturn;
}


sub factorial3
{
    my $n = shift;

    my $prod = 1;
    gosub "CALC";
    
    return $prod;
CALC:
    if ($n > 1)
    {
        $prod *= ($n--);
        gosub "CA".uc("l")."C";
    }
    greturn;
}

=end

=cut

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
    greturn;
}

# TEST
is (factorial(3), 6, "factorial(3)");
# TEST
is (factorial(1), 1, "factorial(1)");
# TEST
is (factorial(4), 24, "factorial(4)");
# TEST
is (pythagoras(2,6), 40, "pyth(2,6)");
# TEST
is (pythagoras(1,1), 2, "pyth(1,1)");
# TEST
is (pythagoras(4,3), 25, "pyth(4,3)");
# TEST

__END__
is (factorial2(3), 6, "factorial2(3)");
# TEST
is (factorial2(1), 1, "factorial2(1)");
# TEST
is (factorial2(4), 24, "factorial2(4)");
# TEST
is (factorial3(3), 6, "factorial3(3)");
# TEST
is (factorial3(1), 1, "factorial3(1)");
# TEST
is (factorial3(4), 24, "factorial3(4)");


