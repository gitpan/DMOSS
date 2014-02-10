use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

use DMOSS::Plugin;

my $plugin = DMOSS::Plugin->new;
ok(ref($plugin) eq 'DMOSS::Plugin', 'new function');

