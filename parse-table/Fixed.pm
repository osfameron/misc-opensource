#!/usr/bin/perl

package Fixed;
use Moose ();
use Moose::Exporter;

Moose::Exporter->setup_import_methods(
   with_caller => ['column'],
   also        => 'Moose',
);

sub column {
    my $caller = shift;
    my ($name, %pars) = @_;
    $caller->meta->has($name => (
        traits => ['Fixed'],
        is     => 'ro',
        isa    => 'Str', # default
        %pars,
        ));
}

1;
