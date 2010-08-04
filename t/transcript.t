#!perl -T

use Test::More tests => 3;
use Data::Dumper;
use WWW::TamperData;


sub request_hook {
    my $arg = shift;
    $arg->{tdRequestHeaders}->{tdRequestHeader}->{'User-Agent'}->{content} = 'WWW::TamperData';
    warn Dumper($arg);
}

sub response_hook {
    my $arg = shift;
}


my $obj = WWW::TamperData->new(transcript => 't/test1.xml');
ok( $obj->request_filter('request_hook'));
ok( $obj->response_filter('response_hook'));
ok( $obj->replay() );
