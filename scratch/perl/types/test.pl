package Testing::Types;
use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Types::Structured qw(Tuple);
use MooseX::Types::Moose qw(ArrayRef Any);
use MooseX::Types -declare => [qw(List Empty Cons)];

use feature 'say';

subtype Empty,
    as ArrayRef,
    where { ! @$_ };

subtype Cons,
    as Tuple [ Any, List ]; # 

subtype List, 
    as Empty | Cons;

sub head {
    my $list = shift;
    match_on_type $list => (
        Empty,  sub { die "Can't take head of empty list" },
        Cons,   sub { $_->[0] },
        sub { die "Not a valid list" },
    );
}

sub main {

    my $list = [];

    for (1..100) {
        $list = [$_, $list]
    };

    # deep recursion - i.e. will descend whole list to see what it is
    say head($list);
}

main;

