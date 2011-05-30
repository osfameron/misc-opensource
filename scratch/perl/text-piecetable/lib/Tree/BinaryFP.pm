package Tree::BinaryFP;
use Moose;
use feature 'say';

sub node_class { __PACKAGE__ . '::Node'   }
sub empty_class { __PACKAGE__ . '::Empty' }
sub isEmpty { undef }

{
 my $empty;
    sub empty {
        my $self = shift;
        $empty //= $self->empty_class->new;
    }
}

sub reverse {
    my $self = shift;
    return $self->new({
        %$self,
        left => $self->right->reverse,
        right => $self->left->reverse,
    });
}
sub mk_node {
    my ($class, $val) = @_;
    if (defined $val) {
        return sub {
            return $class->node($val, @_);
        }
    }
    else {
        return sub { $class->empty }
    }
}
sub node {
    my ($class, $val, $left, $right) = @_;
    return $class->empty unless grep defined, ($val, $left, $right);
    $class->node_class->new({
        value => $val,
        left  => $left  ? $left  : $class->empty,
        right => $right ? $right : $class->empty,
    });
}

sub match {
    my ($self, $match, $sym) = @_;

    return $self if $match->isEmpty;
    my $p = $match->value;
    if (ref $p and ref $p eq 'CODE') {
        $p->($self) or return;
    }
    else {
        return unless $self->value eq $p;
    }

    my @dirs = qw/ left right /;
    my %opposite = ( left=>'right', right=>'left' );

    my @children;
    for my $dir (@dirs) {
        my $child = $match->$dir;
        next if $child->isEmpty;

        my $descend = $sym ? $opposite{$dir} : $dir;
        my @child = $self->$descend->match($child, $sym)
            or return;
        push @children, @child;
    }
    return ($self, @children);
}

sub run_match {
    my ($self, $tree, $f) = @_;
    my @list = eval { $self->match($tree) };
    if (@list) {
        return $f->(@list);
    }
    return;
}
sub run_match_and_sym {
    my ($self, $tree, $f) = @_;

    for my $sym (0,1) {
        my @list = eval { $self->match($tree, $sym) };
        if (@list) {
            return $f->(@list);
        }
    }
    return;
}

sub default_comparison {
    return sub { $_[0]->value <=> $_[1] }
}

sub compare {
    my ($self, $value) = @_;
    return $self->compareWith(
        $self->default_comparison,
        $value);
}
sub insert {
    my ($self, $value) = @_;
    return $self->insertWith($self->default_comparison, $value);
}
sub insertWith  {
    my ($self, $comparison, $value) = @_;
    return $self->_insertWith( $comparison, $value );
}

sub _insertWith { die "abstract method" };
sub compareWith { die "abstract method" };
sub member      { die "abstract method" };
sub debug_tree  { die "abstract method" };
sub inorder      { die "abstract method" };
sub show        { die "abstract method" };
sub debug_inorder {
    my $self = shift;
    return join ',' => map $_->show, $self->inorder;
}

package Tree::BinaryFP::Empty;
use Moose;
extends 'Tree::BinaryFP';

sub min { shift }
sub max { shift }

sub popMax { 
    die "popMax called on empty list";
}

sub reverse {
    return shift;
}
sub _insertWith {
    my ($self, $comparison, $value) = @_;
    return $self->node_class->new({ value => $value });
}
sub member  { return }
sub compare { return }
sub debug_tree { '' }
sub inorder { () }
sub show { '()' }
sub isEmpty { 1 }
sub childless { 1 }

package Tree::BinaryFP::Node;
use Moose;
extends 'Tree::BinaryFP';

has left => (
    is      => 'ro',
    # isa     => quote_sub q{ $_[0]->isa('Tree::BinaryFP') },
    default => sub { $_[0]->empty },
);
has right => (
    is    => 'ro',
    # isa   => quote_sub q{ $_[0]->isa('Tree::BinaryFP') },
    default => sub { $_[0]->empty },
);

sub hasLeft {
    my $self = shift;
    return $self->left->isEmpty ? 0 : 1;
}
sub hasRight {
    my $self = shift;
    return $self->right->isEmpty ? 0 : 1;
}
sub childless {
    my $self = shift;
    return !($self->hasLeft || $self->hasRight);
}

has value => (
    is => 'ro',
);

sub show {
    my $self = shift;
    return $self->value;
}

sub _insertWith {
    my ($self, $cf, $value) = @_;

    my $cmp = $cf->($self, $value)
        or return $self;

    return $self->new(
        value => $self->value,
        left => $cmp < 0 ? $self->left ->insertWith($cf, $value) : $self->left,
        right=> $cmp > 0 ? $self->right->insertWith($cf, $value) : $self->right,
    );
}
sub debug_tree {
    my ($self, $level) = @_;
    $level ||= 0;
    my $padding = '  ' x $level;

    my $left  = $self->left ->debug_tree($level+1);
    my $right = $self->right->debug_tree($level+1);

    my $value = $self->value;
    $value = $value ? "$value\n" : '';

    return $left . $padding . $value . $right;
}
sub inorder {
    my $self = shift;
    return (
        $self->left->inorder,
        $self,
        $self->right->inorder
    );
}

sub min {
    my $self = shift;
    # return $self->hasLeft ? $self->left : $self;
    my $left = $self->left;
    return $left->isEmpty ? $self : $left;
}
sub max { 
    my $self = shift;
    # return $self->hasRight ? $self->right : $self;
    my $right = $self->right;
    return $right->isEmpty ? $self : $right;
}
sub popMax { 
    my $self = shift;
    my $right = $self->right;
    if ($right->isEmpty) {
        return ($self, $self->left);
    }
    else {
        my ($popped, $newRight) = $right->popMax;
        return (
            $popped,
            $self->new({
                %$self,
                right => $newRight,
            }),
        );
    }
}

sub A;
sub N;
sub E;
*A = __PACKAGE__->mk_node( sub { 1 } );
*E = __PACKAGE__->mk_node( sub { shift->isEmpty } );
*N = __PACKAGE__->mk_node( sub { ! shift->isEmpty } );

sub _delete {
    my $self = shift;

    #$self->run_match( any(empty,empty),
    if ($self->childless) {
        return $self->empty;
    }

    $self->run_match_and_sym( 
        A(N,E),
        sub {
            my ($self, $node, undef) = @_;
            return $node;
        })
    or do {
    # $self->run_match( any(node,node),
        my ($popped, $left) = $self->left->popMax;
        return $self->new({
            %$popped,
            left  => $left,
            right => $self->right,
        });
    };
}

1;
