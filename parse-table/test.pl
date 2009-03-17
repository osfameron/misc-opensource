#!/usr/bin/perl

package Row::Name;
use Fixed;
extends 'Fixed::Row';

column first => range  => [0, 4 ];
column last  => range  => [5, 11];
column date  => range  => [12, 22], isa => 'My.DateTime';

package main;

use Test::More tests => 4;

my $obj = Row::Name->parse('Fred Bloggs 2009-03-17');

isa_ok $obj, 'Row::Name';
is $obj->first, 'Fred';
is $obj->last,  'Bloggs';
isa_ok $obj->date, 'DateTime';

use Data::Dumper;
local $Data::Dumper::Maxdepth=1; local $Data::Dumper::Indent = 1;
diag Dumper($obj);
