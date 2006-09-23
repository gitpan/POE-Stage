# $Id: Emit.pm 105 2006-09-23 18:12:07Z rcaputo $

=head1 NAME

POE::Request::Emit - encapsulates non-terminal replies to POE::Request

=head1 SYNOPSIS

	# Note, this is not a complete program.
	# See the distribution's examples directory.

	$poe_request_object->emit(
		type        => "failure",
		args        => {
			function  => "connect",
			errnum    => $!+0,
			errstr    => "$!",
		},
	);

=head1 DESCRIPTION

A POE::Request::Emit object is used to send an intermediate response
to a request.  It is internally created and sent when a stage calls
$self->{req}->emit(...).

An emitted reply does not cancel the request it is in response to.  A
stage may therefore emit multiple messages for a single request,
finally calling return() or cancel() to end the request.

=cut

package POE::Request::Emit;

use warnings;
use strict;
use Carp qw(croak confess);

use POE::Request::Upward qw(
	REQ_DELIVERY_RSP
	REQ_PARENT_REQUEST
	REQ_CREATE_STAGE
);

use base qw(POE::Request::Upward);

# Emitted requests may be recall()ed.  Therefore they need parentage.

sub _init_subclass {
	my ($self, $current_request) = @_;
	$self->[REQ_PARENT_REQUEST] = $current_request;
}

=head2 recall PAIRS

The stage receiving an emit()ted message may call recall() on it to
continue the dialogue after emit().  recall() sends a new
POE::Request::Recall message back to the stage that called emit().  In
this way, emit() and recall() can be used to continue a persistent
dialogue between two stages.

Once constructed, the recall message is automatically sent to the
source of the POE::Request::Emit object.

The PAIRS of parameters to recall() are for the most part passed
through to POE::Request::Recall's constructor.  You'll need to see
POE::Request::Recall for details about recall messages.

=cut

sub recall {
	my ($self, %args) = @_;

	# Where does the message go?
	# TODO - Have croak() reference the proper package/file/line.

	my $parent_stage = $self->[REQ_CREATE_STAGE];
	unless ($parent_stage) {
		confess "Cannot recall message: The requester is not a POE::Stage class";
	}

	# Validate the method.
	my $message_method = delete $args{method};
	croak "Message must have a 'method' parameter" unless(
		defined $message_method
	);

	# Reconstitute the parent's context.
	my $parent_context;
	my $parent_request = $self->[REQ_PARENT_REQUEST];
	croak "Cannot recall message: The requester has no context" unless (
		$parent_request
	);

	my $response = POE::Request::Recall->new(
		stage   => $parent_stage,
		method  => $message_method,
		args    => { %{ $args{args} || {} } },    # copy for safety?
	);
}

1;

=head1 BUGS

See L<http://thirdlobe.com/projects/poe-stage/report/1> for known
issues.  See L<http://thirdlobe.com/projects/poe-stage/newticket> to
report one.

POE::Stage is too young for production use.  For example, its syntax
is still changing.  You probably know what you don't like, or what you
need that isn't included, so consider fixing or adding that.  It'll
bring POE::Stage that much closer to a usable release.

=head1 SEE ALSO

L<POE::Request>, L<POE::Request::Recall>, and probably L<POE::Stage>.

=head1 AUTHORS

Rocco Caputo <rcaputo@cpan.org>.

=head1 LICENSE

POE::Request::Emit is Copyright 2005-2006 by Rocco Caputo.  All rights
are reserved.  You may use, modify, and/or distribute this module
under the same terms as Perl itself.

=cut