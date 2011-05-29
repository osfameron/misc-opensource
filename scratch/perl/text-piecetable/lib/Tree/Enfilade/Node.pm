package Tree::Enfilade::Node;
use Moose;

extends 'Tree::Enfilade';

has left => (
    is  => 'ro',
    isa => 'Tree::Enfilade',
    default => sub { shift->empty },
);
has right => (
    is  => 'ro',
    isa => 'Tree::Enfilade',
    default => sub { shift->empty },
);

has data => ( is => 'ro', isa => 'Str' );

sub width {
    my $self = shift;
    return length $self->data;
}
sub total_width {
    my $self = shift;

    return $self->width
        + $self->left->total_width
        + $self->right->total_width;
}

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

    my $left  = $cmp < 0 ? $self->left ->_insert($data) : $self->left;
    my $right = $cmp > 0 ? $self->right->_insert($data) : $self->right;

    my $result = $self->new(
        data   => $self->data,
        colour => $self->colour,
        disp   => $left->total_width,
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
    my ($self, $pos) = @_;
    return -1 if $pos < $
    return $data cmp $self->data;
}

sub member {
    my ($self, $data) = @_;

    my $cmp = $self->compare($data)
        or return 1;

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
    my ($self) = @_;
    return (
        $self->left->leaves,
        $self->data,
        $self->right->leaves,
    );
}

no Moose; __PACKAGE__->meta->make_immutable; 1;
