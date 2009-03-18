#!/usr/bin/perl

package Fixed::Row;

use Fixed;
use Fixed::Column;

use Moose::Util::TypeConstraints;
use DateTime::Format::Strptime;
use DateTime::Format::Duration;

subtype 'Date' =>
    as class_type('DateTime');

coerce 'Date'
    => from 'Str'
        => via { 
            my $f = DateTime::Format::Strptime->new( pattern => '%F' );
            my $d = $f->parse_datetime( $_ );
            $d->set_formatter($f);
            $d;
            };

subtype 'Duration' =>
    as class_type('DateTime::Duration');

coerce 'Duration'
    => from 'Str'
        => via { 
            my $f = DateTime::Format::Duration->new( pattern => '%R' );
            my $d = $f->parse_duration( $_ );
            $d->{formatter} = $f;                      # direct access! Yuck!
            bless $d, 'DateTime::Duration::Formatted'; # rebless!
            return $d;
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

package DateTime::Duration::Formatted;
our @ISA = 'DateTime::Duration';

use overload q("") => sub {
    my ($self) = @_;
    my $f = $self->{formatter};
    return $f->format_duration_from_deltas($f->normalise($self));
    };

1;
