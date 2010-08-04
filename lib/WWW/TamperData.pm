package WWW::TamperData;

use warnings;
#use strict;
use Carp;
use XML::Simple;
use HTTP::Request;
use LWP::UserAgent;

=head1 NAME

WWW::TamperData - Replay tamper data xml files

=head1 VERSION

Version 0.09

=cut

# Globals
our $VERSION = '0.1';
our $AUTHOR = 'Eldar Marcussen - http://www.justanotherhacker.com';
our $_tamperagent;
our $_tamperxml;

=head1 SYNOPSIS

Tamperdata is a firefox extension that lets you intercept or inspect browser requests and the server responses. WWW::TamperData can replay
requests exported to an xml file from tamperdata.

Replaying a file can be as simple as:

    use WWW::TamperData;

    my $foo = WWW::TamperData->new(transcript => "myfile.xml");
    my %data = $foo->replay();

=head1 FUNCTIONS

=head2 new

Initializes the new object, it takes some options;

=over 4

=item WWW::TamperData->new(%options);

    KEY             DEFAULT                 USE
    -------         -----------------       ------------------------------------
    transcript      tamperdata.xml          Filename to read tamperdata xml from
    timeout         60                      LWP connection timeout

=back

=cut

sub new {
    my ($class, %options) = @_;
    my $self = {};

    $self->{'transcript'} = $options{'transcript'} ? $options{'transcript'} : "tamperdata.xml";
    $self->{'timeout'}    = $options{'timeout'} ? $options{'timeout'} : 60;

    $_tamperxml = XMLin($self->{'transcript'});
    $_tamperagent = LWP::UserAgent->new;
    $_tamperagent->timeout($self->{'timeout'});
    return bless $self, $class;
}

=head2 replay

This function will replay all the requests provided in the xml file in sequential order.

=cut

#TODO: Add delay between requests
sub replay {
    my $self = shift;
    if (ref($_tamperxml->{tdRequest}) eq 'ARRAY') {
        for my $x (0..scalar($_tamperxml->{tdRequest})) {
        #    $_tamperxml->{tdRequest}->[$x]->{uri} =~ s/%([0-9A-F][0-9A-F])/pack("c",hex($1))/gei;
        #    my $request = HTTP::Request->new($_tamperxml->{tdRequest}->[$x]->{tdRequestMethod} => "$_tamperxml->{tdRequest}->[$x]->{uri}");
        #    my $response = $_tamperagent->get($request);
        #    if (!$response->is_success) {
        #        croak $response->status_line;
        #    }
        $self->_make_request($_tamperxml->{tdRequest}->[$x]);

        }
    } else {
        #$_tamperxml->{tdRequest}->{uri} =~ s/%([0-9A-F][0-9A-F])/pack("c",hex($1))/gei;
        #my $request = HTTP::Request->new($_tamperxml->{tdRequest}->{tdRequestMethod} => "$_tamperxml->{tdRequest}->{uri}");
        #my $response = $_tamperagent->get($request);
        #if (!$response->is_success) {
        #    croak $response->status_line;
        #}
        $self->_make_request($_tamperxml->{tdRequest});
    }
}

=head2 request_filter

Callback function that allows inspection/tampering of the uri and parameters before the request is performed.

=cut

sub request_filter {
    my ($self, $callback) = @_;
    $self->{request_filter}->{module} = caller;
    $self->{request_filter}->{function} = $callback;
}

=head2 response_filter

Callback function that allows inspection of the response object.

=cut

sub response_filter {
    my ($self, $callback) = @_;
    $self->{response_filter}->{module} = caller;
    $self->{response_filter}->{function} = $callback;
}

sub _make_request {
    my ($self, $uriobj) = @_;
    if ($self->{request_filter}) {
        eval "$self->{request_filter}->{module}::$self->{request_filter}->{function}(\$uriobj);";
    }
    $uriobj->{uri} =~ s/%([0-9A-F][0-9A-F])/pack("c",hex($1))/gei;
    my $request = HTTP::Request->new($uriobj->{tdRequestMethod} => "$uriobj->{uri}");
    foreach my $header (keys( %{ $uriobj->{tdRequestHeaders}->{tdRequestHeader} } )) {
        $uriobj->{tdRequestHeaders}->{tdRequestHeader}->{$header}->{content} =~ s/%([0-9A-F][0-9A-F])/pack("c",hex($1))/gei;
        $request->push_header($header => $uriobj->{tdRequestHeaders}->{tdRequestHeader}->{$header}->{content});
    }
    my $response = $_tamperagent->request($request);
    if ($self->{response_filter}) {
        eval "$self->{response_filter}->{module}::$self->{response_filter}->{function}(\$uriobj);";
    }
    if (!$response->is_success) {
        croak $response->status_line;
    }
    return $response;
}
=head1 AUTHOR

Eldar Marcussen, C<< <japh at justanotherhacker.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-www-tamperdata at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-TamperData>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::TamperData


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-TamperData>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-TamperData>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-TamperData>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-TamperData>

=back


=head1 COPYRIGHT & LICENSE

Copyright 2009 Eldar Marcussen, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of WWW::TamperData
