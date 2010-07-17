#!/usr/bin/perl

use strict; use warnings;
use List;
use Data::Dumper;
local $Data::Dumper::Indent = 1;
local $Data::Dumper::Maxdepth = 2;

# dummy modules for things we want to run feeds about
use Event;
use User;
use Module;
use DateTime;

use KiokuDB;

{
    my @modules = map { Module->new(id=>$_) } 1..10;
    my @users   = map { User  ->new(id=>$_) } 1..10;

    sub make_event {
        my $date = shift || DateTime->now;
        my $event = Event->new(
            datestamp => $date,
            user      => $users[ int(rand(10)) ],
            subject   => $modules[ int(rand(10)) ],

            ((rand > 0.5) ? 
            (
                action    => 'completed',
                object    => int(rand(100)),
            )
            :
            (
                action    => 'started',
            ))
        );
        return List->node(  
            $event,
            sub { make_event($date->clone->subtract( days => 1)) }
            );
    }
}

{
    my $kioku = KiokuDB->connect('hash');
    my $scope = $kioku->new_scope;

    my $list = make_event(); 
        # this is an infinite list, to test that our functions are properly lazy :-)

    $kioku->store(list => $list);

    my $completions = $kioku->lookup('list')->Grep( sub { $_[0]->action eq 'completed' } );

    my $high_score  = $completions->Grep( sub { $_[0]->object >= 80 } );

    $kioku->store(high_scores => $high_score);

    my $h2 = $kioku->lookup( 'high_scores' );

    warn Dumper( [ $h2->Take(10)->to_array ] );
}
