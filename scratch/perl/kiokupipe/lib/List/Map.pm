package List::Map;
use KiokuDB::Class;

extends 'List';

has 'list' => (
    is  => 'ro',
    isa => 'List',
);

has '+head' => (
    lazy => 1,
    default => sub { 
        my $self = shift;
        $self->transform( $self->list->head ),
    },
);

has '+tail' => (
    lazy => 1,
    default => sub {
        my $self = shift;
        my $class = (ref $self) || $self;
        if (my $tail = $self->list->tail) {
            return $class->new( list => $tail );
        }
        else {
            return;
        }
    },
);

sub transform {
    my ($self, $val) = @_;
    return $val; # id
}

1;
