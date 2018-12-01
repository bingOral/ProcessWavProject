#!/usr/bin/perl

package OuterServer;
use strict;
use JSON;
use LWP::UserAgent;


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
