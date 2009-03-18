#!/usr/bin/perl

package Fixed::Column;
use Moose::Role;
use MooseX::Types::Moose      qw(Int);
use MooseX::Types::Structured qw(Tuple Optional);
use Moose::Util::TypeConstraints;

subtype 'FromTo'
    => as Tuple[Int, Int];

has range => (
    is        => 'ro',
    isa       => 'FromTo',
    predicate => 'has_range',
    coerce    => 1,
    );

coerce 'FromTo'
    => from 'Int'
        => via { [($_)  x 2] }
    => from Tuple[Int]
        => via { [(@$_) x 2] };

sub Moose::Meta::Attribute::Custom::Trait::Column::register_implementation { 'Fixed::Column' };

1;
