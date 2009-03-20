#!/usr/bin/perl

package Row::Test;
use Fixed;
extends 'Fixed::Row';

column first    => range=>[0 , 3];
column middle   => range=> 5;
column last     => range=>[7 ,12];
column date     => range=>[16,25], isa =>'Date';
column duration => range=>[29,33], isa =>'Duration';

             #           1         2         3
             # 0123456789012345678901234567890123
             # 0..3
             #      5
             #        7...12
             #                 16......25
             #                              29.33

package Row::Test::WithPicture;
use Fixed;
extends 'Row::Test';

# Gah!  Mx::ClassAttribute works not to my expectation...
__PACKAGE__->picture(
              '              |            |      ' 
            );

$Test::Data = 'Fred J Bloggs | 2009-03-17 | 02:03';

#######################################################
package main;

use Test::More tests => 14;

my $obj = Row::Test->parse( $Test::Data );

my @fields = (qw/ first middle last date duration /);

can_ok 'Row::Test',              @fields;
can_ok 'Row::Test::WithPicture', @fields;

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

(my $expected = $Test::Data) =~tr/|/ /;

is $obj->output, $expected, 'Round trip output (with spaces)';
is ''.$obj,      $expected, '... with overloading';

my $obj2 = Row::Test::WithPicture->parse( $Test::Data );
diag $obj2->picture;
is $obj2->output, $Test::Data, 'Round trip output (explicit picture)';
is ''.$obj2,      $Test::Data, '... with overloading';
