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

=for LATER
has clockwise90 => (
    is  => 'ro',
    isa => __PACKAGE__,
    );
has anticlockwise90 => (
    is  => 'ro',
    isa => __PACKAGE__,
    );

=cut

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

$horizontal = Compass::Axis->new(
    name        => 'horizontal',
    directions => sub { [$west, $east ] },
    );
$vertical = Compass::Axis->new(
    name        => 'vertical',
    directions => sub { [$north, $south] },
    );

$west = Compass::Direction->new(
    name     => 'west',
    opposite => sub { $east },
    delta    => [0,-1],
    ); 
$east = Compass::Direction->new(
    name     => 'east',
    opposite => sub { $west },
    delta    => [0,1],
    ); 

use Data::Dumper;
warn $west->opposite;
warn $west->name;
warn Dumper($west, $west->opposite, $horizontal);

1;
