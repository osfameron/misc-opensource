#!/usr/bin/perl

package Row::Name;
use Fixed;
use Fixed::Row;
extends 'Fixed::Row';

column first => (
    range  => [0, 4]
    );

column last => (
    range  => [5, 11]
    );

package main;

use Test::More tests => 3;

my $obj = Row::Name->parse('Fred Bloggs');

isa_ok $obj, 'Row::Name';
is $obj->first, 'Fred';
is $obj->last,  'Bloggs';
