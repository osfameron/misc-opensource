package MooX::Role::But;
use Moo::Role;

sub but {
    my $self = shift;
    return $self->new(%$self, @_);
}

1
