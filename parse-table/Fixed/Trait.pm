#!/usr/bin/perl

package Fixed::Trait;
use Moose::Role;
use MooseX::Types::Moose      qw(Int);
use MooseX::Types::Structured qw(Tuple Optional);

has range => (
    is  => 'ro',
    isa => Tuple[Int, Optional[Int]],
    predicate => 'has_range',
    );

sub Moose::Meta::Attribute::Custom::Trait::Fixed { 'Fixed::Trait' };
}

1;
