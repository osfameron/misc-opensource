package MooseX::LazyValue::Trait; 
use Moose::Role;
use Carp qw(confess);

around _process_options => sub {
    my ($original, $class, $name, $options) = @_;
    $options->{lazy}     = 1;
    $options->{default}  = sub { my $alt = "_${name}";  $_[0]->$alt->() };
    $original->($class, $name, $options);
};

around initialize_instance_slot => sub {
    my $original = shift;
    my ($self, $meta_instance, $instance, $params) = @_;

    my $init_arg = $self->init_arg(); # from %params
    if ( defined($init_arg) and exists $params->{$init_arg}) {

        my $alt_attr_name = "_${init_arg}";

        my $alt_attr = $instance->meta->add_attribute($alt_attr_name, 
            is       => 'ro',
            isa      => 'CodeRef',
            init_arg => $init_arg,
            );
        # just process the _alt slot
        $original->($alt_attr, $meta_instance, $instance, $params);
        # the actual slot is lazy, and doesn't need to be initialized yet!
        return;
    }
    # now do whatever original does
    $original->($self, $meta_instance, $instance, $params);
};

no Moose::Role;
1;

__END__

=pod

=head1 NAME

TODO docment

MooseX::MultiInitArg::Trait - A composable role to add multiple init arguments
to your attributes.

=head1 DESCRIPTION

This is a composable trait which you can add to an attribute so that you can 
specify a list of aliases for your attribute to be recognized as constructor
arguments.  

=head1 AUTHOR

Paul Driver, C<< <frodwith at cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright 2007-2008 by Paul Driver.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut



