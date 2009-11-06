use strict; use warnings;
use Template;

use Test::More tests => 1;
use Test::Exception;

my $tt = Template->new({
    INCLUDE_PATH => [ 'tt' ],
    RELATIVE     => 1,
    });

lives_ok {
    $tt->process( 'path/my.tt' )
        || die $tt->error;
    };

#   Failed test at t/template.t line 15.
# died: Template::Exception (file error - parse error - my.tt line 59: unexpected token (.)
#   [% INCLUDE ./main_nav %])
# Looks like you failed 1 test of 1.
