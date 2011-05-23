#!/usr/bin/perl
use strict; use warnings;
use Data::Dumper;
use Test::More;

use Tree::BinaryFP;

my $node = Tree::BinaryFP->empty;

my @list = qw/ e d f c g b h a i /;
my $cmp = sub { $_[0]->data cmp $_[1] };
for (@list) {
    $node = $node->insertWith($cmp, $_);
}

diag $node->debug_tree;
diag join ',' => $node->leaves;
# diag Dumper($node);

done_testing;

