package DMOSS::Plugin::AutoClassify;
$DMOSS::Plugin::AutoClassify::VERSION = '0.01_1';
# ABSTRACT: DMOSS classification plugin
use parent qw/DMOSS::Plugin/;
use strict;
use warnings;

use URI::Find;
use File::Slurp qw/read_file/;
use HTTP::Request;
use LWP::UserAgent;
use Data::Dumper;

our @types = qw/_PACKAGE/;

# taxonomy
my $tax = {
  'audio video' => {
	'sound audio' => 1,
	'video' => 1,
  },
  'business enterprise' => {
	'scheduling' => 1,
	'office suites' => 1,
	'e-commerce shopping' => 1,
	'desktop publisinhg' => 1,
	'report generators' => 1,
	'knowledge management' => 1,
	'enterprise' => 1,
	'financial' => 1,
	'todo lists' => 1,
	'modelling' => 1,
	'project management' => 1,
	'time tracking' => 1,
	'insurance' => 1,
  },
  'communications' => {
	'chat' => 1,
	'rss feed readers	' => 1,
	'bbs' => 1,
	'conferencing' => 1,
	'email' => 1,
	'fax' => 1,
	'fido' => 1,
	'ham radio' => 1,
	'usenet news' => 1,
	'internet phone' => 1,
	'synchronization' => 1,
	'streaming' => 1,
	'telephony' => 1,
	'file sharing' => 1,
  },
  'development' => {
	'software development' => 1,
	'database' => 1,
	'text editors' => 1,
	'data formats' => 1,
  },
  'home education' => {
	'religion philosophy' => 1,
	'education' => 1,
	'printing' => 1,
	'social sciences' => 1,
  },
  'games' => {
	'hobbies' => 1,
	'side-scrolling arcade' => 1,
	'flight simulator' => 1,
	'sports' => 1,
	'mmorpg' => 1,
	'puzzle' => 1,
	'real time tactical' => 1,
	'real time strategy' => 1,
	'first person shooter' => 1,
	'turn base strategy' => 1,
	'role-playing' => 1,
	'card games' => 1,
	'multi user dungeon' => 1,
	'console based' => 1,
	'development framework' => 1,
	'multiplayer' => 1,
	'simulation' => 1,
	'board games' => 1,
  },
  'graphics' => {
	'capture' => 1,
	'conversion' => 1,
	'editors' => 1,
	'3d modeling' => 1,
	'3d rendering', => 1,
	'fractals procedural generation' => 1,
	'viewers' => 1,
	'image galleries' => 1,
	'presentation' => 1,
	'handwriting recognition' => 1,
	'animation' => 1,
  },
  'science engineering' => {
	'chemistry' => 1,
	'information analysis' => 1,
	'interface engine' => 1,
	'protocol translator' => 1,
	'physics' => 1,
	'artificial intelligence' => 1,
	'astronomy' => 1,
	'visualization' => 1,
	'mapping' => 1,
	'medical' => 1,
	'mechanical civil engineering' => 1,
	'human machine interfaces' => 1,
	'medical physics' => 1,
	'molecular mechanics' => 1,
	'quantum computing' => 1,
	'earth ' => 1,
	'ecosystem ' => 1,
	'test measurement' => 1,
	'molecular' => 1,
	'building automation' => 1,
	'simulators' => 1,
	'robotics' => 1,
	'scada' => 1,
	'mathematics' => 1,
	'linguistics' => 1,
	'electronic design automation' => 1,
	'bio-informatics' => 1,
  },
  'security utilities' => {
	'archiving' => 1,
	'file management' => 1,
	'power ups' => 1,
	'terminals' => 1,
	'security' => 1,
	'log rotation' => 1,
	'file transfer protocol' => 1,
	'capture' => 1,
	'log analysis' => 1,
  },
  'system administration' => {
	'software distribution' => 1,
	'benchmark' => 1,
	'boot' => 1,
	'clustering' => 1,
	'file system' => 1,
	'emedded sustem' => 1,
	'operation system kernel' => 1,
	'cron scheduling' => 1,
	'instalattion' => 1,
	'logging' => 1,
	'networking' => 1,
	'power ups' => 1,
	'home automation' => 1,
	'os distribution' => 1,
	'system shell' => 1,
	'distributed computing' => 1,
	'emulators' => 1,
	'hardware' => 1,
	'search' => 1,
	'storage' => 1,
  }
};

sub name { 'Auto Classification' }

my $TMPDIR = '/tmp';  # FIXME
sub process {
  my ($self, $dmoss, $file) = @_;

  my $corpus = join('/', $TMPDIR, $dmoss->{meta}->{dist}) . '.txt';
  unless (-e $corpus) {
    `dmoss-corpus $dmoss->{basedir} > $corpus`
  }
  my $c = read_file $corpus;

  # first level
  my $last = 0;
  my $first;
  foreach my $um (keys %$tax) {
    my @words = ();
    if ($um =~ m/\s/) { @words = split /\s+/, $um; }
    else { push @words, $um; }

    foreach (keys %{$tax->{$um}}) {
      push @words, split /\s+/, $_;
    }

    my $curr = findAll(@words);
    if ($curr > $last) {
      $last = $curr;
      $first = $um
    }
  }

  # second level
  my $second;
  $last = 0;
  foreach my $dois (keys %{$tax->{$first}}) {
    my @words = ();
    if ($dois =~ m/\s/) { @words = split /\s+/, $dois; }
    else { push @words, $dois; }

    my $curr = findAll($c, @words);
    if ($curr > $last) {
      $last = $curr;
      $second = $dois;
    }
  }

  $dmoss->add_attr('auto_classify', {fst=>$first, snd=>$second});
}

sub reduce { }

sub report {
  my ($self, $dmoss, $attr) = @_;
  return unless ($attr->value and keys %{$attr->value});

  return [ $attr->value->{fst}, $attr->value->{snd} ];
}

sub report_headers {
  my ($self, $dmoss) = @_;

  return [ 'Class', 'Sub-class' ];
}

sub grade {
  my ($self, $dmoss, $attr) = @_;

  return 1 if ($attr->value->{fst} and $attr->value->{snd});
  return 0.5 if ($attr->value->{fst} or $attr->value->{snd});
  return 0;
}

sub findAll {
  my ($c, @words) = @_;

  my $found = 0;
  foreach (@words) {
  next unless ($_ =~ m/\w/);
    $found++ while ($c =~ m/\b${_}s?\b/ig);
  }

  return $found;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

DMOSS::Plugin::AutoClassify - DMOSS classification plugin

=head1 VERSION

version 0.01_1

=head1 DESCRIPTION

This plugin attempts to aautomaticaly classify a software package based
on a taxonomy.

=head1 AUTHOR

Nuno Carvalho <smash@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Project Natura <natura@natura.di.uminho.pt>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
