package DMOSS::File;
# ABSTRACT: DMOSS file object
$DMOSS::File::VERSION = '0.01_1';
use strict;
use warnings;

use File::Basename ();
use File::Slurp qw/slurp/;

sub new {
  my ($class, $basedir, $fullpath) = @_;
  my $self = bless({}, $class);

  $self->fullpath($fullpath);
  $self->basename(File::Basename::basename($fullpath)) if $fullpath;
  $self->dirname(File::Basename::dirname($fullpath)) if $fullpath;
  my $path = $fullpath;
  $path =~ s/$basedir//g if $path;
  $path =~ s/^\/+//g if $path;
  $self->{path} = $path;

  #$self->content(slurp $fullpath) if -e $fullpath;

  return $self;
}

sub basename {
  my ($self, $basename) = @_;
  $self->{basename} = $basename if $basename;

  return $self->{basename};
}

sub fullpath {
  my ($self, $fullpath) = @_;
  $self->{fullpath} = $fullpath if $fullpath;

  return $self->{fullpath};
}

sub dirname {
  my ($self, $dirname) = @_;
  $self->{dirname} = $dirname if $dirname;

  return $self->{dirname};
}

sub path {
  my ($self, $path) = @_;
  $self->{path} = $path if $path;

  return $self->{path};
}

sub type {
  my ($self, $type) = @_;
  $self->{type} = $type if $type;

  return $self->{type};
}

sub content {
  my ($self, $content) = @_;
  $self->{content} = $content if $content;

  return $self->{content};
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

DMOSS::File - DMOSS file object

=head1 VERSION

version 0.01_1

=head1 SYNOPSIS

    use DMOSS::File;
    
    my $file = DMOSS::File->new($fullpath);

=head1 DESCRIPTION

DMOSS file object.

=head1 FUNCTIONS

=head2 new

Create a new object to represent a file.

=head2 basename

The file base name.

=head2 fullpath

The file full path.

=head2 dirname

The file directony path.

=head2 path

The file path.

=head2 type

The file type.

=head2 content

The file content.

=head1 AUTHOR

Nuno Carvalho <smash@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Project Natura <natura@natura.di.uminho.pt>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
