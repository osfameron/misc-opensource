#!/usr/bin/perl

package Fixed;
use Moose ();
use Fixed::Column;
use Moose::Exporter;
use Moose::Util::TypeConstraints;

Moose::Exporter->setup_import_methods(
   with_caller => ['column'],
   also        => ['Moose' ],
);

sub column {
    my $caller = shift;
    my ($name, %pars) = @_;
    $pars{isa} ||= 'Str';
    $pars{coerce}++ if do {
        my $t = find_type_constraint($pars{isa});
        $t && $t->has_coercion;
        };
    Moose::has( $caller => 
        $name => (
            traits => ['Column'],
            is     => 'ro',
            %pars,
            ));
}

1;
