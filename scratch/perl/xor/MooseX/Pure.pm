package MooseX::Pure;

use strict;
use warnings;

our $VERSION = '0.01';

use Moose ();
use Moose::Util::MetaRole;
use MooseX::Pure::Attribute;
use MooseX::Pure::Trait;
use MooseX::Clone;

Moose::Exporter->setup_import_methods;

# cargo culted from MooseX::AlwaysCoerce
sub init_meta {
    shift;
    my %options = @_;
    my $for_class = $options{for_class};

    MooseX::ClassAttribute->import({ into => $for_class });

    Moose::Util::MetaRole::apply_metaclass_roles(
        for_class => $for_class,
        attribute_metaclass_roles =>
            ['MooseX::Pure::Trait'],
        metaclass_roles =>
            ['MooseX::Clone'],
    );

    return $for_class->meta;
}

1;

__END__

=pod

TODO

=head1 NAME

MooseX::Pure - is 'pure' accessors for Moose

=head1 SYNOPSIS

  package Princess;
  use Moose;
  use MooseX::Pure;

  has 'hair' => (
      is  => 'pure',
      isa => 'HairType',
    );
  
  has 'favourite_dwarf' => (
      is  => 'pure',
      isa => 'Dwarf',
    );

  # ... later

  my $snow_white = Princess->new( 
      hair            => hair_type('long', 'black', 'shiny'),
      favourite_dwarf => $Happy
    );

  $snow_white_2 = $snow_white->favourite_dwarf($Grumpy);

  # Yay!  Snow White is still constant in her affections for Happy
  # $snow_white_2 is a new object, with the same hair type as before,
  # but differering just in the accessed value.

=head1 DESCRIPTION

Adds a 'pure' accessor creator, whose writer clones the object, returning
a new one, with just that attribute changed.

=head1 AUTHOR

osfameron, C<< <osfameron at cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright 2009 by ofameron.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


