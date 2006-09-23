# $Id: Receiver.pm 105 2006-09-23 18:12:07Z rcaputo $

=head1 NAME

POE::Stage::Receiver - a simple UDP recv/send component

=head1 SYNOPSIS

	# Note, this is not a complete program.
	# See the distribution's examples directory.

	use POE::Stage::Receiver;
	my $stage = POE::Stage::Receiver->new();
	my $request = POE::Request->new(
		stage         => $stage,
		method        => "listen",
		on_datagram   => "handle_datagram",
		on_recv_error => "handle_error",
		on_send_error => "handle_error",
		args          => {
			bind_port   => 8675,
		},
	);

	# Echo the datagram back to its sender.
	sub handle_datagram {
		my ($self, $args) = @_;
		rsp()->recall(
			method            => "send",
			args              => {
				remote_address  => $args->{remote_address},
				datagram        => $args->{datagram},
			},
		);
	}

=head1 DESCRIPTION

POE::Stage::Receiver is a simple UDP receiver/sender stage.  Not only
is it easy to use, but it also rides the short bus for now.

Receiver has two public methods: listen() and send().  It emits a
small number of message types: datagram, recv_error, and send_error.

=cut

package POE::Stage::Receiver;

use warnings;
use strict;

use POE::Stage qw(:base req);

use POE::Watcher::Input;
use IO::Socket::INET;
use constant DATAGRAM_MAXLEN => 1024;

=head1 PUBLIC COMMANDS

Commands are invoked with POE::Request objects.

=head2 listen (bind_port => INTEGER)

Bind to a port on all local interfaces and begin listening for
datagrams.  The listen request should also map POE::Stage::Receiver's
message types to appropriate handlers.

=cut

sub listen {
	my ($self, $args) = @_;

	my $bind_port :Req = delete $args->{bind_port};

	my $socket :Req = IO::Socket::INET->new(
		Proto     => 'udp',
		LocalPort => $bind_port,
	);
	die "Can't create UDP socket: $!" unless $socket;

	my $udp_watcher :Req = POE::Watcher::Input->new(
		handle    => $socket,
		on_input  => "handle_input"
	);
}

sub handle_input {
	my ($self, $args) = @_;

	my $socket :Req;
	my $remote_address = recv(
		$socket,
		my $datagram = "",
		DATAGRAM_MAXLEN,
		0
	);

	if (defined $remote_address) {
		req->emit(
			type              => "datagram",
			args              => {
				datagram        => $datagram,
				remote_address  => $remote_address,
			},
		);
	}
	else {
		req->emit(
			type      => "recv_error",
			args      => {
				errnum  => $!+0,
				errstr  => "$!",
			},
		);
	}
}

=head2 send (datagram => SCALAR, remote_address => ADDRESS)

Send a datagram to a remote address.  Usually called via recall() to
respond to a datagram emitted by the Receiver.

=cut

sub send {
	my ($self, $args) = @_;

	my $socket :Req;
	return if send(
		$socket,
		$args->{datagram},
		0,
		$args->{remote_address},
	) == length($args->{datagram});

	req->emit(
		type      => "send_error",
		args      => {
			errnum  => $!+0,
			errstr  => "$!",
		},
	);
}

1;

=head1 PUBLIC RESPONSES

Responses are returned by POE::Request->return() or emit().

=head2 "datagram" (datagram, remote_address)

POE::Stage::Receiver emits a message of "datagram" type whenever it
successfully recv()s a datagram from some remote peer.  The datagram
message includes two parameters: "datagram" contains the received
data, and "remote_address" contains the address that sent the
datagram.

Both parameters can be pased back to the POE::Stage::Receiver's send()
method, as is done in the SYNOPSIS.

=head2 "recv_error" (errnum, errstr)

The stage encountered an error receiving from a peer.  "errnum" is the
numeric form of $! after recv() failed.  "errstr" is the error's
string form.

=head2 "send_error" (errnum, errstr)

The stage encountered an error receiving from a peer.  "errnum" is the
numeric form of $! after send() failed.  "errstr" is the error's
string form.

=head1 BUGS

See L<http://thirdlobe.com/projects/poe-stage/report/1> for known
issues.  See L<http://thirdlobe.com/projects/poe-stage/newticket> to
report one.

POE::Stage is too young for production use.  For example, its syntax
is still changing.  You probably know what you don't like, or what you
need that isn't included, so consider fixing or adding that.  It'll
bring POE::Stage that much closer to a usable release.

=head1 SEE ALSO

L<POE::Stage> and L<POE::Request>.  The examples/udp-peer.perl program
in POE::Stage's distribution.

=head1 AUTHORS

Rocco Caputo <rcaputo@cpan.org>.

=head1 LICENSE

POE::Stage::Receiver is Copyright 2005-2006 by Rocco Caputo.  All rights
are reserved.  You may use, modify, and/or distribute this module
under the same terms as Perl itself.

=cut