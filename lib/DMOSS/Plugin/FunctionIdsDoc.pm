package DMOSS::Plugin::FunctionIdsDoc;
$DMOSS::Plugin::FunctionIdsDoc::VERSION = '0.01_1';
# ABSTRACT: DMOSS number identifiers found in docs plugin
use parent qw/DMOSS::Plugin/;
use strict;
use warnings;

use File::Slurp qw/read_file/;

our @types = qw/_SOURCE/;

sub name { 'Function Identifiers Found in Documentation' }

my $TMPDIR = '/tmp';  # FIXME
sub process {
  my ($self, $dmoss, $file) = @_;

  my $run = "curl -s -F \"upload_file=\@".$file->fullpath.';filename='.$file->path."\" http://conclave.di.uminho.pt/clang/ws";
  my $res = `$run`;

  my @ids;
  foreach (split /\n+/, $res) {
    if ($_ =~ m/^Function/) {
      my @l = split /,/, $_;
      push @ids, $l[2];
    }
  }

  my $corpus = join('/', $TMPDIR, $dmoss->{meta}->{dist}) . '.txt';
  unless (-e $corpus) {
    `dmoss-corpus $dmoss->{basedir} > $corpus`;
  }

  my $content = read_file $corpus;
  my $found = 0;
  foreach (@ids) {
    $found++ if ($content =~ m/\b$_\b/);
  }

  $dmoss->add_attr('ids', {found=>$found, total=>scalar(@ids) } );
}

sub reduce {
  my ($self, $dmoss, @attrs) = @_;
  my ($total, $found) = (0, 0);

  foreach (@attrs) {
    $total += $_->value->{total};
    $found += $_->value->{found};
  }

  $dmoss->add_attr('ids', {found=>$found, total=>$total} );
}

sub report {
  my ($self, $dmoss, $attr) = @_;
  return unless ($attr->value and keys %{$attr->value});
  return unless $attr->value->{total};
  my ($found, $total) = ($attr->value->{found}, $attr->value->{total});

  my $p = $total ? int($found/$total*100) : 0;
  return [ $attr->file->path, $found, $total, "$p%" ];

}

sub report_headers {
  my ($self, $dmoss) = @_;

  return [ '', 'Ids Found', 'Total Ids', '% Found' ];
}

sub grade {
  my ($self, $dmoss, $attr) = @_;
  my ($found, $total) = ($attr->value->{found}, $attr->value->{total});

  return ($total ? ($found/$total) : 0);

}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

DMOSS::Plugin::FunctionIdsDoc - DMOSS number identifiers found in docs plugin

=head1 VERSION

version 0.01_1

=head1 DESCRIPTION

This plugin verifies percentage of function identifiers are present in the
documentation.

=head1 AUTHOR

Nuno Carvalho <smash@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Project Natura <natura@natura.di.uminho.pt>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
