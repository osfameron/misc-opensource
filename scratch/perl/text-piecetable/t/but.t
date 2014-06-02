
package Foo;
use Moo;
with 'MooX::Role::But';

has number => (
    is => 'ro',
);

has child => (
    is => 'ro',
);

sub add_number {
    my ($self, $add) = @_;
    return $self->but(
        number => $self->number + $add,
    );
}

package main;
use strict; use warnings;
use Test::More;

my $struct = Foo->new(
    number => 1,
    child => Foo->new(
        number => 2,
        child => Foo->new(
            number => 3,
            child => Foo->new(
                number => 4
            )
        )
    )
);

subtest "Sanity check - the current way" => sub {

    my $struct = $struct
        ->add_number(15)
        ->but(child => $struct->child->add_number(10)
            ->but( child => $struct->child->child->add_number(5)
                ->but( child => $struct->child->child->child->add_number(1))));
        
    is_deeply $struct,
        bless { number => 16, child =>
            bless { number => 12, child =>
                bless {
                    number => 8,
                    child => bless {
                        number => 5,
                    }, 'Foo',
                }, 'Foo'
            }, 'Foo'
        }, 'Foo';
};

subtest "With zipper" => sub {

    my $struct = $struct->traverse
        # ->set(number => 16)
        ->call(add_number => 15)
        ->go('child')->call(add_number => 10)
        ->go('child')->call(add_number => 5)
        ->go('child')->call(add_number => 1)
        ->focus;

    is_deeply $struct,
        bless { number => 16, child =>
            bless { number => 12, child =>
                bless {
                    number => 8,
                    child => bless {
                        number => 5,
                    }, 'Foo',
                }, 'Foo'
            }, 'Foo'
        }, 'Foo';
};


done_testing;
