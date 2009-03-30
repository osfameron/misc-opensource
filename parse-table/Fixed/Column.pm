#!/usr/bin/perl

package Fixed::Column;
use Moose::Role;
use MooseX::Types::Moose      qw(Int);
# use MooseX::Types::Structured qw(Tuple Optional);
use Moose::Util::TypeConstraints;

has width => (
    is        => 'ro',
    isa       => 'Int',
    );

sub Moose::Meta::Attribute::Custom::Trait::Column::register_implementation { 'Fixed::Column' };

1;
