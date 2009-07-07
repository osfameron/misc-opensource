package MooseX::Pure::Trait; 
use Moose::Role;
# use Scalar::Defer;

around _process_options => sub {
    my ($original, $class, $name, $options) = @_;
    if ($options->{is} eq 'pure') {

        # create getter/setter subs...
        $options->{is} = 'rw'; 

        # ... defined like this:
        my $attr; 
        my $accessor = sub {
            my $self = shift;
            $attr ||= $self->meta->find_attribute_by_name($name);
            if (@_) {
                my $value = shift;
                # the calling class will have with'd MooseX::Clone
                return $self->clone( $name => $value );
            } else {
                return $attr->get_value($self);
            }
          };
        $options->{accessor} = { $name => $accessor };
            my $self = shift;
    }
    $original->($class, $name, $options);
};

no Moose::Role;
1;

__END__

=pod

=head1 NAME

MooseX::Pure::Trait - A composable role to add pure accessors
to your attributes.

=head1 DESCRIPTION

This is a custom accessor, whose reader is as normal, but whose
writer actually clones the object with just that attribute
modified.

=head1 AUTHOR

osfameron, C<< osfameronfrodwith at cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright 2009 by osfameron

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
