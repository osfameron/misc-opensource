package Text::PieceTable::Source;

use Moose;

has data => (
    traits => ['String'],
    isa => 'Str',
    is => 'rw', # only appendable, so easily shared!
    default => '',
    handles => {
        _append => 'append',
        length  => 'length',
        substr  => 'substr',
    },
);

sub append {
    my ($self, $string) = @_;
    my $pos = $self->length;

    $self->_append($string);
    return Text::PieceTable::Piece->new(
        source => $self,
        from   => $pos,
        length => length $string,
    );
}

sub whole_piece {
    my $self = shift;
    return Text::PieceTable::Piece->new(
        source => $self,
        from   => 0,
        length => $self->length,
    );
}

no Moose; 1;
