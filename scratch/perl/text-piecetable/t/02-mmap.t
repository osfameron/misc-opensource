use Test::More;
use Data::Dumper;
local $Data::Dumper::Indent = 1;
use FindBin '$Bin';

use Text::PieceTable;
my $pt = Text::PieceTable->from_file("$Bin/fox.txt");
is $pt->as_string, "fox\n";

$pt = $pt->insert(0, 'the quick ');
is $pt->as_string, "the quick fox\n";


# $pt = $pt->insert(-1, ' jumps over the lazy dog');
$pt = $pt->insert($pt->length, ' jumps over the lazy dog');
is $pt->as_string, "the quick fox\n jumps over the lazy dog";

$pt = $pt->insert(10, 'brown ');
is $pt->as_string, "the quick brown fox\n jumps over the lazy dog";

done_testing;
