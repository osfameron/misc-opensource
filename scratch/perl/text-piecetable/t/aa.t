package main;
use strict; use warnings;
use Data::Dumper;

use Tree::AA;

# TODO, write some actual tests

{
    my $tree = Tree::AA->new;
    warn $tree->debug_tree;

    for (1..16) {
        $tree = $tree->insert($_);
    }
    warn $tree->debug_tree;
}
{
    my $tree = Tree::AA->new;
    warn $tree->debug_tree;

    for (reverse 1..16) {
        $tree = $tree->insert($_);
    }
    warn $tree->debug_tree;

    for (8..12) {
        $tree = $tree->delete($_);
    }
    warn $tree->debug_tree;
}
