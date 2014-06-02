package main;
use strict; use warnings;
use Data::Dumper;

use Tree::AA;
use Test::More;
use Test::Exception;

sub create {
    my $tree = Tree::AA->new( cmp => sub { $_[0] <=> $_[1] } );
    for (@_) {
        $tree = $tree->insert($_);
    }
    $tree->debug_check_invariants;
    is_deeply [ $tree->keys ], [ sort { $a <=> $b } @_ ];
    return $tree;
}

subtest 'check invariants after addition ASC' => sub {
    create(1..16);
};

subtest 'check invariants after addition DESC' => sub {
    create(reverse 1..16);
};

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

subtest 'pairs' => sub {
    my $tree = create(1..4);
    is_deeply [ $tree->pairs ], [[1,undef], [2,undef], [3,undef], [4,undef ]];
};

subtest 'Check deletions' => sub {
    check_delete(1);
    check_delete(1..2);
    check_delete(1..3);
    check_delete(1..4);
    check_delete(1..5);
    check_delete(1..16);
    check_delete(reverse 1..16);
};

subtest 'fmap' => sub {
    my $tree = Tree::AA->new( cmp => sub { $_[0] <=> $_[1] } );
    for (1..3) {
        $tree = $tree->insert($_, $_);
    }
    is_deeply [ $tree->pairs ], [[1,1], [2,2], [3,3]];

    $tree = $tree->fmap( sub { $_[0] * 2 } );

    is_deeply [ $tree->pairs ], [[1,2], [2,4], [3,6]];
};

subtest 'insert with' => sub {
    my $tree = Tree::AA->new->insert( foo => 1 );

    dies_ok {
        $tree = $tree->insert( foo => 1 );
    } "By default, can't insert duplicate";

    lives_ok {
        $tree = $tree->insert( foo => 2, sub { $_[0] + $_[1] } );
        is_deeply [ $tree->pairs ], [[foo => 3 ]], 'merged value is ok';
    } 'Can insert when a sub is provided';

};

done_testing;
