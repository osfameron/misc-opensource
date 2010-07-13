#!/usr/bin/perl

use strict; use warnings;
use List;
use List::Map::Increment;
use Data::Dumper;

use KiokuDB;

my $list = List->from_array(1..10);
my $map = List::Map::Increment->new( list => $list );

local $Data::Dumper::Indent = 1;
local $Data::Dumper::Maxdepth = 10;

{
    my $kioku = KiokuDB->connect('hash');
    my $scope = $kioku->new_scope;

    warn $map->head;
    warn $map->tail->head;
    warn $map->tail->tail->head;

    $kioku->store(map => $map);

    my $map2 = $kioku->lookup('map');

    warn Dumper($map2);
}
