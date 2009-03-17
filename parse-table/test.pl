#!/usr/bin/perl

package Row::Name;
use Fixed;
extends 'Fixed::Row';

use DateTime::Format::DateParse;;

use Params::Coerce ();
use Moose::Util::TypeConstraints;

subtype 'My.DateTime' =>
    as class_type('DateTime');

coerce 'My.DateTime' 
    => from 'Str'
        => via { 
                 my $date = DateTime::Format::DateParse->parse_datetime( $_ );
                 warn "Gots $date ($_)";
                 $date; };

column first => range  => [0, 4 ];
column last  => range  => [5, 11];
column date  => range  => [12, 22], isa => 'My.DateTime', coerce => 1;

package main;

use Test::More tests => 3;

my $obj = Row::Name->parse('Fred Bloggs 2009-03-17');

isa_ok $obj, 'Row::Name';
is $obj->first, 'Fred';
is $obj->last,  'Bloggs';
isa_ok $obj->date, 'DateTime';

use Data::Dumper;
local $Data::Dumper::Maxdepth=1; local $Data::Dumper::Indent = 1;
diag Dumper($obj);
