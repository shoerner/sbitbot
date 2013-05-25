#!/usr/bin/perl

use strict;
use warnings;
use Bot::BasicBot;
use Config::Simple;
use Time::Piece;

my $cfg = new Config::Simple('bot.cfg');

#Get callback information
my $caller = $cfg->param('caller');

#instantiate the bot
my $bot = Bot::BasicBot->new(
	server => $cfg->param('server'),
	port   => $cfg->param('port'),
	channels => $cfg->param('channels'),

	nick   => $cfg->param('nick'),
	username => $cfg->param('username'),
	name   => $cfg->param('realname'),
);
#Start the bot
$bot->run();

#Overrides Bot::BasicBot 'said' sub
sub said
{
	my ($self, $message) = @_;
	my $who = $message->{raw_nick};
	my $channel = $message->{channel};
	my $body = $message->{body};
	
	toIRCLog($who, $channel, $body);

	if($channel 
}

#logs IRC output to file if enabled
sub toIRCLog
{
	my ($who, $channel, $body) = $_;
	if(!$cfg->param('storeChat'))
	{
		return 0;
	}
	else
	{
		#Make file handle
		my $date = Time::Piece->new->strftime('%m%d%y');
		my $file = $cfg->param('storeChatPrefix') . "_$channel" . "_$date.txt";
		open(my $fileHandle, "<<", $file);
		print $fileHandle "[$who]: $body\n";
		close($fileHandle);
	}
	return;
}
