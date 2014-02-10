use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

use DMOSS::File;

my $file = DMOSS::File->new;
ok(ref($file) eq 'DMOSS::File', 'new function');

