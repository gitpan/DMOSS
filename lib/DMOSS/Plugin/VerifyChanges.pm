package DMOSS::Plugin::VerifyChanges;
$DMOSS::Plugin::VerifyChanges::VERSION = '0.01_1';
# ABSTRACT: DMOSS changes plugin
use parent qw/DMOSS::Plugin/;
use strict;
use warnings;

use File::Slurp qw/read_file/;
use Data::Dumper;

our @types = qw/CHANGES/;

sub name { 'Verify Changes' }

sub process {
  my ($self, $dmoss, $file) = @_;

  open(my $fh, '<', $file->fullpath);
  $/ = '';
  my $years;
  while (<$fh>) {
    my ($year, $ver);
    $year = $1 if $_ =~ m/(\d{4})/;
    $ver = $1 if $_ =~ m/(\d+\.\d+)/;
    push @{$years->{$year}}, $ver if $year;
  }

  my @years = sort {$b<=>$a} keys %$years;
  my $last = shift @years;

  $dmoss->add_attr('changes', {years=>$years, last=>$last} );
}

sub reduce {
  my ($self, $dmoss, $attr) = @_;

  $dmoss->add_attr('links', $attr->value);
}

sub report {
  my ($self, $dmoss, $attr) = @_;
  return unless ($attr->value and keys %{$attr->value});

  my $final;
  foreach (sort {$b<=>$a} keys %{ $attr->value->{years} }) {
    next unless $attr->value->{years}->{$_};
    push @$final, [ $_, join(', ', @{$attr->value->{years}->{$_}}) ];
  }

  return $final;
}

sub report_headers {
  my ($self, $dmoss) = @_;

  return ['Year', 'Versions'];
}

sub grade {
  my ($self, $dmoss, $attr) = @_;
  return 0 unless $attr;

  my $last = $attr->value->{last};
  return 0 unless $last;
  my @local = localtime;
  my $current = $local[5]+1900;
  return 0 unless $current;

  return 1 if ($last == $current);
  return 0.9 if ($last+1 == $current);
  return 0.5 if ($last < $current);
  return 0;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

DMOSS::Plugin::VerifyChanges - DMOSS changes plugin

=head1 VERSION

version 0.01_1

=head1 DESCRIPTION

This plugin attempts to verify how long was the software last release.

=head1 AUTHOR

Nuno Carvalho <smash@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Project Natura <natura@natura.di.uminho.pt>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
