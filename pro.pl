#!/usr/bin/perl

use strict;
use JSON;
use Data::Dumper;
use LWP::UserAgent;
use script::CallOuterServer;

my $asr_res = OuterServer::callNuanceEnglishAsrEngine('http://192.168.1.20:9000/data/voa/special/vadnn/chinese-businesses-wholesale-capital-struggle-economy-slows/chinese-businesses-wholesale-capital-struggle-economy-slows-034.wav','http://192.168.1.20:8081/v4/jobs');
print $asr_res."\n";

1;


