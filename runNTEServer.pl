#!/usr/bin/perl

use strict;
use Config::Tiny;

my $config = Config::Tiny->new;
$config = Config::Tiny->read('config/config.ini', 'utf8');

my $nuance_engine_thread = $config->{process_Wav_config}->{nuance_engine_thread};
my $http_start_port = 11001;
my $https_start_port = 12001;
my $NTE_ROOT_DIR = qx(echo $NTE_ROOT_DIR);
$NTE_ROOT_DIR =~ s/[\r\n]//g;

for(my $i = 0; $i < $nuance_engine_thread; $i++)
{
	my $httpport = $http_start_port + $i;
	my $httpsport = $https_start_port + $i;

	system("killall nte");
	syetem("cd $NTE_ROOT_DIR");
	my $str = "$startEngine.sh --httpPort=$httpport --httpsPort=$httpsport --engineUUID=`uuidgen` &";
	print $str."\n";
	system($str);
}

1;

