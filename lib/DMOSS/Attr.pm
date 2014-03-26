package DMOSS::Attr;
# ABSTRACT: DMOSS attribute object
$DMOSS::Attr::VERSION = '0.01_2';
use strict;
use warnings;

sub new {
  my ($class, $file, $plugin, $name, $value) = @_;
  my $self = bless({}, $class);
	
  $self->file($file) if $file;
  $self->plugin($plugin) if $plugin;
  $self->name($name) if $name;
  $self->value($value) if $value;
  $self->value({}) unless $self->value;
  $self->type(ref($value)) if $value;

  return $self;
}

sub file {
  my ($self, $file) = @_;
  $self->{file} = $file if $file;

  return $self->{file};
}

sub plugin {
  my ($self, $plugin) = @_;
  $self->{plugin} = $plugin if $plugin;

  return $self->{plugin};
}

sub name {
  my ($self, $name) = @_;
  $self->{name} = $name if $name;

  return $self->{name};
}

sub value {
  my ($self, $value) = @_;
  $self->{value} = $value if $value;

  return $self->{value};
}

sub type {
  my ($self, $type) = @_;
  $self->{type} = $type if $type;

  return $self->{type};
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

DMOSS::Attr - DMOSS attribute object

=head1 VERSION

version 0.01_2

=head1 SYNOPSIS

    use DMOSS::Attr;
     
    my $attr = DMOSS::Attr->new($file, $plugin, $name, $value);

=head1 DESCRIPTION

DMOSS attribute object.

=head1 FUNCTIONS

=head2 new

Create a new object to represent an attribute.

=head2 file

The DMOSS::File object to add the attribute.

=head2 plugin

The plugin module that added the attribute.

=head2 name

The name of the attribute.

=head2 value

The value of the attribute.

=head2 type

The type of reference of the value.

=head1 AUTHOR

Nuno Carvalho <smash@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Project Natura <natura@natura.di.uminho.pt>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
