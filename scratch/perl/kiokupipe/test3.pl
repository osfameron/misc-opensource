#!/usr/bin/perl

use strict; use warnings;
use List;
use Data::Dumper;
local $Data::Dumper::Indent = 1;
local $Data::Dumper::Maxdepth = 2;

# dummy modules for things we want to run feeds about
use Feed;
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
    }
    sub make_event_list {
        my $date = shift || DateTime->now;
        return List->node(  
            make_event($date),
            sub { make_event_list($date->clone->subtract( days => 1)) }
            );
    }
}

{
    my $kioku = KiokuDB->connect('hash');
    my $scope = $kioku->new_scope;

    my $list = make_event_list()->Take(20); 

    my $root_list = Feed->new( list => $list, store_as => 'root' );
    $root_list->store($kioku);

    my $completions = Feed->new(
        store_as => 'completions',
        from_feed => 'root',
        make_list => sub {
            my $root = shift;
            $root->Grep( sub { $_[0]->action eq 'completed' } );
        },
    );
    $completions->update($kioku);
    $completions->store($kioku);

    my $high_score = Feed->new(
        store_as => 'high_score',
        from_feed => 'completions',
        make_list => sub {
            my $completions = shift;
            $completions->Grep( sub { $_[0]->object >= 80 } );
        }
    );
    $high_score->update($kioku);
    $high_score->store($kioku);

    my $h2 = $kioku->lookup( 'high_score' );
    warn Dumper( [ $h2->list->take(2) ] );

    # now, let's add some more events

    for (1..10) {
        $root_list->add_event( make_event() );
    }

    $high_score->update($kioku);
    warn Dumper( [ $h2->list->take(5) ] ); # may be different from above
}
