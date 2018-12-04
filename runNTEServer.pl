#!/usr/bin/perl

use strict;
use Config::Tiny;

my $config = Config::Tiny->new;
$config = Config::Tiny->read('config/config.ini', 'utf8');

my $nuance_engine_thread = $config->{process_Wav_config}->{nuance_engine_thread};
my $http_start_port = 11001;
my $https_start_port = 12001;

system("killall nte");
for(my $i = 0; $i < $nuance_engine_thread; $i++)
{
	my $httpport = $http_start_port + $i;
	my $httpsport = $https_start_port + $i;

	my $str = "cd /usr/local/Nuance/Transcription_Engine; ./startEngine.sh --httpPort=$httpport --httpsPort=$httpsport --engineUUID=`uuidgen` &";
	print $str."\n";
	system($str);
}

1;

