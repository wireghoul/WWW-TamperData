#!perl -T

use Test::More tests => 3;
use Data::Dumper;
use WWW::TamperData;


sub request_hook {
    my $arg = shift;
    warn Dumper($arg);
}


my $obj = WWW::TamperData->new(transcript => 't/test1.xml');
ok( $obj->request_filter('request_hook'));
ok( $obj->response_filter('request_hook'));
ok( $obj->replay() );
