package DMOSS::Oracle;
# ABSTRACT: DMOSS file type oracle
$DMOSS::Oracle::VERSION = '0.01_2';
use strict;
use warnings;

use MIME::Types;

sub new {
  my ($class) = @_;
  my $self = bless({}, $class);

  return $self;
}

sub type {
  my ($self, $file) = @_;
  my $type = '';

  # first, filter by extension
  $type = $self->type_by_extension($file);
  return $type if $type;
  
  # second, some hand made RE
  return 'README'   if ($file->basename =~ m/^read.*?me$/i);
  return 'LICENSE'  if ($file->basename =~ m/^licen.e$/i);
  return 'INSTALL'  if ($file->basename =~ m/^install$/i);
  return 'MAN'      if ($file->path =~ m/\/man\//i);
  return 'MAKEFILE' if ($file->basename =~ m/^makefile$/i);
  return 'TEXT'     if ($file->basename =~ m/\.txt$/i);
  return 'CHANGES'  if ($file->basename =~ m/^changes*(log)*$/i);

  # third, try to return mime type
  my $types = MIME::Types->new;
  my $mime = $types->mimeTypeOf($file->fullpath);
  return $mime if $mime;

  # no type found
  return undef;
}

my $extensions = {
    'ANT'      => [qw/build.xml/],
    'ASM'      => [qw/asm ASM s S A51 29[kK] [68][68][kKsSxX] [xX][68][68]/],
    'ASP'      => [qw/asp asa/],
    'AWK'      => [qw/awk gawk mawk/],
    'BASIC'    => [qw/bas bi bb pb/],
    'BETA'     => [qw/bet/],
    'C'        => [qw/c/],
    'C++'      => [qw/c++ cc cp cpp cxx h h++ hh hp hpp hxx C H/],
    'C#'       => [qw/cs/],
    'COBOL'    => [qw/cbl cob CBL COB/],
    'DOSBATCH' => [qw/bat cmd/],
    'EIFFEL'   => [qw/e/],
    'ERLANG'   => [qw/erl ERL hrl HRL/],
    'FLEX'     => [qw/as mxml/],
    'FORTRAN'  => [qw/f for ftn f77 f90 f95 F FOR FTN F77 F90 F95/],
    'GO'       => [qw/go/],
    'HTML'     => [qw/htm html/],
    'JAVA'     => [qw/java/],
    'JAVASCRIPT' => [qw/js/],
    'LISP'     => [qw/cl clisp el l lisp lsp/],
    'LUA'      => [qw/lua/],
    'MAKE'     => [qw/mak mk [Mm]akefile GNUmakefile/],
    'MATLAB'   => [qw/m/],
    'OBJECTIVEC' => [qw/m h/],
    'OCAML'    => [qw/ml mli/],
    'PASCAL'   => [qw/p pas/],
    'PERL'     => [qw/pl pm plx perl/],
    'PHP'      => [qw/php php3 phtml/],
    'PYTHON'   => [qw/py pyx pxd pxi scons/],
    'REXX'     => [qw/cmd rexx rx/],
    'RUBY'     => [qw/rb ruby/],
    'SCHEME'   => [qw/SCM SM sch scheme scm sm/],
    'SH'       => [qw/sh SH bsh bash ksh zsh/],
    'SLANG'    => [qw/sl/],
    'SML'      => [qw/sml sig/],
    'SQL'     => [qw/sql/],
    'TCL'      => [qw/tcl tk wish itcl/],
    'TEX'      => [qw/tex/],
    'VERA'     => [qw/vr vri vrh/],
    'VERILOG'  => [qw/v/],
    'VHDL'     => [qw/vhdl vhd/],
    'VIM'      => [qw/vim/],
    'YACC'     => [qw/y/],
  };

sub type_by_extension {
  my ($self, $file) = @_;

  foreach (keys %$extensions) {
    foreach my $re (@{ $extensions->{$_} }) {
      return $_ if ($file->basename =~ m/\.$re$/);
    }
  }

  return undef;
}

sub group {
  my ($self, $group) = @_;
  return () unless ($group =~ m/^_/);

  if ($group eq '_DOC') {
    return qw/README INSTALL MAN TEXT/;
  }
  if ($group eq '_OTHER') {
    return qw/LICENSE MAKEFILE CHANGES/;
  }
  if ($group eq '_SOURCE') {
    return (keys %$extensions);
  }
  if ($group eq '_ALL') {
    return ( $self->group('_DOC'), $self->group('_OTHER'), $self->group('_SOURCE') );
  }
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

DMOSS::Oracle - DMOSS file type oracle

=head1 VERSION

version 0.01_2

=head1 SYNOPSIS

    use DMOSS::Oracle;

    my $oracle = DMOSS::Oracle->new;
    my $type = $oracle->type($file);

=head1 DESCRIPTION

The DMOSS oracle gives a type to a file, initially based on file axtension,
and next based on hand crafted regular expressions.

=head1 FUNCTIONS

=head2 new

Create a new oracle object.

=head2 type

Given a file path this function returns its' type.

=head1 AUTHOR

Nuno Carvalho <smash@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Project Natura <natura@natura.di.uminho.pt>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
