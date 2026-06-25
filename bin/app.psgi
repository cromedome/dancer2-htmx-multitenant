#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";


# use this block if you don't need middleware, and only have a single target Dancer app to run here
use Dungeon;

Dungeon->to_app;

=begin comment
# use this block if you want to include middleware such as Plack::Middleware::Deflater

use Dungeon;
use Plack::Builder;

builder {
    enable 'Deflater';
    Dungeon->to_app;
}

=end comment

=cut

=begin comment
# use this block if you want to mount several applications on different path

use Dungeon;
use Dungeon_admin;

use Plack::Builder;

builder {
    mount '/'      => Dungeon->to_app;
    mount '/admin'      => Dungeon_admin->to_app;
}

=end comment

=cut

