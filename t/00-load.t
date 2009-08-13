#!perl -T

use Test::More tests => 4;

BEGIN {
	use_ok( 'WWW::TamperData' );
    my $obj = WWW::TamperData->new(transcript => 't/test1.xml');
    isa_ok( $obj, 'WWW::TamperData' );
    ok( $obj->request_filter('return'));
    ok( $obj->response_filter('return'));
}

diag( "Testing WWW::TamperData $WWW::TamperData::VERSION, Perl $], $^X" );
