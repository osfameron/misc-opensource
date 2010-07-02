#!/usr/bin/perl

use strict; use warnings;
use feature 'say';

{
    package Context;
    use Moose;
    use Template;
    has user_name => is => 'ro', isa => 'Str';
    has location  => is => 'ro', isa => 'Int';
    has is_admin  => is => 'ro', isa => 'Bool';
    has stash     => is => 'rw', isa => 'HashRef', default => sub { {} };

    has tt =>
        is  => 'ro',
        isa => 'Template',
        default => sub { Template->new };

    my @locations = map {
        {
            id   => $_->[0],
            name => $_->[1],
        }
    } (
        [ 1 => 'Retail' ],
        [ 2 => 'Call Centre' ],
        [ 3 => 'Sales' ],
    );

    sub get_list_of_locations {
        my $self = shift;
        if ($self->is_admin) {
            return @locations;
        }
        else {
            return grep { $_->{id} == $self->location } @locations;
        }
    }
}
{
    package Widgets;
    use Moose;
    use MooseX::Types::Set::Object;

    has context => is => 'ro', isa => 'Context';

    has styles => 
        is => 'rw', 
        isa => 'Set::Object',
        default => sub { Set::Object->new() },
        coerce => 1,
        handles => {
            all_styles => 'members',
            add_style  => 'insert',
        };
    has inline_styles =>
        is => 'rw', 
        isa => 'ArrayRef[Str]',
        traits => ['Array'],
        default => sub { [] },
        coerce => 1,
        handles => {
            all_inline_styles => 'elements',
            add_inline_style  => 'push',
        };
    has scripts => 
        is => 'rw', 
        isa => 'Set::Object',
        default => sub { Set::Object->new() },
        handles => {
            all_scripts => 'members',
            add_script  => 'insert',
        };
    has inline_scripts => 
        is => 'rw', 
        isa => 'ArrayRef[Str]',
        traits => ['Array'],
        default => sub { [] },
        handles => {
            all_inline_scripts => 'elements',
            add_inline_script  => 'push',
        };

    sub widget {
        my ($self, %param) = @_;
        $param{widget_name} ||= do {
            my $caller_sub = (caller(1))[3];
            $caller_sub =~s/^.*::([^:]+)$/$1/;
            $caller_sub;
            };
        $param{field_name} ||= $param{widget_name}; # the field_name
        my $c = $self->context;
        $param{value} = $c->stash->{$param{field_name}};

        $param{template} ||= $param{widget_name} . '.tt';
        warn "GOTS $param{template}";

        my $tt = $self->context->tt;

        for my $style (@{ $param{styles} || [] }) {
            $self->add_style($style);
        }
        for my $script (@{ $param{scripts} || [] }) {
            $self->add_script($script);
        }
        for my $inline_style (@{ $param{inline_styles} || [] }) {
            my $style;
            $tt->process( \$inline_style, { %param }, \$style )
                or die $tt->error;
            $self->add_inline_style($style);
        }
        for my $inline_script (@{ $param{inline_scripts} || [] }) {
            my $script;
            $tt->process( \$inline_script, { %param }, \$script )
                or die $tt->error;
            $self->add_inline_script($script);
        }

        warn "NOW $param{template}";
        my $widget;
        $tt->process( 
            $param{template},
            { 
                %{ $c->stash }, # for sticky values etc.
                %param,
            },
            \$widget)
            or warn $tt->error . " $param{template}";
        return $widget;
    }

    sub location_select {
        my ($self, %param) = @_;
        return $self->widget(
            %param,
            data => {
                locations => [ $self->context->get_list_of_locations ],
            },
            styles  => ['/css/location_select.css'],
            scripts => ['/js/location_select.js'],
            inline_scripts => [<<'EOF'],
                $('#[% field_name %]').fooble(); // apply location_select.js magic!
EOF
        );
    }
}

{
    package main;
    use Data::Dumper;
    local $Data::Dumper::Maxdepth = 3;
    local $Data::Dumper::Indent = 1;

    for my $admin_value (undef, 1) {
        my $c = Context->new( 
            user_name => 'test', 
            is_admin  => $admin_value, 
            location  => 2,
            );
        my $tt = $c->tt;

        $c->stash->{widgets} = Widgets->new( context => $c );
        $c->stash->{location_select} = 2;


        my $template = 'widget_test.tt';
        my $output;

        $tt->process( $template,
                      $c->stash,
                      \$output )
            or die $tt->error . " ($template) " . Dumper($c->stash);
        say "**********************";
        say $output;
    }
}

