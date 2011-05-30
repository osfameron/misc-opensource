#!/usr/bin/perl
use strict; use warnings;
use Data::Dumper;
use Test::More;
use Test::LongString;
use feature 'say';

use Tree::BinaryFP;

my $node = Tree::BinaryFP->empty;

my @list = qw/ e d f c g b h a i /;
my $cmp = sub { $_[0]->value cmp $_[1] };
for (@list) {
    $node = $node->insertWith($cmp, $_);
}

is_string $node->debug_tree, <<EOT, 'Node created correctly';
        i
      h
    g
  f
e
  d
    c
      b
        a
EOT
is $node->debug_inorder, 'i,h,g,f,e,d,c,b,a', 'i,h,g,f,e,d,c,b,a';

BEGIN {
    no strict 'refs';
    for ('a'..'i') {
        *$_ = Tree::BinaryFP->mk_node($_);
    }
    *any = Tree::BinaryFP->mk_node( sub {1} );
    *A = Tree::BinaryFP->mk_node( sub { 1 } );
    *E = Tree::BinaryFP->mk_node( sub { shift->isEmpty } );
    *N = Tree::BinaryFP->mk_node( sub { ! shift->isEmpty } );
}

sub test_match {
    my ($node, $ok, $expr, $string) = @_;
    my @list = eval { $node->match($expr) };
    if (@list) {
        ok $ok, $string . ' MATCHED (' . (join ',' => map $_->show, @list) .')';
    }
    else {
        ok !$ok, "$string NO MATCH";
    }
    return @list;
}

test_match( $node, 0, e(d,f), 'e(d,f)' );
my ($e, $f, $d) = 
test_match( $node, 1, e(f,d), 'e(f,d)' );
test_match( $node, 1, e(f,any), 'e(f,any)' );

test_match( $node, 1, e(any,f)->reverse, 'e(any,f)->reverse' );
test_match( $node, 1, e(d,f)->reverse, 'e(d,f)->reverse' );
test_match( $node, 1, e(undef,d), 'e(undef,d)' );
test_match( $node, 1, e(f,undef), 'e(f,undef)' );
test_match( $node, 1, any(any(any(any()))),                'any x4');
test_match( $node, 1, any(any(any(any(any())))),           'any x5');
test_match( $node, 1, any(any(any(any(any(any()))))),      'any x6');
test_match( $node, 0, any(any(any(any(any(any(any())))))), 'any x7');
test_match( $node, 1, any(undef, any(undef, any)), 'any(undef, any(undef, any))' );

is_string $e->_delete->debug_tree, <<EOT, 'delete root node';
      i
    h
  g
f
  d
    c
      b
        a
EOT
is $d->_delete->debug_inorder, 'c,b,a', 'c,b,a';
is $f->_delete->debug_inorder, 'i,h,g', 'i,h,g';

done_testing;
