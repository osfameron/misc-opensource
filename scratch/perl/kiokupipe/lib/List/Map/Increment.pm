package List::Map::Increment;
use KiokuDB::Class;

extends 'List::Map';

sub transform {
    my ($self, $val) = @_;
    return $val+1;
}

1;
