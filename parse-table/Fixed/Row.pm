#!/usr/bin/perl

package Fixed::Row;

use Fixed;

sub parse {
    my ($self, $string) = @_;
    my $class = ref $self || $self;
    my %attributes = %{ $self->meta->get_attribute_map };

    my %data = map {
        my ($k, $v) = ($_, $attributes{$_});
        $v->has_range ?
            do {
                my ($from, $to) = @{ $v->range };
                ($k => substr($string, $from, $to-$from) );
                }
            : ();
        } keys %attributes;

    return $class->new( %data );
}

1;