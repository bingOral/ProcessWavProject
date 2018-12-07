#!/usr/bin/perl

package OuterServer;
use strict;
use JSON;
use LWP::UserAgent;

sub callNuanceEnglishAsrEngine
{
	my $index = shift;
	my $es = shift;
	my $prefix = shift;
	my $wavname = shift;
	my $engine_url = shift;
	my $nunace_callback_url = shift;

	my $jsonparser = new JSON;
	my $body_data = {"job_type" => "batch_transcription",
			 "channels" => {"channel1" => {"format" => "audio/wave","result_format" => "transcript"}},
			    "model" => {    "name" => "eng-usa","sample_rate" => 16000},
		     "callback_url" => $nunace_callback_url,
		   "operating_mode" => "accurate"};
	$body_data->{channels}->{channel1}->{url} = $prefix.$wavname;

	#send
	my $ua = LWP::UserAgent->new;
	my $req = HTTP::Request->new('POST' => $engine_url); 
	$req->content_type('application/json-rpc; charset=UTF-8');
	$req->content($jsonparser->encode($body_data));

	my $res = $ua->request($req);
	my $jobs_id;
	if($res->is_success)
	{
		$jobs_id = $jsonparser->decode($res->content())->{reference};
		$es->index(index => $index,
		 	    type => 'data',
		 	    id   => $wavname,
		 	    body => {wavname => $wavname,
			   	   reference => $jobs_id,
			                text => "",
			              server => $engine_url,
			              length => 0
			}
		);

		return $jobs_id;

	}
	else
	{
		print "HTTP POST error code: ", $res->code, "\n";
		print "HTTP POST error message: ", $res->message, "\n";
		callNuanceEnglishAsrEngine($index,$es,$prefix,$wavname,$engine_url,$nunace_callback_url);
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
