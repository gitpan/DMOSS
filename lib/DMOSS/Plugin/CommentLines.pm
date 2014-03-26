package DMOSS::Plugin::CommentLines;
$DMOSS::Plugin::CommentLines::VERSION = '0.01_2';
# ABSTRACT: DMOSS number of comment lines plugin
use parent qw/DMOSS::Plugin/;
use strict;
use warnings;

use File::Comments;
use File::Slurp qw/read_file/;

our @types = qw/_SOURCE/;

sub name { 'Comment Lines' }

sub process {
  my ($self, $dmoss, $file) = @_;
  my $content = read_file $file->fullpath;

  my $snoop = File::Comments->new;
  my $c = $snoop->comments($file->{fullpath});

  my $res = `wc -l $file->{fullpath}`;
  my $total = 0;
  $total = $1 if ($res =~ m/(\d+)/);
  my $comments = 0;
  $comments = @$c if $c;

  $dmoss->add_attr('comment_lines', {total=>$total, comments=>$comments});
}

sub reduce {
  my ($self, $dmoss, @attrs) = @_;

  my ($total, $comments) = (0, 0);
  foreach my $a (@attrs) {
    $total += $a->value->{total};
    $comments += $a->value->{comments};
  }

  $dmoss->add_attr('comment_lines', {total=>$total, comments=>$comments});
}

sub report {
  my ($self, $dmoss, $attr) = @_;
  return unless ($attr->value and keys %{$attr->value});
  return unless $attr->value->{total};
  my ($comments, $total) = ($attr->value->{comments}, $attr->value->{total});

  my $p = $total ? int($comments/$total*100) : 0;
  return [ $attr->file->path, $comments, $total, "$p%" ];
}

sub report_headers {
  my ($self, $dmoss) = @_;

  return [ '', 'Comment Lines', 'Total Lines', '% Comment Lines' ];
}

sub grade {
  my ($self, $dmoss, $attr) = @_;
  my ($comments, $total) = ($attr->value->{comments}, $attr->value->{total});

  return ($total ? ($comments/$total) : 0);
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

DMOSS::Plugin::CommentLines - DMOSS number of comment lines plugin

=head1 VERSION

version 0.01_2

=head1 DESCRIPTION

This plugin measures the number of comment lines per lines of code.

=head1 AUTHOR

Nuno Carvalho <smash@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Project Natura <natura@natura.di.uminho.pt>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
