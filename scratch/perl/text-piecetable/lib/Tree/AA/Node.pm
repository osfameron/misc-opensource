package Tree::AA::Node;
use Moo;

sub level { 0 }
sub value { die }

sub insert {
    my ($self, $cmp, $item) = @_;
    return Tree::AA::Node::NonEmpty->new(value => $item);
}

# simplest algorithm is by defining most methods to just return self
sub but { $_[0] }
sub delete { $_[0] }
sub left { $_[0] }
sub right { $_[0] }
sub skew { $_[0] }
sub split { $_[0] }
sub debug_tree { '' }
sub debug { '()' }
sub debug_check_invariants { }

1;
