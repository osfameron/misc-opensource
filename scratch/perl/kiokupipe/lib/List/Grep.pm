package List::Grep;
use KiokuDB::Class;

extends 'List::Node';

has 'list' => (
    is  => 'rw',
    isa => 'List',
);

sub _list {
    my $self = shift;
    my $list = $self->list;

    my $reset_list;
    {
        last if $list->isEmpty;
        last if $self->filter( $list->head );
        $reset_list++;
        $list = $list->tail;
        redo;
    }
    $self->list($list) if $reset_list; # optimization: modify inplace
    return $list;
}

sub isEmpty {
    my $self = shift;
    return $self->_list->isEmpty;
}

has '+head' => (
    lazy => 1,
    default => sub { 
        my $self = shift;
        return $self->_list->head;
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

sub filter {
    my ($self, $val) = @_;
    return 1; # id
}

1;
