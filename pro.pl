#!/usr/bin/perl

use strict;
use Data::Dumper;
use script::CallOuterServer;

#my $res = OuterServer::callNuanceEnglishAsrEngine('http://li4240789.vicp.io:9000/data/voa/special/vadnn/chinese-businesses-wholesale-capital-struggle-economy-slows/chinese-businesses-wholesale-capital-struggle-economy-slows-034.wav','http://li4240789.vicp.io:8081/v4/jobs');

#print Dumper($res)."\n";


use LWP::UserAgent;
use JSON;

my $url = 'http://li4240789.vicp.io:8081/v4/jobs/c57a96e0-f504-11e8-ae7f-158de6cf37b1/results';
my $ua = LWP::UserAgent->new;
my $req = HTTP::Request->new(GET => $url);

# send request
my $jsonparser = new JSON;
my $res = $ua->request($req);
my $ref = $jsonparser->decode($res->decoded_content);
print $ref->{channels}->{channel1}->{transcript}->[0]->{text}."\n";
