#!/usr/bin/perl

package Fixed;
use Moose ();
use Fixed::Column;
use Moose::Exporter;
use Moose::Util::TypeConstraints;

Moose::Exporter->setup_import_methods(
   with_caller => ['column', 'pic'],
   also        => ['Moose' ],
);

sub pic {
    my $caller = shift;
    my $pic = shift;

    $caller->add_field($pic);
}

sub column {
    my $caller = shift;
    my ($name, %pars) = @_;
    $pars{isa} ||= 'Str';
    $pars{coerce}++ if do {
        my $t = find_type_constraint($pars{isa});
        $t && $t->has_coercion;
        };
    my $attr = $caller->meta->add_attribute(
        $name => (
            traits => ['Column'],
            is     => 'ro',
            %pars,
            ));
    $caller->add_field($attr);
}

1;
