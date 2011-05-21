package Text::PieceTable;
use Text::PieceTable::Source;
use Text::PieceTable::Piece;
use List::Util 'sum';

use Data::Dumper;
local $Data::Dumper::Indent = 1;

use Moose;

has source => (
    isa => 'Text::PieceTable::Source',
    is  => 'ro',
    default => sub {
        Text::PieceTable::Source->new({
            data => '',
        })
    },
);

has additional => (
    isa => 'Text::PieceTable::Source',
    is  => 'ro',
    default => sub {
        Text::PieceTable::Source->new({
            data => '',
        })
    },
);
has pieces => (
    traits  => ['Array'],
    is      => 'ro',
    isa     => 'ArrayRef[Text::PieceTable::Piece]',
    default => sub { [] },
    handles => {
        all_pieces => 'elements',
        find_piece => 'first',
        map_pieces => 'map',
        push_piece => 'push',
    },
);

sub from_string {
    my ($class, $string) = @_;

    my $source = Text::PieceTable::Source->new({
        data => $string,
    });
    my $self = $class->new(source => $source);
    if (length $string) {
        $self->push_piece($source->whole_piece);
    }
    return $self;
}
sub from_file {
    my ($class, $filename) = @_;
    use File::Map 'map_file';
    map_file my $map, $filename;
    return $class->from_string($map);
}

sub piece_at_pos {
    my ($self, $pos) = @_;

    my $i = 0;
    my @before;
    my @pieces = $self->all_pieces;

    while (my $piece = shift @pieces) {
        my $len = $piece->length;
        if ($i + $len > $pos) {
            return ($piece, $pos - $i, \@before, \@pieces);
        }
        if ($i + $len == $pos and !@pieces) {
            return ($piece, $len, \@before, \@pieces);
        }
        push @before, $piece;
        $i += $len;
    }
    die "Invalid pos $pos";
}

sub insert {
    my ($self, $pos, $text) = @_;

    my $piece = $self->additional->append($text);
    return $self->insert_piece($pos, $piece);
}

sub insert_piece {
    my ($self, $pos, $insert) = @_;
    my ($piece, $i, $before, $after) =
        $self->piece_at_pos($pos);

    my ($pre,$post) = $piece->split_at($i);

    my $pieces = [
            @$before,
            $pre ? $pre : (),
            $insert,
            $post ? $post : (),
            @$after,
        ];
    return $self->new(
        source     => $self->source,
        additional => $self->additional,
        pieces     => $pieces,
    );
}

sub as_string {
    my $self = shift;
    return join '' => $self->map_pieces( sub { $_->as_string } );
}
sub length {
    my $self = shift;
    return sum $self->map_pieces( sub { $_->length } );
}

no Moose; 1;
