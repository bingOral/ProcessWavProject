#!/usr/bin/perl

use strict;
use Data::Dumper;
use script::CallOuterServer;

my $res = OuterServer::callNuanceEnglishAsrEngine('http://li4240789.vicp.io:9000/data/voa/special/vadnn/chinese-businesses-wholesale-capital-struggle-economy-slows/chinese-businesses-wholesale-capital-struggle-economy-slows-034.wav','http://li4240789.vicp.io:8081/v4/jobs');

print Dumper($res)."\n";