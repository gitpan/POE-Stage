#!/usr/bin/perl
# $Id: ping-pong.perl 99 2006-08-14 02:21:22Z rcaputo $

# Illustrate the pattern of many one request per response, where each
# response triggers another request.  This often leads to infinite
# recursion and stacks blowing up, so it's important to be sure the
# system works right in this case.

use warnings;
use strict;

{
	# The application is itself a POE::Stage.

	package App;

	use warnings;
	use strict;

	use POE::Stage::Echoer;
	use POE::Stage qw(:base self);

	sub run {
		my $echoer :Req = POE::Stage::Echoer->new();
		my $i :Req = 1;

		self->send_request();
	}

	sub got_echo {
		my $echo :Arg;

		print "got echo: $echo\n";

		my $i :Req;
		$i++;

		# Comment out this line to run indefinitely.  Great for checking
		# for memory leaks.
#		return if $i > 10;

		self->send_request();
	}

	sub send_request {
		my ($i, $echoer) :Req;
		my $echo_request :Req = POE::Request->new(
			stage     => $echoer,
			method    => "echo",
			on_echo   => "got_echo",
			args      => {
				message => "request $i",
			},
		);
	}
}

# TODO - Perhaps a magical App->run() could encapsulate the standard
# instantiation, initial requesting, and loop execution that goes on
# here.

my $app = App->new();

my $req = POE::Request->new(
	stage   => $app,
	method  => "run",
);

POE::Kernel->run();
exit;
