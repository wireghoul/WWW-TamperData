#!perl -T

use Test::More tests => 3;
use Data::Dumper;
use WWW::TamperData;


sub request_hook {
    my ($self, $td_hash) = @_;
    $td_hash->{tdRequestHeaders}{tdRequestHeader}{'User-Agent'}{content} = 'WWW::TamperData-'.WWW::TamperData->VERSION;
    warn "Request hook\n";
    warn Dumper($td_hash);
}

sub response_hook {
    my ($self, $td_hash, $response) = @_;
    warn "Response hook\n";
    warn Dumper($response);
}


my $obj = WWW::TamperData->new(transcript => 't/test1.xml');
ok( $obj->requestfilter('request_hook'));
ok( $obj->responsefilter('response_hook'));
ok( $obj->replay() );
