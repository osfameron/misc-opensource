#!/usr/bin/perl

use strict; use warnings;
use List;
use Data::Dumper;
use PerlX::MethodCallWithBlock;
local $Data::Dumper::Indent = 1;
local $Data::Dumper::Maxdepth = 2;

# dummy modules for things we want to run feeds about
use Feed;
use Event;
use User;
use Module;
use DateTime;

# Deps: KiokuDB, SQL::Translator (for deploy)
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

    my $create = shift @ARGV;

    my $kioku = KiokuDB->connect("dbi:mysql:dbname=kioku;user=root;password=password", 
        create => $create);

    my $scope = $kioku->new_scope;

    if ($create) {
        my $list = make_event_list()->Take(40); 

        my $root_list = Feed->create( 
            $kioku,
            list => $list, 
            store_as => 'root' );

        my $completions = Feed->create(
            $kioku,
            store_as => 'completions',
            from_feed => 'root',
            make_list => sub {
                my $root = shift;
                $root->Grep { $_[0]->action eq 'completed' };
            },
        );

        my $high_score = Feed->create(
            $kioku,
            store_as => 'high_score',
            from_feed => 'completions',
            make_list => sub {
                my $completions = shift;
                $completions->Grep { $_[0]->object >= 80 } };
            }
        );
    }

    my $root_list = $kioku->lookup( 'root' );
    my $h2        = $kioku->lookup( 'high_score' );
    warn Dumper( [ $h2->list->Take(2)->to_array ] );
    warn Dumper( $h2->list->Take(2) );

    # now, let's add some more events

    for (1..10) {
        $root_list->add_event( make_event() );
    }
    $h2->update($kioku);

    my $h3 = $kioku->lookup( 'high_score' );
    warn Dumper( [ $h3->list->Take(5)->to_array ] ); # may be different from above
}
