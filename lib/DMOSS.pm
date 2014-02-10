package DMOSS;
# ABSTRACT: Data Mining Open Source Software
$DMOSS::VERSION = '0.01_1';
use strict;
use warnings;

use DMOSS::Oracle;
use DMOSS::File;
use DMOSS::Attr;
use File::Basename;
use Storable qw/store retrieve dclone store_fd fd_retrieve/;
use Module::Find;
use Data::Dumper;

sub new {
  my ($class,$basedir,@files) = @_;
  my $self = bless({}, $class);
  $self->{basedir} = $basedir;
  $self->{typeof} = {};
  $self->{res} = {};
  $self->{meta} = {};

  my $dist = basename $basedir if $basedir;

  $self->{meta}->{dist} = $dist;
  if ($dist and $dist =~ m/([\d\-\.]+)$/) {
      my $version = $1;
      $version =~ s/^[\-\.]+//;
      if ($version) {
          $self->{meta}->{version} = $version;
      }
  }

  # start with an empty tree
  $self->{tree} = {};

  # init files, and populate tree
  $self->__init_files($basedir, @files);

  # find available plugins
  my @available = findallmod DMOSS::Plugin;
  my @plugins;
  foreach (@available) {
    eval "require $_;";
    my $skip = eval '$'.$_ .'::SKIP or 0';
    push @plugins, $_ unless $skip;
  }
  $self->{plugins} = [@plugins];

  return $self;
}

sub __init_files {
  my ($self, $basedir, @files) = @_;
  my $ora = DMOSS::Oracle->new();

  foreach (@files) {
    my $file = DMOSS::File->new($basedir, $_);
    $self->{files}->{$file->path} = $file;

    my $type = $ora->type($file);
    if ($type) {
      $file->type($type);
      $self->{files}->{$file->path}->{type} = $type;
      $self->{typeof}->{$file->path} = $type;
    }

    $self->__add_tree($file->path, $_);
  }
}

sub __add_tree {
  my ($self, $path, $id) = @_;

  my @l = split /[\\\/]+/, $path;  # FIXME generalize file separator

  my $root = $self->{tree};
  my $next = shift @l;
  while (@l) {
    $root->{$next} = {} unless exists($root->{$next});
    $root = $root->{$next};
    $next = shift @l;
  }
  $root->{$path} = $id;
}

my $curr_file;  # FIXME remove global variables

sub process {
  my ($self) = @_;
  my @plugins = @{$self->{plugins}};
  my $ora = DMOSS::Oracle->new;

  # load plugins and populate dispatch table per type
  my $dispatch;
  my @package_plugins;
  foreach (@plugins) {
    no strict 'refs';
    eval "require $_";
    my @types = @{ $_ . '::types' };
    foreach my $t (@types) {
      if ($t =~ m/_PACKAGE/) {
        push @package_plugins, $_;
      }
      if ($t =~ m/^_/) {
        foreach my $tt ($ora->group($t)) {
          push @{$dispatch->{$tt}}, $_;
        }
      }
      else { push @{$dispatch->{$t}}, $_; }
    }
  }

  # run plugins procesors for each file
  foreach (keys %{$self->{files}}) {
    my $file = $self->{files}->{$_};
    next unless ($file->type and exists($dispatch->{$file->type}));
    $curr_file = $file;

    my @watchers = @{$dispatch->{$file->type}};
    foreach (@watchers) {
      my $obj = $_->new;
      $obj->process($self, $file);
    }
  }
  # run package processors
  foreach (@package_plugins) {
    $curr_file = DMOSS::File->new($self->{basedir}, '');
    my $obj = $_->new;
    $obj->process($self, $curr_file);
  }

  # run post processing (reduce) functions
  $self->tree_process($self->{tree}, '');
  $self->__handle_level($self->{tree}, '');
}

sub tree_process {
  my ($self, $root, $path) = @_;

  foreach my $k (keys %$root) {
    if (ref($root->{$k}) eq 'HASH') {
      my $curr = $path ? "$path/$k" : $k;
      $self->tree_process($root->{$k}, $curr);
      $self->__handle_level($root->{$k}, $curr);
    }
  }
}

sub __handle_level {
  my ($self, $root, $path) = @_;
  $curr_file = DMOSS::File->new($self->{basedir}, $path);

  foreach my $p ( @{ $self->{plugins} } ) {
    my @attrs;
    foreach my $k (keys %$root) {
      next unless $self->{attrs}->{$k}->{$p};
      push @attrs, @{ $self->{attrs}->{$k}->{$p} };
    }
    $p->reduce($self, @attrs) if (@attrs);
  }
}

sub add_attr {
  my ($self, $name, $value) = @_;
  my ($plugin) = caller;

  my $attr = DMOSS::Attr->new($curr_file, $plugin, $name, $value);
  push @{ $self->{attrs}->{$attr->file->path or ''}->{$plugin} }, $attr;
}

sub report_attrs_plugin {
  my ($self, $report, $plugin) = @_;
  my @reports;
  eval "require $plugin;";

  foreach my $k (keys %{ $self->{attrs} }) {
    foreach (@{ $self->{attrs}->{$k}->{$plugin} }) {
      my $r = $plugin->report($self, $_);
      if (ref($r->[0]) eq 'ARRAY') { push @reports, @$r; }
      else { push @reports, $r; }
    }
  }

  return @reports;
}

sub plugin_grade {
  my ($self, $plugin) = @_;

  eval "require $plugin;";
  return $plugin->grade($self, $self->{attrs}->{''}->{$plugin}->[0]);
}

sub dt {
    my ($self, $f) = @_;

    $self->__dt($self->{tree}, '', $f);
}

sub __dt {
    my ($self, $root, $path, $f) = @_;
   no strict 'refs';

   foreach my $k (keys %$root) {
      if (ref($root->{$k}) eq 'HASH') {
         my $curr = $path ? "$path/$k" : $k;
         $self->__dt($root->{$k}, $curr, $f);
      }
   }

   my $tmp = dclone($self->{res});
   foreach my $k (keys %$root) {
        &$f(dclone($self), $k);
   }

}

sub save {
  my ($self, $file) = @_;
  $file = 'dmoss.data' unless $file;

  store $self, $file;

  return $file;
}

sub to_stdout {
  my ($self) = @_;

  store_fd($self, *STDOUT);
}

sub load {
  my ($file) = @_;
  $file = 'dmoss.data' unless $file;

  my $ref = retrieve($file);
  my $self = bless($ref, 'DMOSS');

  return $self;
}

sub from_stdout {
  my $ref = fd_retrieve(*STDIN);
  my $self = bless($ref, 'DMOSS');

  return $self;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

DMOSS - Data Mining Open Source Software

=head1 VERSION

version 0.01_1

=head1 SYNOPSIS

    $ dmoss-process -f package-1.0.tgz
    Data saved as dmoss.data
     
    $ dmoss-report > package-1.0.html

=head1 DESCRIPTION

The DMOSS toolkit provides a framework for software packages (mainly
non-source content) analysis. A set of plugins is distributed with
the framework that provide a small set of analysis. For more information
on available plugins and how to implement new plugins view the current
plugins.

For performing software packages analysis please refer to L<dmoss-process>
and L<dmoss-report> tools, and corresponding documentation.

More information about this framework can be found in this
L<page|http://eremita.di.uminho.pt/~nrc/dmoss/>, an example of a HTML
report is available
L<here|http://eremita.di.uminho.pt/~nrc/dmoss/tree-1.5.3.html>.

=head1 FUNCTIONS

=head2 new

Create a new DMOSS object.

=head2 process

Process the package, compute attributes for files.

=head2 tree_process

Process package tree, reduce attributes for each level.

=head2 add_attr

Add an attribute to the the tree, this function is used by plugins
to add data to a node in the tree (which represents a file).

=head2 report_attrs_plugin

This function is used in the reports modules to get a list of reports
(one for each attribute) for a given plugin.

=head2 dt

Down translate, still under development (don't use).

=head2 save

Save dmoss object to a file (default is C<dmoss.data>) as a C<Storable>
object.

=head2 to_stdout

Instead of saving object state to file, prints it to C<STDOUT>.

=head2 load

Load a dmoss object from a file (default is C<dmoss.data>), expects a
C<Storable> object.

=head2 from_stdout

Instead of loading object from file, load from C<STDIN>.

=head1 PLUGINS

Current available plugins in this distribution are:

=over

=item L<DMOSS/Plugin/AutoClassify.pm>

=item L<DMOSS/Plugin/CommentLines.pm>

=item L<DMOSS/Plugin/FunctionIdsDoc.pm>

=item L<DMOSS/Plugin/LinkValidator.pm>

=item L<DMOSS/Plugin/SpellChecker.pm>

=item L<DMOSS/Plugin/VerifyChanges.pm>

=item L<DMOSS/Plugin/VerifyLicense.pm>

=back

=head1 AUTHOR

Nuno Carvalho <smash@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Project Natura <natura@natura.di.uminho.pt>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
