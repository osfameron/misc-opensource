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
        warn "Node is $node";
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
        warn "New node is $node -> $new_node";
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

my $y = Zip->new(node=>$x)
            ->traverse('foo')
            ->traverse('bar')
            ->traverse('baz')
            ->change_with (sub { (shift) * 10 })
            ->change_with_(sub { $_++ })
            ->unzip;
warn Dumper($y); # ... { baz => 11 }
