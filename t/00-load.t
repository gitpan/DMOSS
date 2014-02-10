#!perl -T

use Test::More tests => 7;

BEGIN {
  foreach (qw/DMOSS DMOSS::Oracle DMOSS::File DMOSS::Attr DMOSS::File DMOSS::Plugin DMOSS::Report/) {
    use_ok($_) || print "$_ failed to load!\n";
  }
}

