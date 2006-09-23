# $Id: Watcher.pm 105 2006-09-23 18:12:07Z rcaputo $

package POE::Watcher;

use warnings;
use strict;

1;

=head1 NAME

POE::Watcher - a base class for POE::Stage's event watchers

=head1 SYNOPSIS

	This module is meant to be subclassed, not used directly.

=head1 DESCRIPTION

POE::Watcher is a base class for POE::Stage event watchers.  It is
purely virtual at this time.  Common watcher code will eventually be
hoisted into it once patterns emerge from POE::Stage's suite of event
watchers.

POE::Watcher classes encapsulate POE::Kernel's event watchers.  They
allocate POE::Kernel watchers at creation time, and they release them
during destruction.  It is therefore important to keep references to
POE::Watcher objects until they are no longer needed.

The best place to store POE::Watcher objects is probably the current
stage's request continuation.  Should the request be canceled for some
reason, $self->{req} will go away, and so will all the watchers stored
within its continuation.  Use of this convention automates a lot of
cleanup associated with request cancellation.

=head1 DESIGN GOALS

Provide a simpler, extensible interface to POE::Kernel event watchers.
Watcher and event parameters are given names, eliminating the rote
memorization of positional arguments.

Watcher destruction is triggered by Perl reference counting rather
than reference counts maintained in the library.  Watchers' lifetimes
are explicit and easily understood.

Watcher cleanup is automated.  POE::Component classes must track every
active request and its watchers, and they must explicitly destroy them
at the end of a request.

Watchers are subclassable, layering new features atop basic watchers.

Watchers are restartable.  A POE::Watcher object can outlive the
POE::Kernel resource it hides.  It can be restarted, using the same
parameters to create another POE::Kernel resource.

=head1 BUGS

See L<http://thirdlobe.com/projects/poe-stage/report/1> for known
issues.  See L<http://thirdlobe.com/projects/poe-stage/newticket> to
report one.

POE::Stage is too young for production use.  For example, its syntax
is still changing.  You probably know what you don't like, or what you
need that isn't included, so consider fixing or adding that.  It'll
bring POE::Stage that much closer to a usable release.

=head1 SEE ALSO

POE::Watcher subclasses may have additional features and methods.
Please see their corresponding documentation.

=head1 AUTHORS

Rocco Caputo <rcaputo@cpan.org>.

=head1 LICENSE

POE::Watcher is Copyright 2005-2006 by Rocco Caputo.  All rights are
reserved.  You may use, modify, and/or distribute this module under
the same terms as Perl itself.

=cut