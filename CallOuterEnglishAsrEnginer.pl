#!/usr/bin/perl

use strict;
use JSON;
use threads;
use Encode;
use Config::Tiny;
use LWP::UserAgent;
use script::CallOuterServer;

if(scalar(@ARGV) != 2)
{
	print "Usage : perl $0 input.list threadnum\n";
	exit;
}

my $jsonparser = new JSON;
open(IN,$ARGV[0])||die("The file can't find!\n");

&Main();

sub Main
{
	my $threadnum = $ARGV[1];
	my @tasks = <IN>;
	my $group = div(\@tasks,$threadnum);
	my $param = init();

	my @threads;
	foreach my $key (keys %$group)
	{
		my $thread = threads->create(\&dowork,$group->{$key},$param);
		push @threads,$thread;
	}

	foreach(@threads)
	{
		$_->join();
	}
}

sub div
{
	my $ref = shift;
	my $threadnum = shift;

	my $res;
    	for(my $i = 0; $i < scalar(@$ref); $i++)
   	{
   		my $flag = $i%$threadnum;
   		push @{$res->{$flag}},$ref->[$i];
    	}

    	return $res;
}

sub init
{
	my $config = Config::Tiny->new;
	$config = Config::Tiny->read('config/config.ini', 'utf8');

	my $res;
	$res->{nuance_engine_url} = $config->{process_Wav_config}->{nuance_engine_url};
	$res->{fileserver_url} = $config->{process_Wav_config}->{fileserver_url};
	return $res;
}

sub dowork
{
	my $wavs = shift;
	my $param = shift;

	my $engine_url = $param->{nuance_engine_url};
	my $fileserver_url = $param->{fileserver_url};
	
	foreach my $wav (@$wavs)
	{
		chomp($wav);

		my $asr_res = OuterServer::callNuanceEnglishAsrEngine($fileserver_url.$wav,$engine_url);
		print $wav.'|'.$asr_res."\n";
	}
}

1;

