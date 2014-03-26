package DMOSS::Report;
# ABSTRACT: DMOSS base class for creating reports
$DMOSS::Report::VERSION = '0.01_2';
use strict;
use warnings;

my @types = ();

sub new {
  my ($class, $dmoss) = @_;
  my $self = bless({}, $class);

  $self->dmoss($dmoss) if $dmoss;
  $self->output($self->report) if $dmoss;

  return $self;
}

sub dmoss {
  my ($self, $dmoss) = @_;
  $self->{dmoss} = $dmoss if $dmoss;

  return $self->{dmoss};
}

sub output {
  my ($self, $output) = @_;
  $self->{output} = $output if $output;

  return $self->{output};
}

sub report {
  my ($self) = (@_);
  my $output = '';

  # begin report
  $output .= $self->start_report;

  # include plugins reports
  foreach my $p (sort @{ $self->dmoss->{plugins} }) {
    my $plugin;

    # include title, and grade
    my $grade = $self->grade( $self->dmoss->plugin_grade($p) );
    $plugin .= $self->make_title($p, $grade);

    # include a row for every attribute
    my @reports = $self->dmoss->report_attrs_plugin($self, $p);
#use Data::Dumper; print STDERR Dumper(@reports);
    my @results;
    foreach (@reports) {
      if (ref $_ eq 'ARRAY') {
        push @results, $self->make_row(@$_) if (scalar(@$_) > 0);
      }
      else {
        push @results, $_;
      }
    }
    $plugin .= $self->make_more_info($p, @results);

    $output .= $self->make_plugin_box($plugin, $grade);
  }

  # end report
  $output .= $self->end_report;

  return $output;
}

sub make_title {
  my ($self, $plugin, $grade) = (@_);

  return "$plugin == $grade\n";
}

sub make_plugin_box {
  my ($self, $content) = (@_);

  return(('-'x60)."+\n$content\n");
}

sub make_more_info {
  my ($self, $plugin, @results) = (@_);

  return(join("\n", @results));
}

sub make_row {
  my ($self, @values) = (@_);

  return join("\t\t", @values);
}

sub grade {
  my ($self, $num) = (@_);
   
  return 'F' if $num < 0.1;
  return 'D' if $num < 0.4;
  return 'C' if $num < 0.6;
  return 'B' if $num < 0.8;
  return 'A';
}

sub start_report { "\nDMOSS Report\n" }

sub end_report { "\n" }

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

DMOSS::Report - DMOSS base class for creating reports

=head1 VERSION

version 0.01_2

=head1 SYNOPSIS

    package DMOSS::Report::HTML;
    use parent qw/DMOSS::Report/;

=head1 DESCRIPTION

This is the base class for creating reports.

=head1 AUTHOR

Nuno Carvalho <smash@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Project Natura <natura@natura.di.uminho.pt>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
