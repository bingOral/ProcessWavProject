#!/usr/bin/perl

use strict;
use JSON;
use threads;
use Encode;
use Try::Tiny;
use Config::Tiny;
use Data::Dumper;
use LWP::UserAgent;
use Search::Elasticsearch;
use script::CallOuterServer;

if(scalar(@ARGV) != 1)
{
	print "Usage : perl $0 input.list\n";
	exit;
}

my $jsonparser = new JSON;
open(IN,$ARGV[0])||die("The file can't find!\n");

&Main();

sub Main
{
	my $param = init();
	my $threadnum = $param->{nuance_engine_thread};
	my @tasks = <IN>;
	my $group = div(\@tasks,$threadnum);
	my $es = Search::Elasticsearch->new(nodes=>['192.168.1.20:9200'], cxn_pool => 'Sniff');

	my @threads;
	foreach my $key (keys %$group)
	{
		my $thread = threads->create(\&dowork,$group->{$key},$key,$param,$es);
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
	$res->{nuance_engine_start_port} = $config->{process_Wav_config}->{nuance_engine_start_port};
	$res->{nuance_engine_thread} = $config->{process_Wav_config}->{nuance_engine_thread};
	return $res;
}

sub dowork
{
	my $wavs = shift;
	my $key =  shift;
	my $param = shift;
	my $es = shift;
	
	my $index = 'callserv_call_nuance_en';
	my $fileserver_url = $param->{fileserver_url};
	my $http_start_port = $param->{nuance_engine_start_port} + $key;
	my $engine_url = ($param->{nuance_engine_url}).':'.$http_start_port.'/v4/jobs';
	
	foreach my $wavname (@$wavs)
	{
		chomp($wavname);
		my $pro_wavname = mv($wavname);
		my $flag = query($wavname,$es,$index);
		if($flag eq 'false')
		{
			my $reference = OuterServer::callNuanceEnglishAsrEngine($index,$es,$fileserver_url,$pro_wavname,$engine_url);
			print $engine_url."|".$pro_wavname.'|'.$reference."\n";
		}
		elsif($flag eq 'true')
		{
			print $pro_wavname." has been processed!\n";
		}
	}
}

sub query
{
	my $wavname = shift;
	my $es = shift;
	my $index = shift;

	my $results = $es->search(index => $index,body => {query => {match => {_id => $wavname}}});
	my $flag = $results->{hits}->{total};
	my $text = $results->{hits}->{hits}->[0]->{_source}->{text};
	
	if($flag > 0 and $text ne '')
	{
		return 'true';
	}
	else
	{
		return 'false';
	}
}

sub mv
{
	my $filename = shift;

	my $first_dir;
	my $second_dir;
	my $oldname;
	my $newname;
	if($filename =~ /(.*\/vadnn\/)(.*\/)(.*.wav)/)
	{
		$first_dir = $1;
		$second_dir = $2;
		$oldname = $3;

		my $flag = index($oldname,'%',0);
		if($flag >= 0)
		{
			$newname = $oldname;
			$newname =~ s/%//g;
			$second_dir =~ s/%//g;
			my $f_str = "mkdir -p ".$first_dir.$second_dir;
			my $s_str = "cp ".$filename." ".$first_dir.$second_dir.$newname;
			system($f_str);	
			system($s_str);	
			return $first_dir.$second_dir.$newname;
		}
		else
		{
			return $filename;
		}
	}
}

1;

