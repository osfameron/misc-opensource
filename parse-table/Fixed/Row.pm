#!/usr/bin/perl

package Fixed::Row;

use Fixed;
use Fixed::Column;

use MooseX::ClassAttribute;
use Moose::Util::TypeConstraints;
use DateTime::Format::Strptime;
use DateTime::Format::Duration;
use List::Util qw/max/;

use overload q("") => sub { $_[0]->output };

class_has picture => (
    is        => 'rw',
    isa       => 'Str',
    predicate => 'has_picture',
    );

sub get_picture {
    my $self = shift;
    my %ranges = $self->range_attributes;
    my @ends = map { $_->range->[1] } values %ranges;
    return ' ' x max @ends;
}

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

sub range_attributes {
    my $self = shift;
    my $class = ref $self || $self;

    my %attributes = %{ $class->meta->get_attribute_map };
    return map { 
        my ($k, $v) = ($_, $attributes{$_});
        $v->has_range ?  ($k, $v) : (); 
        } 
        keys %attributes;
}

sub parse {
    my ($self, $string) = @_;
    my $class = ref $self || $self;

    my %ranges = $class->range_attributes;

    my %data;
    while (my ($k, $v) = each %ranges) {
        my ($from, $to) = @{ $v->range };
        $data{$k} = substr($string, $from, $to-$from+1);
    }

    return $class->new( %data );
}

sub output {
    my ($self) = @_;

    my %ranges = $self->range_attributes;

    my $string = $self->has_picture ? $self->picture : $self->picture($self->get_picture);

    for my $v (values %ranges) {
        my ($from, $to) = @{ $v->range };
        my $length = $to-$from;
        substr( $string, 
                $from => $length+1, 
                sprintf("\%${length}s", 
                    $v->get_value($self)));
    }
    return $string;
}

package DateTime::Duration::Formatted;
our @ISA = 'DateTime::Duration';

use overload q("") => sub {
    my ($self) = @_;
    my $f = $self->{formatter};
    return $f->format_duration_from_deltas($f->normalise($self));
    };

1;
