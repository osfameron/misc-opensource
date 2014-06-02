package main;
use strict; use warnings;
use Data::Dumper;

use Tree::AA;
use Test::More;

sub create {
    my $tree = Tree::AA->new( cmp => sub { $_[0] cmp $_[1] } );
    for (@_) {
        $tree = $tree->insert($_);
    }
    return $tree;
}

ok create(1..16)->debug_check_invariants, 'checked invariants after addition ASC';
ok create(reverse 1..16)->debug_check_invariants, 'checked invariants after addition DESC';

sub check_delete {
    my $tree = create(@_);
    my $was = $tree;
    for (@_) {
        $tree = $tree->delete($_);
        ok $tree->debug_check_invariants, "checked invariants after deletion of $_"
            or do {
                diag $tree->debug_tree;
                diag "WAS " . $was->debug_tree;
                last;
            }
    }
    ok ! $tree->root->level, 'Tree fully deleted';
}

check_delete(1);
check_delete(1..2);
check_delete(1..3);
check_delete(1..4);
check_delete(1..5);
check_delete(1..16);
check_delete(reverse 1..16);

done_testing;
