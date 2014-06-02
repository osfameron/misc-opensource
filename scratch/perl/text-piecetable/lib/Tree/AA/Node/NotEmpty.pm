package Tree::AA::Node::NonEmpty;
use Types::Standard qw( Int InstanceOf );
use Moo;
extends 'Tree::AA::Node';
with 'MooX::Role::But';
use List::Util 'min';

my $NIL = Tree::AA::Node->new;

has key => (
    is => 'ro',
);

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
    my ($self, $cmp_ref, $key, $value, $merge_fn) = @_;
    my $cmp = $cmp_ref->($key, $self->key)
        or do {
            die "Attempted to insert duplicate value $key" unless $merge_fn;
            return $self->but(
                value => $merge_fn->($self->value, $value, $key), # old, new, key
            );
        };
    my $dir = $cmp > 0 ? 'right' : 'left';

    return $self->but(
        $dir => $self->$dir->insert($cmp_ref, $key, $value, $merge_fn),
    )->skew->split;

    # equivalent to (but following is significantly slower in tight loop)
    # $self->traverse->go($dir)
    # ->call(insert=>$cmp_ref, $key, $value, $merge_fn)->focus
    # ->skew->split;
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
    my ($self, $cmp_ref, $key) = @_;

    my $tree;

    if (my $cmp = $cmp_ref->($key, $self->key)) {
        # Descend tree to delete there
        my $dir = $cmp > 0 ? 'right' : 'left';

        # $tree = $self->traverse->go($dir)->call(delete => $cmp_ref, $key)->focus;
        $tree = $self->but(
            $dir => $self->$dir->delete($cmp_ref, $key)
        );
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
                        ->set(key=>$pre->key, value=>$pre->value)
                        ->go('left')->call(delete => $cmp_ref, $pre->key)
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

sub keys {
    my $self = shift;
    return ($self->left->keys, $self->key, $self->right->keys);
}

sub values {
    my $self = shift;
    return ($self->left->values, $self->value, $self->right->values);
}

sub pair {
    my $self = shift;
    [ $self->key, $self->value ];
}

sub pairs {
    my $self = shift;
    return ($self->left->pairs, $self->pair, $self->right->pairs);
}

sub fmap {
    my ($self, $fn) = @_;
    $self->but(
        value => $fn->($self->value, $self->key),
        left => $self->left->fmap($fn),
        right => $self->right->fmap($fn),
    );
}

sub filter {
    # for now, let's just degrade to pairs, and rebuild.  Would it be better to do this as unions?

    my ($self, $fn, $cmp_ref) = @_;
    my @pairs = grep { $fn->(@$_) } $self->pairs;

    my $tree = Tree::AA->new( cmp => $cmp_ref );
    for (@pairs) {
        $tree = $tree->insert(@$_);
    }
    return $tree;
}

# Union
# todo implement as divide-and-conquer or hedge-union
# e.g. http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.48.1134&rep=rep1&type=pdf

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

sub debug { my $self=shift; sprintf '(%s/%d)', $self->key, $self->level }
sub debug_tree {
    my ($self, $level) = @_;
    $level ||= 0;
    my $padding = '  ' x $level;

    my $left  = $self->left ->debug_tree($level+1);
    my $right = $self->right->debug_tree($level+1);

    my $data = $self->key . ' (' . ($self->level) . ')';
    $data = $data ? "$data\n" : '';

    return $right . $padding . $data . $left;
}
sub debug_check_invariants {
    my $self = shift;

    my $level = $self->level;

    # 1. The level of every leaf node is 1
    if ($self->leaf) {
        die sprintf "Leaf node not level 1: %s / %d", $self->key, $level
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
