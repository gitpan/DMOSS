package DMOSS::Plugin::VerifyLicense;
$DMOSS::Plugin::VerifyLicense::VERSION = '0.01_2';
# ABSTRACT: DMOSS fix me description
use parent qw/DMOSS::Plugin/;

use strict;
use warnings;

use Software::License;
use Software::LicenseUtils;
use File::Slurp qw/read_file/;

our @types = qw/README LICENSE/;

sub name { 'Verify License' }

sub process {
  my ($self, $dmoss, $file) = @_;
  my $content = read_file $file->fullpath;
  return unless $content =~ m/\b(licen[cs]e|licensing|copyright|legal)\b/;

  # guess license
  $content = "=head1 license\n" . $content . "\n=cut";
  my @guesses = Software::LicenseUtils->guess_license_from_pod($content);
  my $top = shift @guesses;

  if ($top) {
    my $license = $top->name;
    $dmoss->add_attr('license', $license);
  }
}

sub reduce {
  my ($self, $dmoss, @attrs) = @_;
  return unless @attrs;

  if (@attrs > 1) {  # more than one license was found
    # FIXME
  }
  else {
    $dmoss->add_attr('license', $attrs[0]->value);
  }
}

sub report {
  my ($self, $dmoss, $attr) = @_;

  return [ $attr->file->{path}, $attr->value ];
}

sub report_headers {
  my ($self, $dmoss) = @_;

  return [ 'File', 'License' ];
}

sub grade {
  my ($self, $dmoss, $attr) = @_;
  return 0 unless $attr;

  return ( $attr->value ? 1 : 0 );
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

DMOSS::Plugin::VerifyLicense - DMOSS fix me description

=head1 VERSION

version 0.01_2

=head1 DESCRIPTION

This plugin attempts to find an open source license for the software
package.

=head1 AUTHOR

Nuno Carvalho <smash@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Project Natura <natura@natura.di.uminho.pt>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
