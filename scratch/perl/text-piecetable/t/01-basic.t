use Test::More;
use Data::Dumper;
local $Data::Dumper::Indent = 1;

use Text::PieceTable;
my $pt = Text::PieceTable->from_string('fox');
is $pt->as_string, 'fox';

$pt = $pt->insert(0, 'the quick ');
is $pt->as_string, 'the quick fox';


# $pt = $pt->insert(-1, ' jumps over the lazy dog');
$pt = $pt->insert($pt->length, ' jumps over the lazy dog');
is $pt->as_string, 'the quick fox jumps over the lazy dog';

$pt = $pt->insert(10, 'brown ');
is $pt->as_string, 'the quick brown fox jumps over the lazy dog';

done_testing;
