package Tree::RedBlackFP;
use Moose;
use Data::Dumper;

has colour => (
    isa => 'Int',
    is  => 'ro',
);

{ 
    my $empty;
    sub empty { 
        $empty //= __PACKAGE__->new() 
    }
}

# default methods (for Empty)
sub member  { return }
sub compare { return }

sub insert {
    my ($self, $data) = @_;
    my $result = $self->_insert($data);
    return $result->new( %$result, colour => 0 );
}
sub _insert {
    my ($self, $data) = @_;
    require Tree::RedBlackFP::Node;
    my $result = Tree::RedBlackFP::Node->new({
        data   => $data,
        colour => 1,
    });

    return $result;
}

sub debug_tree { '' }

no Moose; __PACKAGE__->meta->make_immutable; 1;
