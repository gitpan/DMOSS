package DMOSS::Plugin;
# ABSTRACT: DMOSS base class for plugins
$DMOSS::Plugin::VERSION = '0.01_2';
use strict;
use warnings;

my @types = ();

sub new {
  my ($class) = @_;
  my $self = bless({}, $class);

  return $self;
}

sub name {
  my ($self) = @_;

  return(ref $self);
}

sub process { print "default process" }

sub grade {
    my ($self, $num) = @_;
   
    return 'F' if $num < 0.1;
    return 'D' if $num < 0.4;
    return 'C' if $num < 0.6;
    return 'B' if $num < 0.8;
    return 'A';
}

sub grade_html_box {
    my ($self, $grade, $title, $more) = @_;
    my $tag = lc $title;
    $tag =~ s/\W+/_/g;

    my $html = "<div class='grade_box grade_".lc($grade)."'>\b";
    $html .= "<span class='grade'>$grade</span><span class='title'><a href='javascript: show(\"$tag\");'>$title</a></span>\n";
    $html .= "<div style='display: none;' id='$tag' class='grade_box_more'><span class='more'>$more</span></div>";
    $html .= "</div>\n";

    return $html;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

DMOSS::Plugin - DMOSS base class for plugins

=head1 VERSION

version 0.01_2

=head1 SYNOPSIS

    package DMOSS::Plugin::MyPlugin;
    use parent qw/DMOSS::Plugin/;

=head1 DESCRIPTION

This should be the base class for all L<DMOSS> plugins. The main functions
a plugin needs to overwrite are:

=over

=item C<name>

This function returns the name of the plugin.

=item C<process>

This function is used process each file, and it create attributes to
add to the package tree.

=item C<reduce>

This function is used to reduce resutls from different files to a single
attribute.

=item C<report>

This function returns the report snippet for each attribute. If the return
value is a reference to a list a table is created in the final report.

=item C<report_headers>

This function can be used to return a reference to a list that contains
the column headers for the table of attributes reports.

=item C<grade>

This function grades the software package, it should return a value
between 0 and 1.

=back

=head1 EXAMPLES

For examples view the C<DMOSS::Plugin::*> included in this distribution.

=head1 AUTHOR

Nuno Carvalho <smash@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Project Natura <natura@natura.di.uminho.pt>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
