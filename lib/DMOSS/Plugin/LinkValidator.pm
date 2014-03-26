package DMOSS::Plugin::LinkValidator;
$DMOSS::Plugin::LinkValidator::VERSION = '0.01_2';
# ABSTRACT: DMOSS link validator plugin
use parent qw/DMOSS::Plugin/;
use strict;
use warnings;

use URI::Find;
use File::Slurp qw/read_file/;
use HTTP::Request;
use LWP::UserAgent;
use Data::Dumper;

#our $SKIP = 1;
our @types = qw/README INSTALL/;

sub name { 'Link Validator' }

sub process {
  my ($self, $dmoss, $file) = @_;
  my $content = read_file $file->fullpath;

  my $res;
  my $finder = URI::Find->new(
      sub {
        my ($uri, $orig_uri) = @_;
        return if ($orig_uri =~ m/(localhost|hostname|localdomain)/i);
        $res->{$orig_uri} = __test_link($orig_uri);
      }
    );
  $finder->find(\$content);

  $dmoss->add_attr('links', $res);
}

sub reduce {
  my ($self, $dmoss, @attrs) = @_;

  my $res;
  foreach (@attrs) {
    foreach my $i (keys %{ $_->value }) {
      $res->{$i} = $_->value->{$i};
    }
  }

  $dmoss->add_attr('links', $res);
}

sub report {
  my ($self, $dmoss, $attr) = @_;
  return unless ($attr->value and keys %{$attr->value});

  my $final = [];
  foreach (keys %{$attr->value}) {
    push @$final, [ $_, ($attr->value->{$_} ? 'ok' : 'nok') ];
  }

  return $final;
  
}

sub report_headers {
  my ($self, $dmoss) = @_;

  return ['URL', 'Status'];
}

sub grade {
  my ($self, $dmoss, $attr) = @_;

  my ($total, $valid) = (0, 0);
  foreach (keys %{ $attr->value }) {
    $total++;
    $valid++ if $attr->value->{$_}
  }

  return ($total ? ($valid/$total) : 0);
}

# auxiliary function
sub __test_link {
   my $url = shift;

   my $request = HTTP::Request->new(GET => $url);
   my $ua = LWP::UserAgent->new;
   my $response = $ua->request($request);

   if ($response->is_success) { return 1; }
   else { return -1; }
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

DMOSS::Plugin::LinkValidator - DMOSS link validator plugin

=head1 VERSION

version 0.01_2

=head1 DESCRIPTION

This plugin validates links found in the documentation.

=head1 AUTHOR

Nuno Carvalho <smash@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Project Natura <natura@natura.di.uminho.pt>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
