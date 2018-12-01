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
	my $json_data = {"job_type" => "batch_transcription",
					"channels" => {"channel1" => 
									{"format" => "audio/wave","result_format" => "transcript"}
								},
					"model" => {"name" => "eng-usa","sample_rate" => 16000},
					"operating_mode" => "accurate"};
	$json_data->{channels}->{channel1}->{url} = $wavfile;
	my $json = $jsonparser->encode($json_data);
	print $json."\n";

	#send
	my $ua = LWP::UserAgent->new;
	my $req = HTTP::Request->new('POST' => $engine_url); 
	$req->content_type('application/json-rpc; charset=UTF-8');
	$req->content($json);
	my $res = $ua->request($req);
	my $reference = $jsonparser->decode($res->content())->{reference};

	#get result 
	my $geturl = $engine_url.'/'.$reference."/results";
	my $response = $ua->get($geturl);
	my $asr_res = $jsonparser->decode($response->content);
	while (1) 
	{
		if($asr_res->{channels}->{channel1}->{transcript}->[0]->{text})
		{
			return $asr_res->{channels}->{channel1}->{transcript}->[0]->{text};
			last;
		}
	}
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
