package List;
use KiokuDB::Class;

my $empty;
sub empty { return $empty ||= List::Empty->new }

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

sub take {
    my ($list, $count) = @_;
    return () unless $count;
    return ($list->head, $list->tail->take($count-1));
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
sub take  { return () }
sub Map   { return shift }
sub Grep  { return shift }
sub While { return __PACKAGE__->empty }

1;
