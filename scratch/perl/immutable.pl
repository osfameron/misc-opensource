#!/usr/bin/perl

use MooseX::Declare;

class Foo {
    with 'MooseX::Clone';
    use Scalar::Defer;

    sub _immutable {
        my $field = shift;
        my $attr = lazy { __PACKAGE__->meta->find_attribute_by_name($field) };
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
      );
    has 'bar' => (
        accessor => _immutable('bar'),
      );
    has 'baz' => (
        accessor => _immutable('baz'),
      );
}

use Data::Dumper;

my $x = Foo->new( foo=> 'foo', bar => 'bar', baz => 'baz' );
my $y = $x->foo('newfoo');

warn Dumper($x, $y);

warn Dumper( $x->foo, $y->foo );
