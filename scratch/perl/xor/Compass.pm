package Compass::Axis;
use Moose;
use MooseX::LazyValue;
use MooseX::Types::Moose qw/ Str ArrayRef /;
use Data::Dumper;

has name => (
    is => 'ro',
    isa => Str,
    );
has directions => (
    metaclass => 'LazyValue',
    is        => 'ro',
    isa       => ArrayRef['Compass::Direction'],
    );

package Compass::Direction;
use Moose;
use MooseX::LazyValue;
use MooseX::Types::Moose      qw/ Int Str /;
use MooseX::Types::Structured qw/ Tuple /;

has name => (
    is => 'ro',
    isa => Str,
    );
has opposite => (
    metaclass => 'LazyValue',
    is        => 'ro',
    isa       => __PACKAGE__,
    );

has clockwise90 => (
    metaclass => 'LazyValue',
    is        => 'ro',
    isa       => __PACKAGE__,
    );

has anticlockwise90 => (
    metaclass => 'LazyValue',
    is        => 'ro',
    isa       => __PACKAGE__,
    );

has delta => (
    is  => 'ro',
    isa => Tuple[Int,Int],
    );
has axis => (
    is  => 'ro',
    isa => 'Compass::Axis',
    );

package Compass;

my ($horizontal, $vertical,        # axes
    $north, $south, $east, $west); # directions

BEGIN {
    $horizontal = Compass::Axis->new(
        name        => 'horizontal',
        directions => sub { [$west, $east ] },
        );
    $vertical = Compass::Axis->new(
        name        => 'vertical',
        directions => sub { [$north, $south] },
        );

    $west = Compass::Direction->new(
        name            => 'west',
        delta           => [ 0, -1 ],
        axis            => $horizontal,
        opposite        => sub { $east },
        clockwise90     => sub { $north },
        anticlockwise90 => sub { $south },
        );
    $east = Compass::Direction->new(
        name            => 'east',
        delta           => [ 0, 1 ],
        axis            => $horizontal,
        opposite        => sub { $west },
        clockwise90     => sub { $south },
        anticlockwise90 => sub { $north },
        );
    $north = Compass::Direction->new(
        name            => 'north',
        delta           => [ -1, 0 ],
        axis            => $vertical,
        opposite        => sub { $south },
        clockwise90     => sub { $east },
        anticlockwise90 => sub { $west },
        );
    $south = Compass::Direction->new(
        name            => 'south',
        delta           => [ 1, 0 ],
        axis            => $vertical,
        opposite        => sub { $north },
        clockwise90     => sub { $west },
        anticlockwise90 => sub { $east },
        );
}
use constant HORIZONTAL => $horizontal;
use constant VERTICAL   => $vertical;
use constant NORTH      => $north;
use constant SOUTH      => $south;
use constant EAST       => $east;
use constant WEST       => $west;

1;
