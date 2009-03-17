#!/usr/bin/perl

package Fixed;
use Moose ();
use Fixed::Column;
use Moose::Exporter;

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

Moose::Exporter->setup_import_methods(
   with_caller => ['column'],
   also        => ['Moose' ],
);

sub column {
    my $caller = shift;
    my ($name, %pars) = @_;
    $pars{coerce}++ if ($pars{isa}||='Str') =~ /^My\./;
    eval <<"EOHACK";
package $caller;
has $name => (
    traits => ['Column'],
    is     => 'ro',
    %pars,
    );
EOHACK
die $@ if $@;
}

1;
