#!/usr/bin/perl
use strict; use warnings;

package Lazy::Tests;
use Template;

sub lazy {
    my ($var, $exp, $my) = @_ ;
    $my = $my ? 'my' : '';
    return $var ?
        "$my $var = lazy { $exp };"
      : "lazy { $exp }";
}

my @data = (

    {
        module => 'Scalar::Lazy',
        lazy   => \&lazy,
        anon   => 1,
    },

    {
        module => 'Data::Thunk',
        lazy   => \&lazy,
        anon   => 1,
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

    {
        module => 'Scalar::Defer',
        lazy   => \&lazy,
        anon   => 1,
    },
);

my $tt = Template->new;
my $count = 0;

for my $module (@data) {
    ( my $name = lc $module->{module} ) =~ s/::/-/g;
    $module->{name} = $name;

    $tt->process( 'lazy.tt', $module, (sprintf 't/%02d-%s.t', $count++, $name ));
}
