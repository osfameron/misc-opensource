package Tree::AA::Node::NonEmpty;
use Types::Standard qw( Int InstanceOf );
use Moo;
extends 'Tree::AA::Node';
with 'MooX::Role::But';
use List::Util 'min';

my $NIL = Tree::AA::Node->new;

has value => (
    is => 'ro',
);

has level => (
    is => 'ro',
    default => 1,
    isa => Int,
);

has left => (
    is => 'lazy',
    isa => InstanceOf['Tree::AA::Node'],
    default => sub { $NIL },
);

has right => (
    is => 'lazy',
    isa => InstanceOf['Tree::AA::Node'],
    default => sub { $NIL },
);

sub insert {
    my ($self, $cmp_ref, $item) = @_;
    my $cmp = $cmp_ref->($item, $self->value)
        or die "Attempted to insert duplicate value $item";
    my $dir = $cmp > 0 ? 'right' : 'left';

    $self->traverse->go($dir)
        ->call(insert=>$cmp_ref, $item)->focus
        ->skew->split;
}

sub leaf {
    my $self = shift;
    return ! ($self->left->level || $self->right->level);
}

sub bothkids {
    my $self = shift;
    return ($self->left->level && $self->right->level);
}

sub firstkid {
    my $self = shift;
    return $self->left if $self->left->level;
    return $self->right if $self->right->level;
}

sub rightmost {
    my $self = shift;
    return $self->right->level ? $self->right->rightmost : $self;
}

sub delete {
    my ($self, $cmp_ref, $item) = @_;

    my $tree;

    if (my $cmp = $cmp_ref->($item, $self->value)) {
        # Descend tree to delete there
        my $dir = $cmp > 0 ? 'right' : 'left';
        $tree = $self->traverse->go($dir)->call(delete => $cmp_ref, $item)->focus;
    }
    else {
        if ($self->leaf) {
            return $NIL;
        }
        else {
            $tree = $self->bothkids ?
                do {
                    my $pre = $self->left->rightmost;
                    $self->traverse
                        ->set(value=>$pre->value)
                        ->go('left')->call(delete => $cmp_ref, $pre->value)
                        ->focus;
                }
                :
                $self->firstkid;
        }
    }

    my $min_level = $tree->level - 1;

    if ($tree->left->level < $min_level
     or $tree->right->level < $min_level) {

        $tree = $tree->traverse
            ->set( level => $min_level )
                ->go('right')->set( 
                    level => min( $min_level, $tree->right->level ) )
            ->top
            ->call('skew')
                ->go('right')->call('skew')
                    ->go('right')->call('skew')
            ->top
            ->call('split')
                ->go('right')->call('split')
            ->focus;
    }
    return $tree;
}

sub skew {
    my $self = shift;

    my $L = $self->left;
    return $self unless $L->level;

    if ($L->level == $self->level) {
        return $L->but(
            right => $self->but(
                left => $L->right,
            ),
        );
    }
    return $self;
}

sub split {
    my $self = shift;

    my $R = $self->right;
    return $self unless $R->level;
    my $RR = $R->right;
    return $self unless $RR->level;

    if ($self->level == $RR->level) {
        return $R->but(
            left => $self->but(
                right => $R->left,
            ),
            level => $R->level + 1,
        );
    }
    return $self;
}

sub debug { my $self=shift; sprintf '(%s/%d)', $self->value, $self->level }
sub debug_tree {
    my ($self, $level) = @_;
    $level ||= 0;
    my $padding = '  ' x $level;

    my $left  = $self->left ->debug_tree($level+1);
    my $right = $self->right->debug_tree($level+1);

    my $data = $self->value . ' (' . ($self->level) . ')';
    $data = $data ? "$data\n" : '';

    return $right . $padding . $data . $left;
}
sub debug_check_invariants {
    my $self = shift;

    my $level = $self->level;

    # 1. The level of every leaf node is 1
    if ($self->leaf) {
        die sprintf "Leaf node not level 1: %s / %d", $self->value, $level
            unless $level == 1;
    }

    # 2. The level of every left child is exactly one less than that of its parent.
    my $L = $self->left;
    die sprintf "Left child (%d) == parent (%d) - 1", $L->level, $level
        unless $L->level == $level - 1;

    # 3. The level of every right child is equal to or one less than that of its parent.
    my $R = $self->right;
    die sprintf "Right child (%d) == parent (%d) OR - 1", $R->level, $level
        unless $R->level == $level - 1 or $R->level == $level;

    # 4. The level of every right grandchild is strictly less than that of its grandparent.
    my $RR = $R->right;
    die sprintf "Right grandchild child (%d) < parent (%d)", $RR->level, $level
        unless $RR->level < $level;

    # 5. Every node of level greater than one has two children.
    if ($level > 1) {
        die sprintf "Level %d but does not have both kids" unless $self->bothkids;
    }

    $self->left->debug_check_invariants;
    $self->right->debug_check_invariants;
}

1;
