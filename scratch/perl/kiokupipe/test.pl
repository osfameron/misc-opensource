#!/usr/bin/perl

use List;
use List::Map::Increment;
use Data::Dumper;

my $list = List->from_array(1..10);

my $map = List::Map::Increment->new( list => $list );

local $Data::Dumper::Indent = 1;
local $Data::Dumper::Maxdepth = 4;
warn Dumper($list, $map);

while ($map) {
    warn $map->head;
    $map = $map->tail;
}

