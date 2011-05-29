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
        left => $self->right,
        right => $self->left,
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
    my ($self, $match) = @_;

    return $self if $match->isEmpty;
    my $p = $match->value;
    if (ref $p and ref $p eq 'CODE') {
        $p->($self) or return;
    }
    else {
        return unless $self->value eq $p;
    }
    my @children;
    for my $dir ('left', 'right') {
        my $child = $match->$dir;
        next if $child->isEmpty;
        my @child = $self->$dir->match($child)
            or return;
        push @children, @child;
    }
    return ($self, @children);
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
sub leaves      { die "abstract method" };
sub show        { die "abstract method" };

sub run_match {
    my ($self, $tree, $debug) = @_;
    my @list = eval { $self->match($tree) };
    if ($debug) {
        say sprintf "$debug %s: %s",
            (@list ? 'OK' : 'FAIL'),
            join ',' => map $_->show, @list;
    }
}

package Tree::BinaryFP::Empty;
use Moose;
extends 'Tree::BinaryFP';

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
sub leaves { () }
sub show { '()' }
sub isEmpty { 1 }

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
sub leaves {
    my $self = shift;
    return (
        $self->left->leaves,
        $self->value,
        $self->right->leaves
    );
}

1;
