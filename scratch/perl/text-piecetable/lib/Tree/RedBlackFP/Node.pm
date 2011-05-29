package Tree::RedBlackFP::Node;
use Moose;

extends 'Tree::RedBlackFP';

has left => (
    is  => 'ro',
    isa => 'Tree::RedBlackFP',
    default => sub { shift->empty },
);
has right => (
    is  => 'ro',
    isa => 'Tree::RedBlackFP',
    default => sub { shift->empty },
);

has data => ( is => 'ro', isa => 'Any' );

sub descend {
    my ($self, $dir) = @_;
    return $self->left  if $dir eq 'L';
    return $self->right if $dir eq 'R';
    die "Bad direction '$dir'";
}

sub _insert {
    my ($self, $data) = @_;

    my $cmp = $self->compare($data)
        or return $self;

    my $result = $self->new(
        data   => $self->data,
        left   => $cmp < 0 ? $self->left ->_insert($data) : $self->left,
        right  => $cmp > 0 ? $self->right->_insert($data) : $self->right,
        colour => $self->colour,
    )->balance;

    return $result;
}

sub balance {
    my ($self) = @_;

    if (! $self->colour) {
        # if we are black

        TRY: for my $try (qw/ LL LR RL RR /) {
            my @path;
            my $root = $self;

            for my $dir (split //, $try) {
                my $node = $root->descend($dir);
                next TRY unless $node->colour;

                push @path, {
                    root => $root,
                    node => $node,
                    dir  => $dir,
                };
                $root = $node;
            }

            my $grandchild = $path[-1];
            my $gc_node = $grandchild->{node};

            my @abcd = ($gc_node->left, $gc_node->right);
            my @xyz  = ($gc_node);

            for my $path (reverse @path) {
                my $dir  = $path->{dir};
                my $root = $path->{root};

                if ($dir eq 'L') {
                    push  @xyz, $root;
                    push @abcd, $root->right;
                }
                else {
                    unshift  @xyz, $root;
                    unshift @abcd, $root->left;
                }
            }

            my ($x, $y, $z)     = @xyz;
            my ($A, $B, $C, $D) = @abcd;

            return $self->new(
                data   => $y->data,
                colour => 1,
                left => $self->new(
                    data => $x->data,
                    left => $A, right => $B,
                    colour => 0,
                ),
                right => $self->new(
                    data => $z->data,
                    left => $C, right => $D,
                    colour => 0,
                ),
            );
        }
    }
    return $self;
}

sub compare {
    my ($self, $data) = @_;
    return $data cmp $self->data;
}

sub member {
    my ($self, $data) = @_;

    my $cmp = $self->compare($data)
        or return $self;

    return $cmp > 0 ?
        $self->right->member($data)
      : $self->left ->member($data);
}

sub debug_tree {
    my ($self, $level) = @_;
    $level ||= 0;
    my $padding = '  ' x $level;

    my $left  = $self->left ->debug_tree($level+1);
    my $right = $self->right->debug_tree($level+1);

    my $data = $self->data . ' (' . ($self->colour ? 'R' : 'B') . ')';
    $data = $data ? "$data\n" : '';

    return $left . $padding . $data . $right;
}
sub leaves {
    my $self = shift;
    return (
        $self->left->leaves,
        $self->data,
        $self->right->leaves
    );
}

sub remove {
    my ($self, $data) = @_;

    my $cmp = $self->compare($data)
        or do {
            

        };

    return $cmp > 0 ?
        $self->right->remove($data)
      : $self->left ->remove($data);
}

use constant is_empty => 0;

no Moose; __PACKAGE__->meta->make_immutable; 1;
