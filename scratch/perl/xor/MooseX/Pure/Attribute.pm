package MooseX::Pure::Attribute;
use Moose;

extends q(Moose::Meta::Attribute);
with q(MooseX::Pure::Trait);

no Moose;

package # Move along, PAUSE...
    Moose::Meta::Attribute::Custom::Pure;

sub register_implementation { q(MooseX::Pure::Attribute) }

1;

__END__

=pod

TODO

=head1 NAME

MooseX::Pure::Attribute - see MooseX::Pure, MooseX::Pure::Trait

=head1 COPYRIGHT AND LICENSE

Copyright 2009 by osfameron

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
