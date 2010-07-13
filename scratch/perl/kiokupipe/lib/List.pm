package List;
use KiokuDB::Class;

my $empty;
sub empty { return $empty ||= List::Empty->new }

sub from_array {
    my $self = shift;
    my $class = (ref $self) || $self;
    if (@_) {
        my $head = shift;
        my $list = List::Node->new({
            head => $head,
            tail => scalar $class->from_array(@_),
        });
        return $list;
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

has 'tail' => (
    traits  => ['KiokuDB::Lazy'],
    is      => 'ro',
    isa     => 'List',
);

sub take {
    my ($list, $count) = @_;
    return () if $list->isEmpty;
    return () unless $count;
    return ($list->head, $list->tail->take($count-1));
}

sub While {
    my ($list, $f) = @_;
    return $list->empty if $list->isEmpty;
    my $head = $list->head;
    if ($f->($head)) {
        return List::Node->new({ head => $head, tail => scalar $list->tail->While($f) });
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
sub While { return __PACKAGE__->empty }

1;
