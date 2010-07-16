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

    warn Dumper( [ $map2->take(3) ] );
    warn Dumper( [ $map2->While(sub { $_[0] < 6 })->take(10) ] );

    my $grep = $map->Grep( sub { $_[0] % 2 });
    warn Dumper( [ $grep->take(10) ] );

    warn $grep->Foldl( sub { $_[0] + $_[1] }, 0 );
    warn $grep->Foldr( sub { $_[0] + $_[1] }, 0 );

    warn Dumper( [ $grep->concat($map2)->take(20) ] );
    warn Dumper( [ $grep->cycle->take(20) ] );
}
