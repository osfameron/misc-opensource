#!/usr/bin/perl
use strict; use warnings;

package Lazy::Tests;
use Template;

sub lazy {
    my ($var, $exp, $my) = @_ ;
    $my = $my ? 'my' : '';
    return "$my $var = lazy { $exp };";
}

my @data = (

    {
        module => 'Scalar::Lazy',
        lazy   => \&lazy,
    },

    {
        module => 'Data::Thunk',
        lazy   => \&lazy,
    },

    {
        module => 'Variable::Lazy',
        lazy   => sub 
            { 
                my ($var, $exp, $my) = @_ ; 
                $my = $my ? 'my' : '';
                "lazy $my $var = { $exp };" 
            },
    },
);

my $tt = Template->new;
for my $module (@data) {
    ( my $name = lc $module->{module} ) =~ s/::/-/g;
    $module->{name} = $name;

    $tt->process( 'lazy.tt', $module, "t/$name.t" );
}
