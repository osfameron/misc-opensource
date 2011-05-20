package Text::PieceTable::Piece;

use Moose;

has source => (
    isa => 'Text::PieceTable::Source',
    is => 'ro',
);

has from => (
    isa => 'Int',
    is => 'ro',
);

has length => (
    isa => 'Int',
    is => 'ro',
);

sub as_string {
    my $self = shift;
    return $self->source->substr($self->from, $self->length);
}

sub split_at {
    my ($self, $pos) = @_;
    if ($pos) {
        if ($pos < $self->length) {
            my $source = $self->source;
            return (
                Text::PieceTable::Piece->new(
                    source => $source,
                    from   => $self->from,
                    length => $pos,
                ),
                Text::PieceTable::Piece->new(
                    source => $source,
                    from   => $self->from + $pos,
                    length => $self->length - $pos,
                )
            );
        }
        else {
            return ($self, undef);
        }
    }
    else {
        return (undef, $self);
    }
}

no Moose; 1;
