package DMOSS::Plugin::SpellChecker;
$DMOSS::Plugin::SpellChecker::VERSION = '0.01_2';
# ABSTRACT: DMOSS spell checker validator plugin
use parent qw/DMOSS::Plugin/;
use strict;
use warnings;

use Text::Aspell;
use Lingua::Identify qw(:language_identification);
use File::Slurp qw/read_file/;
use Data::Dumper;

our @types = qw/README INSTALL MAN/;

my %langs = (
    en => 'en_US',
    fr => 'fr_FR',
    pt => 'pt_PT',
  );

sub name { 'Spell Checker' }

sub process {
  my ($self, $dmoss, $file) = @_;
  my $content = read_file $file->fullpath;
  my $lang = langof($content);

  my $speller = Text::Aspell->new;
  $speller->set_option('lang',$langs{$lang});
  my ($total, $valid) = (0, 0);
  foreach (split /\s+/, $content) {
    $total++;
    $valid++ if $speller->check($_);
  }

  $dmoss->add_attr('spell_checker', {total=>$total, valid=>$valid});
}

sub reduce {
  my ($self, $dmoss, @attrs) = @_;

  my ($total, $valid) = (0, 0);
  foreach my $a (@attrs) {
    $total += $a->value->{total};
    $valid += $a->value->{valid};
  }

  $dmoss->add_attr('spell_checker', {total=>$total, valid=>$valid} );
}

sub report {
  my ($self, $dmoss, $attr) = @_;
  return unless ($attr->value and keys %{$attr->value});
  return unless $attr->value->{total};
  my ($valid, $total) = ($attr->value->{valid}, $attr->value->{total});

  my $p = $total ? int($valid/$total*100) : 0;
  return [ $attr->file->path, $valid, $total, "$p%" ];
}

sub report_headers {
  my ($self, $dmoss) = @_;

  return [ '', 'Valid Words', 'Total Words', '% Valid' ];
}

sub grade {
  my ($self, $dmoss, $attr) = @_;
  my ($valid, $total) = ($attr->value->{valid}, $attr->value->{total});

  return ($total ? ($valid/$total) : 0);
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

DMOSS::Plugin::SpellChecker - DMOSS spell checker validator plugin

=head1 VERSION

version 0.01_2

=head1 DESCRIPTION

This plugin spell checks documentation files.

=head1 AUTHOR

Nuno Carvalho <smash@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Project Natura <natura@natura.di.uminho.pt>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
