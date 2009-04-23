#!/usr/bin/perl

use strict; use warnings;
use Data::Dumper;

use Test::More tests => 14;

use Sub::Section;

is op(+)->(3, 4),
   7,
   'op (+) ok';

is op(-)->(2, 1),
   1,
   'op (-) ok, e.g. in right order';

is op(5-)->(3),
   2,
   'section (5-) ok';

is op(-5)->(3),
   -2,
   'section (-5) ok';

my $x = 5;
is op($x-)->(1),
   4,
   'curried with $x in current scope';

# TODO override the () of RHS in -> case!
# my $foo = op(->{foo});
# is ($foo->( {foo=>'bar'} ), 'bar', 'accessor works');

is op(q/Hello /.)->("World"),
   "Hello World",
   'String section';
is op(.q/ World/)->("Hello"),
   "Hello World",
   'String section 2';

is_deeply [ grep op(%2)->($_), (1..5) ], [1,3,5],      'With grep on (%2)';
is_deeply [ map  op(*2)->($_), (1..5) ], [2,4,6,8,10], 'With map on (*2)';
is_deeply [ grep op(>2)->($_), (1..5) ], [3,4,5],      'With grep on (>2)';
is_deeply [ grep op(2>)->($_), (1..5) ], [1],          'With grep on (2>)';

is_deeply [ grep op(ne "foo")->($_), qw/foo bar baz/ ], 
          [qw/bar baz/], 
          'Grep on (ne "foo")';
is_deeply [ grep op('foo'=~)->($_),  'a'..'z' ], 
          [qw/f o/], 
          'Grep on ("foo"=~)';

is_deeply [ grep op(=~qr/a/)->($_),    qw/foo bar baz/ ], 
          [qw/bar baz/], 
          'Grep on (=~qr/a/)';
