#!/usr/bin/perl

package Fixed::Row;

use Fixed;
use Fixed::Column;

use Moose::Util::TypeConstraints;
use DateTime::Format::DateParse;

subtype 'My.DateTime' =>
    as class_type('DateTime');

coerce 'My.DateTime'
    => from 'Str'
        => via { DateTime::Format::DateParse->parse_datetime( $_ ) };

sub parse {
    my ($self, $string) = @_;
    my $class = ref $self || $self;
    my %attributes = %{ $self->meta->get_attribute_map };

    my %data = map {
        my ($k, $v) = ($_, $attributes{$_});
        $v->has_range ?
            do {
                my ($from, $to) = @{ $v->range };
                $to ||= $from;
                ($k => substr($string, $from, $to-$from) );
                }
            : ();
        } keys %attributes;

    return $class->new( %data );
}

1;
