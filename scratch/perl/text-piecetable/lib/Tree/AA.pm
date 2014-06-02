=head1 NAME

Tree::AA - a simple, purely functional, balanced tree

=head1 SYNOPSIS

    my $tree = Tree::AA->new(
        cmp => sub { $_[0] <=> $_[1] }, # the default
    );
    $tree = $tree->insert( 5 );
    $tree = $tree->insert( 10 );

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
