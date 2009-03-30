#!/usr/bin/perl

package Row::Test;
use Fixed;
extends 'Fixed::Row';

column first    => width => 4;
pic    ' ';
column middle   => width => 1;
pic    ' ';
column last     => width => 6;
pic    ' | ';
column date     => width => 10, isa =>'Date';
pic    ' | ';
column duration => width => 5, isa =>'Duration';

             #           1         2         3
             # 0123456789012345678901234567890123
             # 0..3
             #      5
             #        7...12
             #                 16......25
             #                              29.33

$Test::Data = 'Fred J Bloggs | 2009-03-17 | 02:03';

#######################################################
package main;

use Test::More tests => 13;

my $obj = Row::Test->parse( $Test::Data );

my @fields = (qw/ first middle last date duration /);

can_ok 'Row::Test',              @fields;

isa_ok $obj,           'Row::Test';
is $obj->first,        'Fred';
is $obj->middle,       'J';
is $obj->last,         'Bloggs';
isa_ok $obj->date,     'DateTime';
isa_ok $obj->duration, 'DateTime::Duration';

is $obj->date->day, 17,                      'Day parsed ok';
is $obj->duration->in_units('minutes'), 123, 'Duration parsed ok';

is ''.$obj->date,     '2009-03-17',  'Format date';
is ''.$obj->duration, '02:03',       'Format duration';

my $expected = $Test::Data;

is $obj->output, $Test::Data, 'Round trip output (explicit picture)';
is ''.$obj,      $Test::Data, '... with overloading';
