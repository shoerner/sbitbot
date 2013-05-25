#!/usr/bin/perl

use strict;
use warnings;
use Bot::BasicBot;
use Config::Simple;

my $cfg = new Config::Simple('bot.cfg');

#Get variables here like thus
# my $var = $cfg->param("Varname");

my $bot = Bot::BasicBot->new(
	server => $cfg->param('server'),
	port   => $cfg->param('port'),
	channels => $cfg->param('channels'),

	nick   => $cfg->param('nick'),
	username => $cfg->param('username'),
	name   => $cfg->param('realname'),
);
$bot->run();

sub said
{
	my ($self, $message) = @_;
	my $who = $message->{raw_nick};
	my $channel = $message->{channel};
	my $body = $message->{body};
	
	toIRCLog($who, $channel, $body);
}

sub toIRCLog
{
	if(!$cfg->param('storeChat'))
	{
		return 0;
	}
	else
	{
		#Make file handle
		open
}
