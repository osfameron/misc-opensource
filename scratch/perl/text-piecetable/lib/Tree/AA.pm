=head1 NAME

Tree::AA - a simple, purely functional, balanced tree

=head1 SYNOPSIS

    my $tree = Tree::AA->new(
        cmp => sub { $_[0] <=> $_[1] }, # the default
    );
    $tree = $tree->insert( 5 => 'five' );
    $tree = $tree->insert( 10 => 'ten' );

    $tree = $tree->delete( 5 );

=head1 NOTES

Full descriptions of the algorithm are at
L<http://en.wikipedia.org/wiki/AA_tree>
and L<http://www.eternallyconfuzzled.com/tuts/datastructures/jsw_tut_andersson.aspx>

The latter especially was useful for details of the deletion implementation.

=cut

use Tree::AA::Node;
use Tree::AA::Node::NotEmpty;

package Tree::AA;
use Moo;
with 'MooX::Role::But';
use Types::Standard qw( InstanceOf CodeRef );

has root => (
    is => 'lazy',
    isa => InstanceOf['Tree::AA::Node'],
    default => sub { Tree::AA::Node->new },
);

has cmp => (
    is => 'lazy',
    default => sub { sub { $_[0] cmp $_[1] } },
    isa => CodeRef,
);

sub insert {
    my ($self, $key, $value, $merge_fn) = @_;
    return $self->but(
        root => $self->root->insert($self->cmp, $key, $value, $merge_fn)
    );
}

sub delete {
    my ($self, $key) = @_;
    return $self->but(
        root => $self->root->delete($self->cmp, $key)
    );
}

sub keys {
    my $self = shift;
    return $self->root->keys;
}

sub values {
    my $self = shift;
    return $self->root->pairs;
}

sub pairs {
    my $self = shift;
    return $self->root->pairs;
}

sub fmap {
    my ($self, $fn) = @_;
    return $self->root->fmap($fn);
}

sub filter {
    my ($self, $fn) = @_;
    return $self->root->filter($fn, $self->cmp);
}

sub fromList {
    my $class = shift;
    return $class->fromListWith(undef, @_);
}

sub fromListWith {
    my $class = shift;
    my $cmp = shift;
    my $tree = $class->new( $cmp ? ( cmp => $cmp ) : () );
    for my $pair (@_) {
        $tree = $tree->insert(@$pair); # key => value
    }
    return $tree;
}

sub fromSortedList {
    my $class = shift;
    return $class->fromSortedListWith(undef, @_);
}

sub fromSortedListWith {
    my $class = shift;
    my $cmp = shift; # but we ignore, as we assume that the list is sorted already
    my $root = $class->_fromSortedListWith(\@_, 0, scalar @_);
    return $class->new(
        root => $root,
        $cmp ? ( cmp => $cmp ) : (),
    );
}

my $NIL = Tree::AA::Node->new; # TODO, refactor with ::Node::NonEmpty

sub _fromSortedListWith {
    my ($class, $array, $from, $to) = @_;
    my $len = $to - $from or return $NIL;
    die "RARR $from - $to reversed" if $len < 0;
    if ($len == 1) {
        my $item = $array->[$from];
        return Tree::AA::Node::NonEmpty->new( 
            key => $item->[0],
            value => $item->[1]
        );
    }
    if ($len == 2) {
        my $item = $array->[$from];
        my $next = $array->[$from+1];
        return Tree::AA::Node::NonEmpty->new( 
            key => $item->[0],
            value => $item->[1],
            right => Tree::AA::Node::NonEmpty->new(
                key => $next->[0],
                value => $next->[1],
            ),
        );
    }
    my $pivot = int(($len-1) / 2); # 3-1/2=1, e.g. 2nd elem; 4-1/2=1, e.g. 2nd elem, so more elems on right hand side

    my $left  = $class->_fromSortedListWith($array, $from, $from + $pivot);
    my $right = $class->_fromSortedListWith($array, $from + $pivot+1, $to);

    my $item = $array->[$from + $pivot];
    return Tree::AA::Node::NonEmpty->new( 
        key => $item->[0],
        value => $item->[1],
        level => $left->level + 1,
        left => $left,
        right => $right,
    );
}

sub debug_tree {
    my $self = shift;
    "--------\n" . $self->root->debug_tree;
}
sub debug_check_invariants {
    my $self = shift;
    eval {
        $self->root->debug_check_invariants;
    };
    if ($@) {
        Test::More::diag ($@ . "\n" . $self->debug_tree);
        return 0;
    }
    return 1;
}

1;
