# $Id: Makefile.PL 38 2005-07-12 23:38:42Z rcaputo $

use ExtUtils::MakeMaker;

# Touch CHANGES so it exists.
open(CHANGES, ">>CHANGES") and close CHANGES;

WriteMakefile(
  NAME         => 'POE::Stage',
  AUTHOR       => 'Rocco Caputo <rcaputo@cpan.org>',
  ABSTRACT     => 'a prototype of a successor to POE::Component',
  VERSION_FROM => 'lib/POE/Stage.pm',
  PREREQ_PM    => {
    POE        => 0.31,
    Test::More => 0,
  },
  dist         => {
    COMPRESS   => 'gzip -9f',
    SUFFIX     => 'gz',
    PREOP      => (
      'svn-log.perl | tee ./$(DISTNAME)-$(VERSION)/CHANGES > ./CHANGES'
    ),
  },
);
