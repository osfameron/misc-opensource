#!/usr/bin/perl

use MooseX::Declare;
class Zip {

    use MooseX::Types::Moose      qw[ Any Str Int ArrayRef CodeRef Bool ];
    use MooseX::Types::Structured qw[ Tuple ];
    use Scalar::Util           'blessed';

    has 'node' => (
        isa => Any, # or "Traversable" ?
        is  => 'ro',
        );
    has 'path_up' => (
        isa     => ArrayRef[ Tuple[ Str, Any ] ],
        is      => 'ro',
        default => sub { [] },
        );

    method traverse ($self: Str $child) {
        my $node = $self->node;
        my $new_node = blessed $node ? $node->$child : $node->{$child}; # POC only
        return Zip->new(
            node    => $new_node,
            path_up => [ @{ $self->path_up }, [ $child, $node ] ],
        );
    }

    method set ($self: Any $node) {
        return Zip->new(
            node    => $node,
            path_up => $self->path_up,
        );
    }
    method change_with_ ($self: CodeRef $code) {
        return $self->change_with(sub { 
            local $_ = shift;
            $code->();
            return $_
            });
    }

    method change_with ($self: CodeRef $code) {
        my $node = $self->node;
        my $new_node = $code->($node);
        return Zip->new(
            node    => $new_node,
            path_up => $self->path_up,
        );
    }
    
    method up ($self:) {
        my $node = $self->node;
        my @path = @{ $self->path_up }
            or return $node;

        my $up = pop @path;

        my ($child, $parent_node) = @{ $up };
        my $new_node = blessed $parent_node ?
            $parent_node->$child($node) # this is assuming ::Pure semantics, POC only
          : { %$parent_node, $child => $node };

        return Zip->new(
            node    => $new_node,
            path_up => \@path,
            );
    }
    method unzip ($zip:) {
        while (scalar @{$zip->path_up}) {
            $zip = $zip->up;
        }
        return $zip->node;
    }
}

package main;
use Data::Dumper;

my $x = { foo => { bar => { baz => 1 } } };

my $x1 = { %$x, foo => { bar => { %{ $x->{foo}->{bar} }, baz => $x->{foo}->{bar}->{baz} + 1 }}};

my $x2 = Zip->new(node=>$x1)
            ->traverse('foo')
            ->traverse('bar')
            ->traverse('baz')
            ->change_with (sub { (shift) * 10 })
            ->change_with_(sub { $_++ })
            ->unzip;

sub dive (&) {
    my $sub = shift;
    return sub {
        local $Zip::Node = Zip->new(node => shift);
        $sub->();
        return $Zip::Node->unzip;
        };
}
sub go {
    $Zip::Node = $Zip::Node->traverse($_) for @_;
}
sub set {
    $Zip::Node = $Zip::Node->set(shift);
}
sub change (&) {
    $Zip::Node = $Zip::Node->change_with(shift);
}
sub change_ (&) {
    $Zip::Node = $Zip::Node->change_with_(shift);
}

my $x3 = $x2->${ \dive { go qw/foo bar baz/; change { (shift)+100 }}};

my $x4 = $x3->${ \dive { go qw/foo bar baz/; set "Hello"; }};

warn Dumper($x, $x1, $x2, $x3, $x4);
