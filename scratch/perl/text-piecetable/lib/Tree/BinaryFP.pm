package Tree::BinaryFP;
use Moose;

sub node_class { __PACKAGE__ . '::Node'   }
sub empty_class { __PACKAGE__ . '::Empty' }

{
 my $empty;
    sub empty {
        my $self = shift;
        $empty //= $self->empty_class->new;
    }
}

sub default_comparison {
    return sub { $_[0]->data <=> $_[1] }
}

sub compare {
    my ($self, $data) = @_;
    return $self->compareWith(
        $self->default_comparison,
        $data);
}
sub insert {
    my ($self, $data) = @_;
    return $self->insertWith($self->default_comparison, $data);
}
sub insertWith  {
    my ($self, $comparison, $data) = @_;
    return $self->_insertWith( $comparison, $data );
}

sub _insertWith { die "abstract method" };
sub compareWith { die "abstract method" };
sub member      { die "abstract method" };
sub debug_tree  { die "abstract method" };
sub leaves      { die "abstract method" };

package Tree::BinaryFP::Empty;
use Moose;
extends 'Tree::BinaryFP';

sub _insertWith {
    my ($self, $comparison, $data) = @_;
    return $self->node_class->new({ data => $data });
}
sub member  { return }
sub compare { return }
sub debug_tree { '' }
sub leaves { () }

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

has data => (
    is => 'ro',
);

sub _insertWith {
    my ($self, $cf, $data) = @_;

    my $cmp = $cf->($self, $data)
        or return $self;

    return $self->new(
        data => $self->data,
        left => $cmp < 0 ? $self->left ->insertWith($cf, $data) : $self->left,
        right=> $cmp > 0 ? $self->right->insertWith($cf, $data) : $self->right,
    );
}
sub debug_tree {
    my ($self, $level) = @_;
    $level ||= 0;
    my $padding = '  ' x $level;

    my $left  = $self->left ->debug_tree($level+1);
    my $right = $self->right->debug_tree($level+1);

    my $data = $self->data;
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

1;
