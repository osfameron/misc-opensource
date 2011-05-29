package Tree::Enfilade;
use Moose;
use Data::Dumper;

has colour => (
    isa => 'Int',
    is  => 'ro',
    default => 0,
);

has disp => (
    isa => 'Int',
    is  => 'ro',
    default => 0,
);

use constant width       => 0;
use constant total_width => 0;

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
    require Tree::Enfilade::Node;
    my $result = Tree::Enfilade::Node->new({
        data   => $data,
        colour => 1,
    });

    return $result;
}

sub debug_tree { '' }
sub leaves { () }

no Moose; __PACKAGE__->meta->make_immutable; 1;
