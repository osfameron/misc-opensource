#!/usr/bin/perl
use strict; use warnings;

package Acme::Gosub::DD; # like Acme::Gosub::DD but no source filters
use Devel::Declare;

sub import {
    my $class = shift;
    my $caller = caller;

    Devel::Declare->setup_for( 
        $caller => { 
            gosub  => { const => mk_parse_gosub($caller) },
            retsub => { const => mk_parse_retsub($caller) },
                   } );

    no strict 'refs';
    *{$caller.'::gosub'} = sub {};
    *{$caller.'::retsub'} = sub {};
}

{
    our ($Declarator, $Offset);
    our $LABEL = "C01";

    sub skip_declarator;
    sub strip_name;
    sub strip_proto;

    sub mk_parse_gosub {
        my $package = shift;
        return sub {
            local ($Declarator, $Offset) = @_;
            skip_declarator;
            my $name = strip_name;

            my $linestr = Devel::Declare::get_linestr();
            substr($linestr, $Offset) 
                = qq{; local \$Gosub::Comefrom = "$LABEL"; goto $name; $LABEL\: };
            Devel::Declare::set_linestr($linestr);
            $LABEL++;
          };
    }
    sub mk_parse_retsub {
        my $package = shift;
        return sub {
            local ($Declarator, $Offset) = @_;
            skip_declarator;
            my $linestr = Devel::Declare::get_linestr();
            substr($linestr, $Offset) 
                = q{; goto $Gosub::Comefrom; };
            Devel::Declare::set_linestr($linestr);
          };
    }

    sub skip_declarator {
        $Offset += Devel::Declare::toke_move_past_token($Offset);
    }

    sub skipspace {
        $Offset += Devel::Declare::toke_skipspace($Offset);
    }

    sub strip_name {
        skipspace;
        if (my $len = Devel::Declare::toke_scan_word($Offset, 1)) {
            my $linestr = Devel::Declare::get_linestr();
            my $name = substr($linestr, $Offset, $len);
            substr($linestr, $Offset, $len) = '';
            Devel::Declare::set_linestr($linestr);
            return $name;
        }
        return;
    }

    sub shadow {
        my $pack = Devel::Declare::get_curstash_name;
        Devel::Declare::shadow_sub("${pack}::${Declarator}", $_[0]);
    }
}
            
1;
