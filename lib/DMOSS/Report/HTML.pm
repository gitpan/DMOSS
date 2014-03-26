package DMOSS::Report::HTML;
$DMOSS::Report::HTML::VERSION = '0.01_2';
# ABSTRACT: DMOSS HTML report generator
use parent qw/DMOSS::Report/;
use strict;
use warnings;

sub make_title {
  my ($self, $plugin, $grade) = (@_);
  my $name = $plugin->name;
  my $tag = lc $name;
  $tag =~ s/\W+/_/g;
  my $icon = $self->icon($grade);

  my $html =<<"HTML";
      <div onclick="javascript: show('#$tag');" style="cursor: pointer;" class="panel-heading">
        <div class="panel-title" style="font-size: 22px;">
          <i alt="Grade $grade" title="Grade $grade" class="wi-$icon"></i>
          <span style="padding-left: 15px;">$name</span>
          <span id="${tag}_icon" class="glyphicon glyphicon-chevron-down pull-right" style="padding-top: 5px;"></span>
        </div>
      </div>
HTML

  return $html;
}

sub make_plugin_box {
  my ($self, $content, $grade) = @_;
  my $class = $self->css_class($grade);

  my $html=<<"HTML";
    <div class="panel panel-$class">
      $content
    </div>
HTML

  return $html;
}

sub make_more_info {
  my ($self, $plugin, @results) = @_;
  my $all = join("\n", @results);
  my $name = $plugin->name;
  my $tag = lc $name;
  $tag =~ s/\W+/_/g;

  my @headers = @{ $plugin->report_headers or [] };
  my $hdr = '';  # FIXME better default
  if (@headers) {
    $hdr = '<tr><th>'.join('</th><th>',@headers).'</th></tr>';
  }

  my $html=<<"HTML";
   <div id="$tag" class="panel-body hidden">
     <table class="table table-condensed table-hover">
       $hdr
       $all
     </table>
   </div>
HTML

  return $html;
}

sub make_row {
  my ($self, @values) = @_;
  $values[0] = $self->dmoss->{meta}->{dist} unless $values[0];

  return("<tr><td>".join('</td><td>', @values)."</td></tr>");
}

sub start_report {
  my ($self) = @_;
  my $dist = $self->dmoss->{meta}->{dist};

  my $html =<<"HTML";
<!DOCTYPE HTML>
<html>
  <head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.1.0/css/bootstrap.min.css">
	<link rel="stylesheet" href="http://eremita.di.uminho.pt/~nrc/weather/weather-icons.css">
	<script src="http://code.jquery.com/jquery-1.10.2.min.js"></script>
    <script src="http://netdna.bootstrapcdn.com/bootstrap/3.1.0/js/bootstrap.min.js"></script>
    <title>DMOSS Report - $dist</title>
	<style>#wrapper { margin: auto; width: 70%; }</style>
  </head>
  <body>
    <div id="wrapper"> 
      <div class="page-header">
        <h1>DMOSS Report <small>$dist</small></h1>
	  </div>
HTML
  return $html;
}

sub end_report {
  my $html =<<'HTML';
	</div>
	<script type="text/javascript">
      function show(id) {
        if ( $(id).hasClass('hidden') ) {
	      $(id).removeClass('hidden');
          $(id+'_icon').removeClass('glyphicon-chevron-down');
          $(id+'_icon').addClass('glyphicon-chevron-up');
        }
        else {
          $(id).addClass('hidden');
          $(id+'_icon').removeClass('glyphicon-chevron-up');
          $(id+'_icon').addClass('glyphicon-chevron-down');
        }
      }
    </script>
  </body>
</html>
HTML
  return $html;
}

sub css_class {
  my ($self, $grade) = @_;

  return 'success' if ($grade eq 'A' or $grade eq 'B');
  #return 'info' if ($grade eq 'B');
  return 'warning' if ($grade eq 'C' or $grade eq 'D' or $grade eq 'E');
  return 'danger';
}

sub icon {
  my ($self, $grade) = @_;

  return 'day-sunny' if ($grade eq 'A');
  return 'day-cloudy' if ($grade eq 'B');
  return 'cloudy' if ($grade eq 'C');
  return 'cloudy' if ($grade eq 'D');
  return 'cloudy' if ($grade eq 'E');
  return 'rain' if ($grade eq 'F');

  return 'unk';
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

DMOSS::Report::HTML - DMOSS HTML report generator

=head1 VERSION

version 0.01_2

=head1 SYNOPSIS

    use DMOSS::Report::HTML;

    my $report = DMOSS::Report::HTML->new($dmoss);
    print $report->output;

=head1 DESCRIPTION

This classes extens the base report, and creates an HTML report.

=head1 AUTHOR

Nuno Carvalho <smash@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Project Natura <natura@natura.di.uminho.pt>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
