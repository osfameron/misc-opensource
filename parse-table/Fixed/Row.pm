#!/usr/bin/perl

package Fixed::Row;

use Fixed;
use Fixed::Column;

use Moose::Util::TypeConstraints;
use DateTime::Format::DateParse;
use DateTime::Format::Duration;

subtype 'Date' =>
    as class_type('DateTime');

coerce 'Date'
    => from 'Str'
        => via { DateTime::Format::DateParse->parse_datetime( $_ ) };

subtype 'Duration' =>
    as class_type('DateTime::Duration');

coerce 'Duration'
    => from 'Str'
        => via { 
            my $d = DateTime::Format::Duration->new( pattern => '%H:%M' );
            $d->parse_duration( $_ );
            };

sub parse {
    my ($self, $string) = @_;
    my $class = ref $self || $self;
    my %attributes = %{ $self->meta->get_attribute_map };

    my %data = map {
        my ($k, $v) = ($_, $attributes{$_});
        $v->has_range ?
            do {
                my ($from, $to) = @{ $v->range };
                ($k => substr($string, $from, $to-$from+1) );
                }
            : ();
        } keys %attributes;

    return $class->new( %data );
}

1;
