#!perl -T

use Test::More tests => 3;
use Data::Dumper;
use WWW::TamperData;


sub request_hook {
    my $arg = shift;
    $arg->{tdRequestHeaders}->{tdRequestHeader}->{'User-Agent'}->{content} = 'WWW::TamperData-'.WWW::TamperData->VERSION;
    warn "Request hook\n";
    warn Dumper($arg);
}

sub response_hook {
    my ($tdobj, $response) = @_;
    warn "Response hook\n";
    warn Dumper($response);
}


my $obj = WWW::TamperData->new(transcript => 't/test1.xml');
ok( $obj->requestfilter('request_hook'));
ok( $obj->responsefilter('response_hook'));
ok( $obj->replay() );
