#!/usr/bin/perl
use strict; use warnings;
use Data::Dumper;
use Test::More;

use Tree::RedBlackFP;
use Tree::RedBlackFP::Node;

sub node {
    my $class = 'Tree::RedBlackFP::Node';
    if (@_ == 1) {
        return $class->new({ data => @_ });
    }
    else {
        return $class->new({ @_ });
    }
}

my $node = node(
    data => 'Middle',
    left => node('Left'),
    right => node( 
        data => 'RM',
        left  => node('RL'),
        right => node('RR'),
        colour => 1,
    )
);
my %test = (
    Middle => 1,
    Hello  => 0,
    Goodbye => 0,
    Left    => 1,
    Wibbly  => 0,
    RL      => 1,
    Foo    => 0,
    RR => 1,
    Bar => 0
);
for (keys %test) {
    my $is_member = $node->member($_) || 0;
    is ($is_member, $test{$_}, "$_ found/not correctly ($test{$_})");
}

my $node2 = Tree::RedBlackFP->empty;
for (qw/
    souvent, pour s'amuser, les hommes d'équipage
    prennent des albatros, vastes oiseaux des mers,
    qui suivent, indolents compagnons de voyage,
    le navire glissant sur les gouffres amers.

    a peine les ont-ils déposés sur les planches,
    que ces rois de l'azur, maladroits et honteux,
    laissent piteusement leurs grandes ailes blanches
    comme des avirons traîner à côté d'eux.

    ce voyageur ailé, comme il est gauche et veule!
    lui, naguère si beau, qu'il est comique et laid!
    l'un agace son bec avec un brûle-gueule,
    l'autre mime, en boitant, l'infirme qui volait!

    le poète est semblable au prince des nuées
    qui hante la tempête et se rit de l'archer;
    exilé sur le sol au milieu des huées,
    ses ailes de géant l'empêchent de marcher.
/
) {
    $node2 = $node2->insert($_);
}

print "\n\n";
diag $node2->debug_tree;

done_testing;

