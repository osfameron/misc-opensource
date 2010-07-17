#!/usr/bin/perl

use strict; use warnings;
use List;
use Data::Dumper;

use KiokuDB;

my $list = List->from_array(1..10);
my $map  = $list->Map( sub { $_[0] + 1 });

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

    warn Dumper( [ $map2->Take(3)->to_array ] );
    warn Dumper( [ $map2->While(sub { $_[0] < 6 })->Take(10)->to_array ] );

    my $grep = $map->Grep( sub { $_[0] % 2 });
    warn Dumper( [ $grep->Take(10)->to_array ] );

    warn $grep->Foldl( sub { $_[0] + $_[1] }, 0 );
    warn $grep->Foldr( sub { $_[0] + $_[1] }, 0 );

    warn Dumper( [ $grep->Concat($map2)->Take(20)->to_array ] );
    warn Dumper( [ $grep->Cycle->Take(20)->to_array ] );
}
