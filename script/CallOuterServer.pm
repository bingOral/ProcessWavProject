#!/usr/bin/perl

package OuterServer;
use strict;
use JSON;
use LWP::UserAgent;

sub callNuanceEnglishAsrEngine
{
	my $wavfile = shift;
	my $engine_url = shift;

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
	my $job_id = $jsonparser->decode($res->content())->{reference};

	#get
	my $results_url = $engine_url.'/'.$job_id.'/results';
	my $req = HTTP::Request->new(GET => $results_url);

	my $res = $ua->request($req);
	my $content = $jsonparser->decode($res->decoded_content);
	return $content->{channels}->{channel1}->{transcript}->[0]->{text};
}

sub callBaiduEnglishAsrEngine
{

}

sub calliFlyEnglishAsrEngine
{

}

sub callUnsEnglishAsrEngine
{

}

1;
