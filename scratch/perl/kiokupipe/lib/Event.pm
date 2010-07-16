package Event;
use KiokuDB::Class;
use MooseX::Types::DateTime;

has 'user' => (
    is  => 'ro',
    isa => 'Maybe[Object]',
);

has action => (
    is  => 'ro',
    isa => 'Str',
);

has datestamp => (
    is  => 'ro',
    isa => 'DateTime',
    default => sub { DateTime->now() },
);

has subject => (
    is => 'ro',
    isa => 'Maybe[Object]',
);
has object => (
    is => 'ro',
    isa => 'Any',
);

1;
