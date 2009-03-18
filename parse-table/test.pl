#!/usr/bin/perl

package Row::Test;
use Fixed;
extends 'Fixed::Row';

column first    => range=>[0 , 3];
column last     => range=>[5 ,10];
column date     => range=>[12,21], isa =>'Date';
column duration => range=>[23,27], isa =>'Duration';

#######################################################
package main;

use Test::More tests => 7;

my $obj = Row::Test->parse('Fred Bloggs 2009-03-17 02:03');
                           #          1         2
                           #0123456789012345678901234567
                           #0..3
                           #     5...10
                           #            12......21
                           #                       23.27

isa_ok $obj,           'Row::Test';
is $obj->first,        'Fred';
is $obj->last,         'Bloggs';
isa_ok $obj->date,     'DateTime';
isa_ok $obj->duration, 'DateTime::Duration';

is $obj->date->day, 17,                      'Day parsed ok';
is $obj->duration->in_units('minutes'), 123, 'Duration parsed ok';

use Data::Dumper;
local $Data::Dumper::Maxdepth=1; local $Data::Dumper::Indent = 1;
diag Dumper($obj);
