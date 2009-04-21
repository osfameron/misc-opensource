#!/usr/bin/perl

use strict; use warnings;
use Data::Dumper;

use Test::More tests => 9;

use Sub::Section;

is op(+)->(3)->(4),
   7,
   'section + ok';

is op(5-)->(3),
   2,
   'section (5-) ok';

is op(-5)->(3),
   -2,
   'section (-5) ok';

is_deeply [ grep op(%2)->($_), (1..5) ], [1,3,5],      'With grep on (%2)';
is_deeply [ map  op(*2)->($_), (1..5) ], [2,4,6,8,10], 'With map on (*2)';
is_deeply [ grep op(>2)->($_), (1..5) ], [3,4,5],      'With grep on (>2)';
is_deeply [ grep op(2>)->($_), (1..5) ], [1],          'With grep on (2>)';

my $x = 5;
is op($x-)->(1),
   4,
   'curried with $x in current scope';

is op("Hello ".)->("World"),
   "Hello World",
   'Hello World';
