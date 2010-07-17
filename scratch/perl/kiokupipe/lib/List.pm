package List;
use KiokuDB::Class;

my $empty;
sub empty { return $empty ||= List::Empty->new }

sub Prepend {
    my ($self, $head) = @_;
    return List->node($head, $self);
}

sub node {
    my $class = shift;
    return $class->empty unless @_;
    my ($head, $tail) = @_;
    $tail ||= $class->empty;

    return List::Node->new({
        head  => $head,
        _tail => $tail,
        });
}

sub from_array {
    my $self = shift;
    my $class = (ref $self) || $self;
    if (@_) {
        my $head = shift;
        return List->node( $head, scalar $class->from_array(@_));
    }
    else {
        return $class->empty;
    }
}

package List::Node;
use KiokuDB::Class;

use lib '/home/hakim/other_repos/data-thunk/';
use Data::Thunk;

extends 'List';

sub isEmpty { 0 }

has 'head' => (
    is  => 'ro',
    isa => 'Any',
);

has '_tail' => (
    traits  => ['KiokuDB::Lazy'],
    is      => 'rw',
    isa     => 'List | CodeRef',
);

sub Map {
    my ($self, $f) = @_;

    return List->node(
        $f->($self->head),
        sub {
            $self->tail->Map($f)
        });
}
sub Grep {
    my ($self, $f) = @_;

    my $head = $self->head;

    return $f->($head) ?
        List->node(
            $head, 
            sub {
                $self->tail->Grep($f)
            }) 
        : $self->tail->Grep($f);
}
sub Foldl {
    my ($self, $f, $init) = @_;
    return $self->tail->Foldl( $f, $f->( $init, $self->head ) );
}
sub Foldr {
    # f x (foldr f z xs)
    my ($self, $f, $init) = @_;
    return $f->(
        $self->head,
        $self->tail->Foldr( $f, $init )
        );
}
sub Cycle {
    my ($self, $list) = @_;
    return List->node ($self->head, sub { $self->tail->Cycle($list || $self) });
}

sub Concat {
    my ($self, $list) = @_;
    return $self->Foldr( sub { $_[1]->Prepend($_[0]) }, $list );
}

sub tail {
    my $self = shift;
    my $tail = $self->_tail;
    if (ref $tail eq 'CODE') {
        my $newtail = $tail->($self);
        $self->_tail($newtail);
        return $newtail;
    }
    else {
        return $tail;
    }
}

sub to_array {
    my ($list) = @_;
    return ($list->head, $list->tail->to_array);
}
sub Take {
    my ($list, $count) = @_;
    return $list->empty unless $count;
    return List->node($list->head, $list->tail->Take($count-1));
}

sub While {
    my ($list, $f) = @_;
    my $head = $list->head;
    if ($f->($head)) {
        return List->node( $head, scalar $list->tail->While($f));
    }
    else {
        return $list->empty;
    }
}

package List::Empty;
use KiokuDB::Class;
extends 'List';

sub isEmpty { 1 }

sub head  { die "Empty lists have no head" }
sub tail  { die "Empty lists have no tail" }
sub to_array { return () }
sub Take  { return shift }
sub Map   { return shift }
sub Grep  { return shift }
sub While { return __PACKAGE__->empty }
sub Concat {
    my ($self, $list) = @_;
    return $list;
}
sub Foldl {
    my ($self, $f, $init) = @_;
    return $init;
}
sub Foldr {
    my ($self, $f, $init) = @_;
    return $init;
}
sub Cycle {
    my ($self, $list) = @_;
    return $list->Cycle();
}

1;
