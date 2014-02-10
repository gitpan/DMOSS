use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

use DMOSS;

my $dmoss = DMOSS->new;
ok(ref($dmoss) eq 'DMOSS', 'new function');

