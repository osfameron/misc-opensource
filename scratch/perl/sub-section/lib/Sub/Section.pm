#!/usr/bin/perl
use strict; use warnings;

package Sub::Section;
use Devel::Declare;
use base 'Exporter';
use Carp qw/croak/;
our @EXPORT = qw/mk_op mk_curry flip/;
use Memoize;

sub import {
    my $class = shift;
    my $caller = caller;

    Devel::Declare->setup_for( 
        $caller => { 
            op => { const => \&parse_op },
                   } );

    no strict 'refs';
    *{$caller.'::op'} = sub {}; # placeholder, this will then get shadowed

    goto &Exporter::import;
}
sub mk_op {
    my $string = shift;
    # from perldoc perlop

    no warnings 'qw';
    my @binops = qw{
        ->
        **
        =~ !~
        + - .
        * / % x
        << >>
        < > <= >= lt gt le ge
        == != <=> eq ne cmp ~~
        &
        | ^
        &&
        || //
        ..  ...
        , =>
        and
        or xor
        };

    my $bin_re = '\b' . (join '|' => map quotemeta, @binops) . '\b';

    my ($fn, @args);

    if ($string =~ /^(.*)($bin_re)$/) {
        return (
            mk_binop($2), 
            $1 ? ($1) : ()
            );
    }
    elsif ($string =~ /^($bin_re)(.*)$/) {
        return (
            flip(mk_binop($1)), 
            $2 ? ($2) : ()
            );
    }
}

sub mk_binop {
    my $op = shift;
    return mk_curry( eval "sub { \$_[0] $op \$_[1] }", 2 );
}
memoize 'mk_binop';

sub mk_curry {
    my ($fn, $n, @args) = @_;
    return sub {
        my $num_args = @args + @_;
        if ($num_args > $n) {
            croak "Called with $num_args, expected $n";
        }
        elsif ($num_args < $n) {
            return mk_curry($fn, $n, @args, @_);
        }
        else {
            return $fn->(@args, @_);
        }
        };
}
sub flip {
    my ($fn) = @_; # assume binop
    return mk_curry( sub { $fn->(reverse @_) }, 2 );
}

{
    our ($Declarator, $Offset);
    sub skip_declarator {
        $Offset += Devel::Declare::toke_move_past_token($Offset);
    }

    sub skipspace {
        $Offset += Devel::Declare::toke_skipspace($Offset);
    }

    sub strip_proto {
        skipspace;
    
        my $linestr = Devel::Declare::get_linestr();
        if (substr($linestr, $Offset, 1) eq '(') {
            my $length = Devel::Declare::toke_scan_str($Offset);
            my $proto = Devel::Declare::get_lex_stuff();
            Devel::Declare::clear_lex_stuff();
            $linestr = Devel::Declare::get_linestr();
            substr($linestr, $Offset, $length) = '';
            Devel::Declare::set_linestr($linestr);
            return $proto;
        }
        return;
    }

    sub shadow {
        my $pack = Devel::Declare::get_curstash_name;
        Devel::Declare::shadow_sub("${pack}::${Declarator}", $_[0]);
    }

    sub inject {
        my $inject = shift || '';
        skipspace;
        my $linestr = Devel::Declare::get_linestr;
        substr($linestr, $Offset, 0) = ' ' . $inject;
        Devel::Declare::set_linestr($linestr);
    }

    # This parser is likely to be semi-standard
    # It will call a make_proto_unwrap, which is likely to be heavily customized
    sub parse_op {
        local ($Declarator, $Offset) = @_;
        skip_declarator;
        my $proto = strip_proto;

        my ($fn, $arg) = mk_op($proto);

        inject( length $arg ? "->($arg)" : '' );

        shadow($fn);
    }

}

=for OTHER OPS
          (TODO: we should probably handle unary ops too)
           right       ! ~ \ and unary + and -
           nonassoc    named unary operators
           right       ?:
           right       not
=cut
            
1;
