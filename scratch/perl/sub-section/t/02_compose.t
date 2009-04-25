#!/usr/bin/perl
use strict; use warnings;
use Data::Dumper;
use FindBin '$Bin';
use lib $Bin;

use Test::More tests=>3;

# use Sub::Compose::Dot;
use Sub::Composable;

use Sub::Section;

my $sub = op('Ba'.) << op(x 2) << op(.'a');

is $sub ->('n'), 'Banana', 'Composed a Banana';

my $length = bless sub { length shift }, 'Sub::Composable';
my $sub2 = $length << $sub;
is $sub2->('nn'), 8, 'Composing a compose';

my $sub3 = op(*10) << op(+);

is $sub3->(2, 3), 50, 'Compose with final sub having 2 args';

