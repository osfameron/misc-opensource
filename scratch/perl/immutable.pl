#!/usr/bin/perl

use MooseX::Declare;

class Foo {
    with 'MooseX::Clone';

    sub _immutable {
        my $field = shift;
        my $attr = __PACKAGE__->meta->find_attribute_by_name($field);
        my $meth = sub {
            my $self = shift;
            if (@_) {
                my $value = shift;
                return $self->clone( $field => $value );
            } else {
                return $attr->get_value($self);
            }
          };
        return { $field => $meth };
    }

    has 'foo' => (
        accessor => _immutable('foo'),
        traits => ['Clone'],
      );
    has 'bar' => (
        accessor => _immutable('bar'),
        traits => ['Clone'],
      );
    has 'baz' => (
        accessor => _immutable('baz'),
        traits => ['Clone'],
      );
}

use Data::Dumper;

my $x = Foo->new( foo=> 'foo', bar => 'bar', baz => 'baz' );
warn Dumper($x);
my $y = Foo->foo('newfoo');

warn Dumper($x, $y);
