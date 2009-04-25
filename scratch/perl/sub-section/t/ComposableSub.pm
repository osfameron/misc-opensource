#!/usr/bin/perl
use strict; use warnings;
use Data::Dumper;

# use Sub::Compose::Dot;
package ComposableSub;

# use Sub::Compose qw( chain ); # doesn't fucking work, due to scalar/list context shenanigans
sub chain {
 my (@subs) = @_;

 use Sub::Name;
 my $sub = subname chainer => sub {
     foreach my $sub ( @subs ) {
         @_ = $sub->( @_ );
     }
     return wantarray ? @_ : $_[0];
 };
 bless $sub, __PACKAGE__;
}

use overload '<<' => sub {
    my ($fn, $fn2) = @_;

    return chain( $fn2, $fn );
  };

1;
