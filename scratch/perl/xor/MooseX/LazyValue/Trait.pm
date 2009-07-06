package MooseX::LazyValue::Trait; 
use Moose::Role;
use Carp qw(confess);

around initialize_instance_slot => sub {
    my $original = shift;
    my ($self, $meta_instance, $instance, $params) = @_;

    my $init_arg = $self->init_arg(); # from %params
    if ( defined($init_arg) and exists $params->{$init_arg}) {
        my $val = $params->{$init_arg};
        $self->default($instance, $val);
        $self->meta->find_attribute_by_name('lazy')->set_value($instance, 1);
        use Data::Dumper;
        local $Data::Dumper::Indent =1; local $Data::Dumper::Maxdepth = 2;
        warn Dumper($self->meta->find_attribute_by_name('lazy'), $instance);
        warn "RARR, $init_arg ($val) (" . $self->is_lazy . ") (" . $self->default . ")";
        return;
    }
    # fallback
    $original->(@_);
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



