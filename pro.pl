#!/usr/bin/perl

use strict;
use JSON;
use Data::Dumper;
use LWP::UserAgent;

#my $res = OuterServer::callNuanceEnglishAsrEngine('http://li4240789.vicp.io:9000/data/voa/special/vadnn/chinese-businesses-wholesale-capital-struggle-economy-slows/chinese-businesses-wholesale-capital-struggle-economy-slows-034.wav','http://li4240789.vicp.io:8081/v4/jobs');
#print Dumper($res)."\n";
#use LWP::UserAgent;
#use JSON;

#my $url = 'http://li4240789.vicp.io:8081/v4/jobs/c57a96e0-f504-11e8-ae7f-158de6cf37b1/results';
#my $ua = LWP::UserAgent->new;
#my $req = HTTP::Request->new(GET => $url);

# send request
#my $jsonparser = new JSON;
#my $res = $ua->request($req);
#my $ref = $jsonparser->decode($res->decoded_content);
#print $ref->{channels}->{channel1}->{transcript}->[0]->{text}."\n";

my $asr_res = callNuanceEnglishAsrEngine('http://192.168.1.20:9000/data/voa/special/vadnn/chinese-businesses-wholesale-capital-struggle-economy-slows/chinese-businesses-wholesale-capital-struggle-economy-slows-034.wav','http://192.168.1.20:8081/v4/jobs');

print $asr_res."\n";

sub callNuanceEnglishAsrEngine
{
	my $wavfile = shift;
	my $engine_url = shift;

	my $res = callNuanceEnglishAsrEngine_request($wavfile,$engine_url);
	print $res->{result}."\n";
	print $res->{status}."\n";

	my $asr_res = callNuanceEnglishAsrEngine_get($res);
	print $asr_res."\n";
	return $asr_res;
}

sub callNuanceEnglishAsrEngine_request
{
	my $wavfile = shift;
	my $engine_url = shift;

	my $res;
	my $jsonparser = new JSON;

	my $body_data = {"job_type" => "batch_transcription",
					"channels" => {"channel1" => 
									{"format" => "audio/wave","result_format" => "transcript"}
								},
					"model" => {"name" => "eng-usa","sample_rate" => 16000},
					"operating_mode" => "accurate"};
	$body_data->{channels}->{channel1}->{url} = $wavfile;

	#send
	my $ua = LWP::UserAgent->new;
	my $req = HTTP::Request->new('POST' => $engine_url); 
	$req->content_type('application/json-rpc; charset=UTF-8');
	$req->content($jsonparser->encode($body_data));

	my $res = $ua->request($req);
	my $jobs_id = $jsonparser->decode($res->content())->{reference};

	$res->{result} = $engine_url.'/'.$jobs_id.'/results';
	$res->{status} = $engine_url.'/'.$jobs_id.'/status';
	return $res;
}

sub callNuanceEnglishAsrEngine_get
{
	my $ref = shift;
	my $jsonparser = new JSON;

	my $ua = LWP::UserAgent->new;
	my $req = HTTP::Request->new(GET => $ref->{result});

	# send request
	my $res = $ua->request($req);
	my $ref = $jsonparser->decode($res->decoded_content);
	print Dumper($ref)."\n";
}

