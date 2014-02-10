use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

use DMOSS::Attr;

my $attr = DMOSS::Attr->new;
ok(ref($attr) eq 'DMOSS::Attr', 'new function');

