package Feed;
use KiokuDB::Class;
use MooseX::Types::DateTime;
use Event;
use List;
use Scalar::Util 'refaddr';

has 'store_as' => (
    is  => 'rw',
    isa => 'Maybe[Str]',
);

has from_feed => (
    is  => 'ro',
    isa => 'Maybe[Str]',
);

has list => (
    is      => 'rw',
    isa     => 'List',
    default => sub { List->empty },
);

has make_list => (
    is  => 'rw',
    isa => 'CodeRef',
);

has from_feed_up_to => (
    is  => 'rw',
    isa => 'Maybe[Event]',
);

has from_root_up_to => (
    is => 'rw',
    isa => 'Maybe[Event]',
);

sub add_event {
    my ($self, $event) = @_;
    $self->list( $self->list->prepend($event) );
}

sub store {
    my ($self, $kioku) = @_;

    my $store_as = $self->store_as or return;
    $kioku->store( $store_as, $self );
}

sub up_to_date {
    my ($self, $kioku, $root) = @_;

    return 1 unless $self->from_feed;     # root list cannot be updated in this way
    return unless $self->from_root_up_to; # if new, then must be updated!
                                          # check if it's been updated
    return 1 if refaddr $root->list->head == refaddr $self->from_root_up_to;
}

sub update {
    my ($self, $kioku, $root) = @_;
    $root ||= $kioku->lookup('root');

    return if $self->up_to_date( $kioku, $root );

    my $from = $kioku->lookup( $self->from_feed );
    $from->update($kioku, $root);

    my $from_feed_up_to = $self->from_feed_up_to;
    my $new = $from_feed_up_to ?
        $from->list->While( sub { refaddr $_[0] != refaddr $from_feed_up_to })
        : $from->list;

    my $new_list = $self->make_list->( $new );

    my $whole_list = $new_list->concat($self->list);

    $self->list($whole_list);
    $self->from_feed_up_to( $from->list->head );
    $self->from_root_up_to( $root->list->head );
}

1;
