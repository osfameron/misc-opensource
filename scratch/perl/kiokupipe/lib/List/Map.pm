package List::Map;
use KiokuDB::Class;

extends 'List::Node';

has 'list' => (
    is  => 'ro',
    isa => 'List',
);

sub isEmpty {
    my $self = shift;
    return $self->list->isEmpty;
}

has '+head' => (
    lazy => 1,
    default => sub { 
        my $self = shift;
        my $val = $self->list->head;
        $self->transform( $self->list->head ),
    },
);

has '+tail' => (
    traits => ['KiokuDB::Lazy'],
    lazy => 1,
    default => sub {
        my $self = shift;
        my $class = (ref $self) || $self;
        if ($self->isEmpty) {
            return $self->empty;
        }
        else {
            return $class->new( list => $self->list->tail );
        }
    },
);

sub transform {
    my ($self, $val) = @_;
    return $val; # id
}

1;
