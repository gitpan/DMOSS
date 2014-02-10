use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

use DMOSS::Oracle;

my $ora = DMOSS::Oracle->new;
ok(ref($ora) eq 'DMOSS::Oracle', 'new function');

