#!/usr/bin/perl

use strict;
use warnings;
use Switch;
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
	
	#If this is not a private message and the caller command is present
	if($channel ne 'msg') && $body =~ /^\!/)
	{
		toCMDLog($who, $channel, $body);
		return runCommand($who, $body);
	}
	elsif($channel eq 'msg')
	{
		return "Sorry, private messages are not accepted at this time\n";
	}
	else
	{
		return undef;
	}
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

#logs command execution to file if enabled
sub toCMDLog
{
        my ($who, $channel, $body) = $_;
        if(!$cfg->param('storeCommands'))
        {
                return 0;
        }
        else
        {
                #Make file handle
                my $date = Time::Piece->new->strftime('%m%d%y');
                my $file = $cfg->param('storeCommands') . "_$date.txt";
                open(my $fileHandle, "<<", $file);
                print $fileHandle "[$who]: $body\n";
                close($fileHandle);
        }
        return;
}

sub runCommand
{
	#Get username requesting - possible future implementation
	my $requestUser = $_[0];

	#Remainder of string is requested command
	my $command = substr($_[1], 1);

	my $localCommand = substr($command, 0, index($command, ' '));
	my $commandArguements = substr($command, index($command, ' ')); 
	
	switch($localCommand)
	{
		case 'choose': { return choose($commandArguements);}
		else { return "Invalid command\n";
	}
}
sub choose
{
	my @choiceElements = split(/ /, $_[0]);
	return $choiceElements[rand @choiceElements];
}
