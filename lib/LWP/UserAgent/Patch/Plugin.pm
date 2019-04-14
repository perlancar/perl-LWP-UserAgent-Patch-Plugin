package LWP::UserAgent::Patch::Plugin;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;
use Log::ger;

use LWP::UserAgent::Plugin ();
use Module::Patch qw();
use base qw(Module::Patch);

our %config;

my $plugins_set;
my $p_new = sub {
    my $ctx = shift;
    my $class = shift;

    if ($config{-set_plugins} && !$plugins_set++) {
        LWP::UserAgent::Plugin->set_plugins(@{ $config{-set_plugins} });
    }

    $class = 'LWP::UserAgent::Plugin' if $class eq 'LWP::UserAgent';
    $ctx->{orig}->($class, @_);
};

sub patch_data {
    return {
        v => 3,
        config => {
            -set_plugins => {
                schema  => 'array*',
            },
        },
        patches => [
            {
                action      => 'wrap',
                sub_name    => 'new',
                code        => $p_new,
            },
        ],
    };
}

1;
# ABSTRACT: Change use of LWP::UserAgent to that of LWP::UserAgent::Plugin

=for Pod::Coverage ^(patch_data)$

=head1 SYNOPSIS

First, invoke this patch. From Perl:

 use LWP::UserAgent::Patch::Plugin
     # -set_plugins => ['Cache', CustomRetry=>{strategy=>"Exponential", strategy_options=>{initial_delay=>0.5, max_delay=>300}}],
 ;

or:

 use LWP::UserAgent::Patch::Plugin;
 LWP::UserAgent::Plugin->set_plugins('Cache', ...);

From command-line:

 % LWP_USERAGENT_PLUGINS='["Cache","CustomRetry",{"strategy":"Exponential","strategy_options":{"initial_delay":0.5}}]' \
     perl -MLWP::UserAgent::Patch::Plugin script-that-uses-lwp-useragent.pl ...

Now every usage of L<LWP::UserAgent>, e.g.:

 my $response = LWP::UserAgent->new->get("http://www.example.com/");

will become:

 my $response = LWP::UserAgent::Plugin->new->get("http://www.example.com/");


=head1 DESCRIPTION

This module replaces every instantiation of L<LWP::UserAgent> to instantiate
L<LWP::UserAgent::Plugin> instead, so you can use LWP::UserAgent::Plugin's
plugins. Note that instantiation of other LWP::UserAgent subclasses, e.g.
L<WWW::Mechanize> is not replaced with instantiation of LWP::UserAgent::Plugin.


=head1 CONFIGURATION

=head2 -set_plugins

Array. Will be passed to L<LWP::UserAgent::Plugin>'s C<set_plugins()>. You can
also set plugins by calling C<set_plugins()> yourself.


=head1 FAQ


=head1 SEE ALSO

L<LWP::UserAgent::Plugin>

L<LWP::UserAgent>

L<Module::Patch>

L<WWW::Mechanize::Patch::Plugin>

=cut
