=head1 SYNOPSIS

see http://en.wikipedia.org/wiki/AA_tree
and http://www.eternallyconfuzzled.com/tuts/datastructures/jsw_tut_andersson.aspx

(latter especially useful in details of deletion implementation)

=cut

package But;
use Moo::Role;

sub but {
    my $self = shift;
    return $self->new(%$self, @_);
}

package Tree::AA::Node;
use Moo;

sub level { 0 }
sub value { die }

sub insert {
    my ($self, $cmp, $item) = @_;
    return Tree::AA::Node::NonEmpty->new(value => $item);
}

# simplest algorithm is by defining most methods to just return self
sub delete { $_[0] }
sub left { $_[0] }
sub right { $_[0] }
sub skew { $_[0] }
sub split { $_[0] }
sub debug_tree { '' }
sub debug { '()' }

package Tree::AA::Node::NonEmpty;
use Types::Standard qw( Int InstanceOf );
use Moo;
extends 'Tree::AA::Node';
with 'But';

my $NIL = Tree::AA::Node->new;

has value =>
    is => 'ro';

has level =>
    is => 'ro',
    default => 1,
    isa => Int;

has left =>
    is => 'ro',
    isa => InstanceOf['Tree::AA::Node'],
    default => sub { $NIL };

has right =>
    is => 'ro',
    isa => InstanceOf['Tree::AA::Node'],
    default => sub { $NIL };

sub insert {
    my ($self, $cmp_ref, $item) = @_;
    my $cmp = $cmp_ref->($item, $self->value)
        or die "Attempted to insert duplicate value $item";
    my $dir = $cmp > 0 ? 'right' : 'left';
    return $self->but(
        $dir => $self->$dir->insert($cmp_ref, $item)
    )->skew->split;
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
    if (my $cmp = $cmp_ref->($item, $self->value)) {
        my $dir = $cmp > 0 ? 'right' : 'left';
        return $self->but(
            $dir => $self->$dir->delete($cmp_ref, $item)
        );
    }
    else {
        if ($self->leaf) {
            return $NIL;
        }
        my $tree = $self->bothkids ?
            do {
                my $pre = $self->left->rightmost;
                $self->but(
                    value => $pre->value,
                    left => $self->left->delete($cmp_ref, $pre->value),
                );
            }
            :
            $self->firstkid;

        my $min_level = $tree->level - 1;
        if ($tree->left->level < $min_level
         or $tree->right->level < $min_level) {
            $tree = $tree->but(
                level => $min_level,
                right => $tree->right->but(
                    level => $min_level,
                )
            );
        }
        return $tree->skew->split;
    }
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

package Tree::AA;
use Moo;
with 'But';
use Types::Standard qw( InstanceOf CodeRef );

has root =>
    is => 'lazy',
    isa => InstanceOf['Tree::AA::Node'],
    default => sub { Tree::AA::Node->new };

has cmp =>
    is => 'lazy',
    default => sub { sub { $_[0] <=> $_[1] } },
    isa => CodeRef;

sub insert {
    my ($self, $item) = @_;
    return $self->but(
        root => $self->root->insert($self->cmp, $item)
    );
}

sub delete {
    my ($self, $item) = @_;
    return $self->but(
        root => $self->root->delete($self->cmp, $item)
    );
}

sub debug_tree {
    my $self = shift;
    "--------\n" . $self->root->debug_tree;
}

1;
