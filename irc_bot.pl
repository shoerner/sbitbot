#!/usr/bin/perl
package MyBot;
use warnings;
use strict;
use Config::Simple;
use File::Grep qw{fgrep};
use URI::Title qw( title );
use base qw( Bot::BasicBot );

my $cfg = new Config::Simple('bot.cfg');

#Overrides Bot::BasicBot 'said' sub
sub said
{
    my ($self, $message) = @_;
    
    my $who = $message->{raw_nick};
    my $channel = $message->{channel};
    my $body = $message->{body}; 

    toIRCLog($who, $channel, $body);

    #If this is not a private message and the caller command is present
    if($channel ne 'msg' && $body =~ /^\!/)
    {
        toCMDLog($who, $channel, $body);
        return runCommand($who, $body);
    }
    #Ignore messages sent over private channels (future development: listen to specific user)
    elsif($channel eq 'msg')
    {
        return "Sorry, private messages are not accepted at this time\n";
    }
    #If a URL is sent in the chan
    elsif($body =~ /^http/)
    {
        return title($body) . " - $body";
    }
    else
    {
        return;
    }
}

#logs IRC output to file if enabled
sub toIRCLog
{
    my ($who, $channel, $body) = @_;
    if(!$cfg->param('storeChat'))
    {
        return 0;
    }
    else
    {
        #Make file handle
        my @timeData = localtime(time);
        my $fileTime = $timeData[4] . $timeData[3] . (1900+$timeData[5]);
        my $file = $cfg->param('storeChatPrefix') . "$channel" . "_$fileTime.txt";
        open(my $fileHandle, ">>", $file);
        print $fileHandle "$timeData[3]:$timeData[2]:$timeData[1] [$who]: $body\n";
        close($fileHandle);
    }
    return;
}

#logs command execution to file if enabled
sub toCMDLog
{
    my ($who, $channel, $body) = @_;
    if(!$cfg->param('storeCommands'))
    {
            return 0;
    }
    else
    {
        #Make file handle
        my @timeData = localtime(time);
        my $fileTime = $timeData[4] . $timeData[3] . (1900+$timeData[5]);
        my $file = $cfg->param('storeCommandsLog') . "$channel" . "_$fileTime.txt";
        open(my $fileHandle, ">>", $file);
        print $fileHandle "$timeData[3]:$timeData[2]:$timeData[1] [$who]: $body\n";
        close($fileHandle);
    }
    return;
}

#Checks for command keywords
sub runCommand
{
    #Get username requesting - possible future implementation
    my $requestUser = $_[0];

    #Remainder of string is requested command
    my $command = substr($_[1], 1);

    my $localCommand = substr($command, 0, index($command, ' '));
    my $commandArguements = substr($command, index($command, ' ')); 

    if($localCommand =~ m/^choose$/) { return choose($commandArguements); }
    elsif($localCommand =~ m/^history$/) { return historySearch($requestUser, $commandArguements);}
}

#Random choice 
sub choose
{
    my @choiceElements = split(/ /, $_[0]);
    return $choiceElements[rand @choiceElements];
}

#TODO: Search history files
sub historySearch
{
    my $user = shift(@_);
    my $string = join(' ', @_);
    my @matches = fgrep { $string } glob "ircLog*.txt";
    warn $matches[0]{'matches');
    MyBot->say({who=>$user, channel=>'msg', body=>join("\n", @matches)});
    return;
}

# help text for the bot
sub help { "I'm annoying, and do nothing useful." }

# Create an instance of the bot and start it running. Connect
# to the main perl IRC server, and join some channels.
MyBot->new(
    server => $cfg->param('server'),
    channels => $cfg->param('channels'),

    nick      => $cfg->param('nick'),
    alt_nicks => [$cfg->param('altnicks')],
)->run();
