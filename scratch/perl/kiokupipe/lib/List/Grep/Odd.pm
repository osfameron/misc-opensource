package List::Grep::Odd;
use KiokuDB::Class;

extends 'List::Grep';


sub filter {
    my ($self, $val) = @_;
    return $val % 2;
}

1;
