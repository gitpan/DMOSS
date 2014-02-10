use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

use DMOSS::Report;

my $report = DMOSS::Report->new;
ok(ref($report) eq 'DMOSS::Report', 'new function');

