#!/usr/bin/perl

package Row::Test;
use Fixed;
extends 'Fixed::Row';

column first    => range=>[0 , 3];
column middle   => range=> 5;
column last     => range=>[7 ,12];
column date     => range=>[14,23], isa =>'Date';
column duration => range=>[25,29], isa =>'Duration';

#######################################################
package main;

use Test::More tests => 8;

my $obj = Row::Test->parse('Fred J Bloggs 2009-03-17 02:03');
                           #          1         2
                           #012345678901234567890123456789
                           #0..3
                           #     5
                           #       7...12
                           #              14......23
                           #                         25.29

isa_ok $obj,           'Row::Test';
is $obj->first,        'Fred';
is $obj->middle,       'J';
is $obj->last,         'Bloggs';
isa_ok $obj->date,     'DateTime';
isa_ok $obj->duration, 'DateTime::Duration';

is $obj->date->day, 17,                      'Day parsed ok';
is $obj->duration->in_units('minutes'), 123, 'Duration parsed ok';

use Data::Dumper;
local $Data::Dumper::Maxdepth=1; local $Data::Dumper::Indent = 1;
diag Dumper($obj);
