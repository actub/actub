#!/usr/bin/env perl
use strict;
use warnings;

use lib 'lib';
use Mojolicious::Commands;

require Mojolicious::Commands;
Mojolicious::Commands->start_app('Actub');
