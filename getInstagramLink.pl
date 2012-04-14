#!/usr/bin/perl

#  getInstagramLink.pl
#  
#
#  Created by azur256 on 12/04/11.
#  Copyright (c) 2012 azur256. All rights reserved.
BEGIN {
    push(@INC, '/Library/Perl/5.12/');
    push(@INC, '/opt/local/lib/perl5/site_perl/5.12.3');
    push(@INC, '/opt/local/lib/perl5/site_perl/5.12.3/darwin-multi-2level');
}

use strict;
use warnings;
use Time::Piece ();
use XML::Feed;
use URI;

use Data::Dumper;

# Time::Piece が LANG を意識するので環境変数を変更する
use POSIX qw(locale_h);
setlocale(LC_ALL, "C");

# RSS.stagram (http://rss.stagram.tk/) でフィード情報を取得する
my $url = 'http://rss.stagram.tk/feed.php?id=119509&username=azur256&rss';

# 前回読み込んだところまでのファイルを表示しようかと思ったが、前週のものを出すのが簡単かも。
# my $filename = './.checked';

my $time = Time::Piece::localtime();

my $title  = 'Instagram photos ';
my $header = '先週 Instagram にポストした写真をご紹介します。';
my $body = '';


my $feed;
my $entry;
my $uri;
my $data_set = [];  # ハッシュテーブル格納配列

$uri = URI->new( $url );
$feed = XML::Feed->parse($uri);

for $entry ($feed->entries) {
    
    $title = (($entry->title() ne '') ? $entry->title() : 'No title');
    $title = Encode::encode("utf8", $title);
    print '<hr><strong>' . $title . '</strong>';
    print $entry->content()->body();
    print '<div style="font-size: 80%;"><a href="' . $entry->link() . '">' . $entry->link() . '</a><br />';
    print getPrintDateFormat(getTimeFromIssueDate($entry->issued())) . "</div><br />\n";
    # print Dumper($entry);
}

sub getPrintDateFormat {
    $_[0]->strftime('%b %d, %Y');
}

sub getTimeFromIssueDate {
    my $time = Time::Piece->strptime($_[0], "%FT%T");
}

sub getTimeFromPubDate {
    my $time = Time::Piece->strptime($_[0], "%a, %d %b %Y %H:%M:%S %z");
}

sub getPrevWeek {
    my $time = $_[0];
    (($time->strftime('%U') -1) le 0) ? 53 : $time->strftime('%W');
}

sub isPrevWeek {

    (getPrevWeek($_[0]) eq $_[1]->strftime('%U')) ? 1 : 0;
    
}
