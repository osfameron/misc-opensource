#!/usr/bin/perl

use MooseX::Declare;

class Foo with MooseX::Clone {
    use MooseX::Pure;

    has 'foo' => (
        is => 'pure',
      );
    has 'bar' => (
        is => 'pure',
      );
    has 'baz' => (
        is => 'pure',
      );
}

use Data::Dumper;

my $x = Foo->new( foo=> 'foo', bar => 'bar', baz => 'baz' );
my $y = $x->foo('newfoo')->baz('newbaz');

warn Dumper($x, $y);
warn Dumper( $x->foo, $y->foo );
