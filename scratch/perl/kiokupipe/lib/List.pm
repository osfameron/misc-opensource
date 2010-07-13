package List;
use KiokuDB::Class;

has 'head' => (
    is  => 'ro',
    isa => 'Any',
);

has 'tail' => (
    traits  => ['KiokuDB::Lazy'],
    is      => 'ro',
    isa     => 'Maybe[List]',
);

sub from_array {
    my $self = shift;
    my $class = (ref $self) || $self;
    if (@_) {
        my $head = shift;
        my $list = $class->new({
            head => $head,
            tail => scalar $class->from_array(@_),
        });
        return $list;
    }
    else {
        return;
    }
}

1;
