#!/usr/bin/perl

package Fixed::Column;
use Moose::Role;
use MooseX::Types::Moose      qw(Int);
use MooseX::Types::Structured qw(Tuple Optional);

has range => (
    is  => 'ro',
    isa => Tuple[Int, Optional[Int]],
    predicate => 'has_range',
    );

sub Moose::Meta::Attribute::Custom::Trait::Column::register_implementation { 'Fixed::Column' };

1;
