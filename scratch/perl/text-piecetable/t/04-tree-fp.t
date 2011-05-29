#!/usr/bin/perl
use strict; use warnings;
use Data::Dumper;
use Test::More;
use feature 'say';

use Tree::BinaryFP;

my $node = Tree::BinaryFP->empty;

my @list = qw/ e d f c g b h a i /;
my $cmp = sub { $_[0]->value cmp $_[1] };
for (@list) {
    $node = $node->insertWith($cmp, $_);
}

diag $node->debug_tree;
diag join ',' => $node->leaves;
# diag Dumper($node);

BEGIN {
    no strict 'refs';
    for ('a'..'i') {
        *$_ = Tree::BinaryFP->mk_node($_);
    }
    *any = Tree::BinaryFP->mk_node( sub {1} );
}

$node->run_match( e(d,f),          'e(d,f)' );
$node->run_match( e(f,d),          'e(f,d)' );
$node->run_match( e(d,f)->reverse, 'e(d,f)->reverse' );
$node->run_match( e(undef,d), 'e(undef,d)' );
$node->run_match( e(f,undef), 'e(f,undef)' );
$node->run_match( any(any(any(any()))), 'any(any(any(any)))' );
$node->run_match( any(any(any(any(any())))), 'any x5');
$node->run_match( any(any(any(any(any(any()))))), 'any x6');
$node->run_match( any(any(any(any(any(any(any())))))), 'any x7');
$node->run_match( any(undef, any(undef, any)), 'any(undef, any(undef, any))' );

done_testing;
