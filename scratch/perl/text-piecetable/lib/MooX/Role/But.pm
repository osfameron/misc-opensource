package MooX::Role::But;
use Moo::Role;

sub but {
    my $self = shift;
    return $self->new(%$self, @_);
}

sub traverse {
    my ($self, @traversals) = @_;

    return MooX::Zipper->new( head => $self );
}

package MooX::Zipper;
use Moo;
with 'MooX::Role::But';
use Types::Standard qw( ArrayRef );

has head => (
    is => 'ro',
);

has dir => (
    is => 'ro',
);

has zip => (
    is => 'ro',
);

sub go {
    my ($self, $dir) = @_;
    return $self->but(
        head => $self->head->$dir,
        dir => $dir,
        zip => $self,
    );
}

sub call {
    my ($self, $method, @args) = @_;
    return $self->but(
        head => $self->head->$method(@args),
    );
}

sub set {
    my ($self, %args) = @_;
    return $self->but(
        head => $self->head->but(%args)
    );
}

sub up {
    my $self = shift;
    return $self->zip->but(
        head => $self->zip->head->but(
            $self->dir => $self->head
        ),
    );
}

sub top {
    my $self = shift;
    return $self unless $self->zip;
    return $self->up->top;
}

sub focus {
    my $self = shift;
    $self->top->head;
}

1
