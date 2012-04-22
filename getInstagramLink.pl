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
use utf8;

use Time::Piece ();
use POSIX qw(strftime);
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

my $now = Time::Piece::localtime();

my $blog_title  = 'Instagram photos ';
my $blog_header = '先週 Instagram にポストした写真をご紹介します。';
my $blog_body = '';

my $data_set = [];  # ハッシュテーブル格納配列

my $instagramApplication;
my %useApplications;
my %applicationList;

# my $week=1;
# my $period=1;
# my $options = [[\$week, 1],[\$period, 1]];
# getOptions(\$options);

&initApplicationList(%useApplications, %applicationList);
&loadFeed($url);
$blog_body = makeBody(\@$data_set);
$blog_body .= makeApplicationList(\%useApplications, \%applicationList);
&outputRecord($blog_body);

sub loadFeed {
    my $feed;
    my $entry;

    $feed = XML::Feed->parse(URI->new($_[0]));

    foreach $entry (reverse($feed->entries)) {
        
        if (isPrevWeek($now, getTimeFromIssueDate($entry->issued()))) {
            
            my $record = {};

            $record->{title} = (trim($entry->title()) ne '') ? $entry->title() : 'No title';
            $record->{body} = $entry->content()->body();
            $record->{url} = $entry->link();
            $record->{date} = getPrintDateFormat(getTimeFromIssueDate($entry->issued()));
        
            push @$data_set, $record;
        }
    }
}

sub makeBody{

    my $body = '';
    my $records = [];
    my $record = {};
    my $item_count = 0;

    foreach $records (@_){
        foreach $record (@$records){
                
            $item_count += 1;
            $body .= '<hr /><strong>';
            $body .= Encode::encode("utf8", $record->{title});
            $body .= '</strong>';
            $body .= $record->{body};
            $body .= '<div style="font-size: 80%;"><a href="' . $record->{url} . '">' . $record->{url} . '</a><br />';
            $body .= $record->{date} . '</div><br />' . "\n";

            setApplicationFlag($record->{title}, \%useApplications);
        }
    }
    
    $blog_header = "Instagram photos, " . $now->strftime('%W') . " weeks of " . $now->strftime('%Y') . "\n\n" . '先週 Instagram にアップロードした ' . $item_count . ' 件の写真をご紹介します。<br /><br />' . $instagramApplication . '<br /><!--more--><br />' . "\n\n";
    $body = Encode::encode("utf8", $blog_header) . $body;
}

sub setApplicationFlag {
    foreach my $application (keys(%{$_[1]})) {
        if ($_[0] =~ $application) {
            $_[1]{$application} = 1;
        }
    }
}

sub makeApplicationList{
    my $application_count = 0;
    my $application_body ='';
    
    foreach my $application (keys(%{$_[0]})){
        if($_[0]{$application} eq 1) {
            $application_body = $application_body . $_[1]{$application} . '<br /><br />';
            $application_count += 1;
        }
    }
    if ($application_count ne 0){
        $application_body = '<hr>' . "\n" . '今回ご紹介した写真に使ったアプリケーションです。(価格はダウンロード時に必ずご確認ください)<br /><br />' . "\n\n" . $application_body;
    }
    Encode::encode("utf8", $application_body);
}

sub initApplicationList {
    %useApplications =
    ("photogene2" => 0,
    "dynamiclight" => 0,
    "TiltshiftGen" => 0,
    "Rays" => 0,
    "CAMERAtan" => 0,
    "BigLens" => 0,
    "PhotoForge2" => 0,
    "LensLight" => 0,
    "LensFlare" => 0,
    "SnapSeed" => 0
    );
    
    %applicationList =
    (
    "photogene2" => "<a href='http://click.linksynergy.com/fs-bin/stat?tmpid=2192&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fjp%252Fapp%252Fphotogene2-for-iphone%252Fid463731084%253Fmt%253D8%2526uo%253D4%2526partnerId%253D30&offerid=94348&subid=0&type=3&id=t1Mwpg34oUA' target='_blank' rel='nofollow'><img width='75' class='alignleft' align='left' src='http://a2.mzstatic.com/us/r1000/100/Purple/08/b7/40/mzl.otifskwk.75x75-65.png' style='border-radius: 11px 11px 11px 11px;-moz-border-radius: 11px 11px 11px 11px;-webkit-border-radius: 11px 11px 11px 11px;box-shadow: 1px 4px 6px 1px #999999;-moz-box-shadow: 1px 4px 6px 1px #999999;-webkit-box-shadow: 1px 4px 6px 1px #999999;margin: -5px 15px 1px 5px;'></a><strong> Photogene² for iPhone 1.20 (￥85)</strong><a href='http://click.linksynergy.com/fs-bin/stat?tmpid=2192&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fjp%252Fapp%252Fphotogene2-for-iphone%252Fid463731084%253Fmt%253D8%2526uo%253D4%2526partnerId%253D30&offerid=94348&subid=0&type=3&id=t1Mwpg34oUA' target='_blank' rel='nofollow'><img src='http://r.mzstatic.com/htmlResources/2338/images/viewinitunes_jp.png' style='vertical-align:bottom;' width='90' alt='App'></a><br> カテゴリ: 写真／ビデオ, 仕事効率化<br> 販売元: <a href='http://click.linksynergy.com/fs-bin/stat?tmpid=2192&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fjp%252Fartist%252Fomer-shoor%252Fid287273859%253Fuo%253D4%2526partnerId%253D30&offerid=94348&subid=0&type=3&id=t1Mwpg34oUA' target='_blank' rel='nofollow'>Omer Shoor - Omer Shoor</a>（サイズ: 16.7 MB）<br style='clear: both;'>",
    "dynamiclight" => "<a href='http://click.linksynergy.com/fs-bin/stat?tmpid=2192&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fjp%252Fapp%252Fdynamic-light%252Fid422494924%253Fmt%253D8%2526uo%253D4%2526partnerId%253D30&offerid=94348&subid=0&type=3&id=t1Mwpg34oUA' target='_blank' rel='nofollow'><img width='75' class='alignleft' align='left' src='http://a3.mzstatic.com/us/r1000/058/Purple/59/f1/89/mzl.xzyuypks.75x75-65.png' style='border-radius: 11px 11px 11px 11px;-moz-border-radius: 11px 11px 11px 11px;-webkit-border-radius: 11px 11px 11px 11px;box-shadow: 1px 4px 6px 1px #999999;-moz-box-shadow: 1px 4px 6px 1px #999999;-webkit-box-shadow: 1px 4px 6px 1px #999999;margin: -5px 15px 1px 5px;'></a><strong> Dynamic Light 1.7 (￥85)</strong><a href='http://click.linksynergy.com/fs-bin/stat?tmpid=2192&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fjp%252Fapp%252Fdynamic-light%252Fid422494924%253Fmt%253D8%2526uo%253D4%2526partnerId%253D30&offerid=94348&subid=0&type=3&id=t1Mwpg34oUA' target='_blank' rel='nofollow'><img src='http://r.mzstatic.com/htmlResources/2338/images/viewinitunes_jp.png' style='vertical-align:bottom;' width='90' alt='App'></a><br> カテゴリ: 写真／ビデオ<br> 販売元: <a href='http://click.linksynergy.com/fs-bin/stat?tmpid=2192&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fjp%252Fartist%252Fmediachance%252Fid420583576%253Fuo%253D4%2526partnerId%253D30&offerid=94348&subid=0&type=3&id=t1Mwpg34oUA' target='_blank' rel='nofollow'>Mediachance - Oscar Voska</a>（サイズ: 6.8 MB）<br style='clear: both;'>",
    "TiltshiftGen" => "<a href='http://click.linksynergy.com/fs-bin/stat?tmpid=2192&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fjp%252Fapp%252Ftiltshift-generator-minichua%252Fid327716311%253Fmt%253D8%2526uo%253D4%2526partnerId%253D30&offerid=94348&subid=0&type=3&id=t1Mwpg34oUA' target='_blank' rel='nofollow'><img width='75' class='alignleft' align='left' src='http://a4.mzstatic.com/us/r1000/105/Purple/e2/99/8e/mzl.tnbhgkyt.75x75-65.png' style='border-radius: 11px 11px 11px 11px;-moz-border-radius: 11px 11px 11px 11px;-webkit-border-radius: 11px 11px 11px 11px;box-shadow: 1px 4px 6px 1px #999999;-moz-box-shadow: 1px 4px 6px 1px #999999;-webkit-box-shadow: 1px 4px 6px 1px #999999;margin: -5px 15px 1px 5px;'></a><strong> TiltShift Generator - ミニチュア風トイカメラ 2.02 (￥85)</strong><a href='http://click.linksynergy.com/fs-bin/stat?tmpid=2192&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fjp%252Fapp%252Ftiltshift-generator-minichua%252Fid327716311%253Fmt%253D8%2526uo%253D4%2526partnerId%253D30&offerid=94348&subid=0&type=3&id=t1Mwpg34oUA' target='_blank' rel='nofollow'><img src='http://r.mzstatic.com/htmlResources/2338/images/viewinitunes_jp.png' style='vertical-align:bottom;' width='90' alt='App'></a><br> カテゴリ: 写真／ビデオ, ライフスタイル<br> 販売元: <a href='http://click.linksynergy.com/fs-bin/stat?tmpid=2192&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fjp%252Fartist%252Fart-mobile%252Fid288895705%253Fuo%253D4%2526partnerId%253D30&offerid=94348&subid=0&type=3&id=t1Mwpg34oUA' target='_blank' rel='nofollow'>Art & Mobile - Art & Mobile</a>（サイズ: 1.8 MB）<br style='clear: both;'>",
    "Rays" => "<a href='http://click.linksynergy.com/fs-bin/stat?tmpid=2192&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fjp%252Fapp%252Frays%252Fid411190058%253Fmt%253D8%2526uo%253D4%2526partnerId%253D30&offerid=94348&subid=0&type=3&id=t1Mwpg34oUA' target='_blank' rel='nofollow'><img width='75' class='alignleft' align='left' src='http://a5.mzstatic.com/us/r1000/031/Purple/e0/8d/ba/mzl.foyhwgpn.75x75-65.png' style='border-radius: 11px 11px 11px 11px;-moz-border-radius: 11px 11px 11px 11px;-webkit-border-radius: 11px 11px 11px 11px;box-shadow: 1px 4px 6px 1px #999999;-moz-box-shadow: 1px 4px 6px 1px #999999;-webkit-box-shadow: 1px 4px 6px 1px #999999;margin: -5px 15px 1px 5px;'></a><strong> Rays 1.0.1 (￥85)</strong><a href='http://click.linksynergy.com/fs-bin/stat?tmpid=2192&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fjp%252Fapp%252Frays%252Fid411190058%253Fmt%253D8%2526uo%253D4%2526partnerId%253D30&offerid=94348&subid=0&type=3&id=t1Mwpg34oUA' target='_blank' rel='nofollow'><img src='http://r.mzstatic.com/htmlResources/2338/images/viewinitunes_jp.png' style='vertical-align:bottom;' width='90' alt='App'></a><br> カテゴリ: 写真／ビデオ, ユーティリティ<br> 販売元: <a href='http://click.linksynergy.com/fs-bin/stat?tmpid=2192&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fjp%252Fartist%252Fdigital-film-tools%252Fid299378602%253Fuo%253D4%2526partnerId%253D30&offerid=94348&subid=0&type=3&id=t1Mwpg34oUA' target='_blank' rel='nofollow'>Digital Film Tools - Digital Film Tools</a>（サイズ: 3.3 MB）<br style='clear: both;'>",
    "CAMERAtan" => "<a href='http://click.linksynergy.com/fs-bin/stat?tmpid=2192&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fjp%252Fapp%252Fcameratan-toidejitarukamera%252Fid327075195%253Fmt%253D8%2526uo%253D4%2526partnerId%253D30&offerid=94348&subid=0&type=3&id=t1Mwpg34oUA' target='_blank' rel='nofollow'><img width='75' class='alignleft' align='left' src='http://a3.mzstatic.com/us/r1000/102/Purple/e6/fd/08/mzl.lnkzzwzq.75x75-65.png' style='border-radius: 11px 11px 11px 11px;-moz-border-radius: 11px 11px 11px 11px;-webkit-border-radius: 11px 11px 11px 11px;box-shadow: 1px 4px 6px 1px #999999;-moz-box-shadow: 1px 4px 6px 1px #999999;-webkit-box-shadow: 1px 4px 6px 1px #999999;margin: -5px 15px 1px 5px;'></a><strong> CAMERAtan -トイデジタルカメラ- 3.4 (￥170)</strong><a href='http://click.linksynergy.com/fs-bin/stat?tmpid=2192&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fjp%252Fapp%252Fcameratan-toidejitarukamera%252Fid327075195%253Fmt%253D8%2526uo%253D4%2526partnerId%253D30&offerid=94348&subid=0&type=3&id=t1Mwpg34oUA' target='_blank' rel='nofollow'><img src='http://r.mzstatic.com/htmlResources/2338/images/viewinitunes_jp.png' style='vertical-align:bottom;' width='90' alt='App'></a><br> カテゴリ: 写真／ビデオ<br> 販売元: <a href='http://click.linksynergy.com/fs-bin/stat?tmpid=2192&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fjp%252Fartist%252Fmorokoshiman%252Fid304098655%253Fuo%253D4%2526partnerId%253D30&offerid=94348&subid=0&type=3&id=t1Mwpg34oUA' target='_blank' rel='nofollow'>MorokoshiMan - Yasuhiro Kume</a>（サイズ: 18.8 MB）<br style='clear: both;'>",
    "BigLens" => "<a href='http://click.linksynergy.com/fs-bin/stat?tmpid=2192&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fjp%252Fapp%252Fbig-lens%252Fid470460905%253Fmt%253D8%2526uo%253D4%2526partnerId%253D30&offerid=94348&subid=0&type=3&id=t1Mwpg34oUA' target='_blank' rel='nofollow'><img width='75' class='alignleft' align='left' src='http://a4.mzstatic.com/us/r1000/102/Purple/f5/de/df/mzl.bgjplvwl.75x75-65.png' style='border-radius: 11px 11px 11px 11px;-moz-border-radius: 11px 11px 11px 11px;-webkit-border-radius: 11px 11px 11px 11px;box-shadow: 1px 4px 6px 1px #999999;-moz-box-shadow: 1px 4px 6px 1px #999999;-webkit-box-shadow: 1px 4px 6px 1px #999999;margin: -5px 15px 1px 5px;'></a><strong> Big Lens 1.0.1502.1 (￥85)</strong><a href='http://click.linksynergy.com/fs-bin/stat?tmpid=2192&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fjp%252Fapp%252Fbig-lens%252Fid470460905%253Fmt%253D8%2526uo%253D4%2526partnerId%253D30&offerid=94348&subid=0&type=3&id=t1Mwpg34oUA' target='_blank' rel='nofollow'><img src='http://r.mzstatic.com/htmlResources/2338/images/viewinitunes_jp.png' style='vertical-align:bottom;' width='90' alt='App'></a><br> カテゴリ: 写真／ビデオ, ライフスタイル<br> 販売元: <a href='http://click.linksynergy.com/fs-bin/stat?tmpid=2192&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fjp%252Fartist%252Freallusion-inc.%252Fid347016229%253Fuo%253D4%2526partnerId%253D30&offerid=94348&subid=0&type=3&id=t1Mwpg34oUA' target='_blank' rel='nofollow'>Reallusion Inc. - Reallusion Inc.</a>（サイズ: 13.9 MB）<br style='clear: both;'>",
    "PhotoForge2" => "<a href='http://click.linksynergy.com/fs-bin/stat?tmpid=2192&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fjp%252Fapp%252Fphotoforge2%252Fid435789422%253Fmt%253D8%2526uo%253D4%2526partnerId%253D30&offerid=94348&subid=0&type=3&id=t1Mwpg34oUA' target='_blank' rel='nofollow'><img width='75' class='alignleft' align='left' src='http://a4.mzstatic.com/us/r1000/069/Purple/v4/8f/3b/dc/8f3bdcb8-ddf4-1f4c-8e21-c8e1cb38df15/mzl.optfecjv.75x75-65.png' style='border-radius: 11px 11px 11px 11px;-moz-border-radius: 11px 11px 11px 11px;-webkit-border-radius: 11px 11px 11px 11px;box-shadow: 1px 4px 6px 1px #999999;-moz-box-shadow: 1px 4px 6px 1px #999999;-webkit-box-shadow: 1px 4px 6px 1px #999999;margin: -5px 15px 1px 5px;'></a><strong> PhotoForge2 2.1.8 (￥250)</strong><a href='http://click.linksynergy.com/fs-bin/stat?tmpid=2192&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fjp%252Fapp%252Fphotoforge2%252Fid435789422%253Fmt%253D8%2526uo%253D4%2526partnerId%253D30&offerid=94348&subid=0&type=3&id=t1Mwpg34oUA' target='_blank' rel='nofollow'><img src='http://r.mzstatic.com/htmlResources/2338/images/viewinitunes_jp.png' style='vertical-align:bottom;' width='90' alt='App'></a><br> カテゴリ: 写真／ビデオ, エンターテインメント<br> 販売元: <a href='http://click.linksynergy.com/fs-bin/stat?tmpid=2192&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fjp%252Fartist%252Fghostbird-software%252Fid310150725%253Fuo%253D4%2526partnerId%253D30&offerid=94348&subid=0&type=3&id=t1Mwpg34oUA' target='_blank' rel='nofollow'>GhostBird Software - GhostBird Software</a>（サイズ: 23.5 MB）<br style='clear: both;'>",
    "LensLight" => "<a href='http://click.linksynergy.com/fs-bin/stat?tmpid=2192&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fjp%252Fapp%252Flenslight%252Fid419518259%253Fmt%253D8%2526uo%253D4%2526partnerId%253D30&offerid=94348&subid=0&type=3&id=t1Mwpg34oUA' target='_blank' rel='nofollow'><img width='75' class='alignleft' align='left' src='http://a5.mzstatic.com/us/r1000/093/Purple/v4/a7/4a/55/a74a550e-27da-e1f7-4083-db7f5f9f2d5a/mza_7143595926308578340.75x75-65.png' style='border-radius: 11px 11px 11px 11px;-moz-border-radius: 11px 11px 11px 11px;-webkit-border-radius: 11px 11px 11px 11px;box-shadow: 1px 4px 6px 1px #999999;-moz-box-shadow: 1px 4px 6px 1px #999999;-webkit-box-shadow: 1px 4px 6px 1px #999999;margin: -5px 15px 1px 5px;'></a><strong> LensLight 3.0 (￥85)</strong><a href='http://click.linksynergy.com/fs-bin/stat?tmpid=2192&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fjp%252Fapp%252Flenslight%252Fid419518259%253Fmt%253D8%2526uo%253D4%2526partnerId%253D30&offerid=94348&subid=0&type=3&id=t1Mwpg34oUA' target='_blank' rel='nofollow'><img src='http://r.mzstatic.com/htmlResources/2338/images/viewinitunes_jp.png' style='vertical-align:bottom;' width='90' alt='App'></a><br> カテゴリ: 写真／ビデオ, 仕事効率化<br> 販売元: <a href='http://click.linksynergy.com/fs-bin/stat?tmpid=2192&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fjp%252Fartist%252Fbrainfevermedia%252Fid338517204%253Fuo%253D4%2526partnerId%253D30&offerid=94348&subid=0&type=3&id=t1Mwpg34oUA' target='_blank' rel='nofollow'>BrainFeverMedia - James Grote</a>（サイズ: 34.8 MB）<br style='clear: both;'>",
    "LensFlare" => "<a href='http://click.linksynergy.com/fs-bin/stat?tmpid=2192&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fjp%252Fapp%252Flensflare%252Fid349424050%253Fmt%253D8%2526uo%253D4%2526partnerId%253D30&offerid=94348&subid=0&type=3&id=t1Mwpg34oUA' target='_blank' rel='nofollow'><img width='75' class='alignleft' align='left' src='http://a1.mzstatic.com/us/r1000/093/Purple/v4/22/c5/57/22c557f1-8f40-b4a2-5779-f7b97d97ce64/mzl.namzboev.75x75-65.png' style='border-radius: 11px 11px 11px 11px;-moz-border-radius: 11px 11px 11px 11px;-webkit-border-radius: 11px 11px 11px 11px;box-shadow: 1px 4px 6px 1px #999999;-moz-box-shadow: 1px 4px 6px 1px #999999;-webkit-box-shadow: 1px 4px 6px 1px #999999;margin: -5px 15px 1px 5px;'></a><strong> LensFlare 9.0 (￥85)</strong><a href='http://click.linksynergy.com/fs-bin/stat?tmpid=2192&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fjp%252Fapp%252Flensflare%252Fid349424050%253Fmt%253D8%2526uo%253D4%2526partnerId%253D30&offerid=94348&subid=0&type=3&id=t1Mwpg34oUA' target='_blank' rel='nofollow'><img src='http://r.mzstatic.com/htmlResources/2338/images/viewinitunes_jp.png' style='vertical-align:bottom;' width='90' alt='App'></a><br> カテゴリ: 写真／ビデオ, エンターテインメント<br> 販売元: <a href='http://click.linksynergy.com/fs-bin/stat?tmpid=2192&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fjp%252Fartist%252Fbrainfevermedia%252Fid338517204%253Fuo%253D4%2526partnerId%253D30&offerid=94348&subid=0&type=3&id=t1Mwpg34oUA' target='_blank' rel='nofollow'>BrainFeverMedia - James Grote</a>（サイズ: 29.7 MB）<br style='clear: both;'>",
    "SnapSeed" => "<a href='http://click.linksynergy.com/fs-bin/stat?tmpid=2192&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fjp%252Fapp%252Fsnapseed%252Fid439438619%253Fmt%253D8%2526uo%253D4%2526partnerId%253D30&offerid=94348&subid=0&type=3&id=t1Mwpg34oUA' target='_blank' rel='nofollow'><img width='75' class='alignleft' align='left' src='http://a3.mzstatic.com/us/r1000/103/Purple/v4/b7/6c/2b/b76c2bc5-2e9a-d3c4-157e-e15d9d58588c/mzl.bgyduagw.75x75-65.png' style='border-radius: 11px 11px 11px 11px;-moz-border-radius: 11px 11px 11px 11px;-webkit-border-radius: 11px 11px 11px 11px;box-shadow: 1px 4px 6px 1px #999999;-moz-box-shadow: 1px 4px 6px 1px #999999;-webkit-box-shadow: 1px 4px 6px 1px #999999;margin: -5px 15px 1px 5px;'></a><strong> Snapseed 1.4 (￥450)</strong><a href='http://click.linksynergy.com/fs-bin/stat?tmpid=2192&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fjp%252Fapp%252Fsnapseed%252Fid439438619%253Fmt%253D8%2526uo%253D4%2526partnerId%253D30&offerid=94348&subid=0&type=3&id=t1Mwpg34oUA' target='_blank' rel='nofollow'><img src='http://r.mzstatic.com/htmlResources/2338/images/viewinitunes_jp.png' style='vertical-align:bottom;' width='90' alt='App'></a><br> カテゴリ: 写真／ビデオ, ライフスタイル<br> 販売元: <a href='http://click.linksynergy.com/fs-bin/stat?tmpid=2192&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fjp%252Fartist%252Fnik-software-inc.%252Fid439438624%253Fuo%253D4%2526partnerId%253D30&offerid=94348&subid=0&type=3&id=t1Mwpg34oUA' target='_blank' rel='nofollow'>Nik Software, Inc. - Nik Software, Inc.</a>（サイズ: 17.8 MB）<br style='clear: both;'>"
    );
    
    $instagramApplication ="<a href='http://click.linksynergy.com/fs-bin/stat?tmpid=2192&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fjp%252Fapp%252Finstagram%252Fid389801252%253Fmt%253D8%2526uo%253D4%2526partnerId%253D30&offerid=94348&subid=0&type=3&id=t1Mwpg34oUA' target='_blank' rel='nofollow'><img width='75' class='alignleft' align='left' src='http://a1.mzstatic.com/us/r1000/101/Purple/v4/73/b7/b5/73b7b52d-4fa5-4ed9-6a03-7ee7ec66ef8f/mzl.ntalagmr.75x75-65.png' style='border-radius: 11px 11px 11px 11px;-moz-border-radius: 11px 11px 11px 11px;-webkit-border-radius: 11px 11px 11px 11px;box-shadow: 1px 4px 6px 1px #999999;-moz-box-shadow: 1px 4px 6px 1px #999999;-webkit-box-shadow: 1px 4px 6px 1px #999999;margin: -5px 15px 1px 5px;'></a><strong> Instagram 2.4.0 (無料)</strong><a href='http://click.linksynergy.com/fs-bin/stat?tmpid=2192&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fjp%252Fapp%252Finstagram%252Fid389801252%253Fmt%253D8%2526uo%253D4%2526partnerId%253D30&offerid=94348&subid=0&type=3&id=t1Mwpg34oUA' target='_blank' rel='nofollow'><img src='http://r.mzstatic.com/htmlResources/2338/images/viewinitunes_jp.png' style='vertical-align:bottom;' width='90' alt='App'></a><br> カテゴリ: 写真／ビデオ, ソーシャルネットワーキング<br> 販売元: <a href='http://click.linksynergy.com/fs-bin/stat?tmpid=2192&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fjp%252Fartist%252Fburbn-inc.%252Fid389801255%253Fuo%253D4%2526partnerId%253D30&offerid=94348&subid=0&type=3&id=t1Mwpg34oUA' target='_blank' rel='nofollow'>Burbn, Inc. - Burbn, inc.</a>（サイズ: 13.4 MB）<br style='clear: both;'>";
}

sub outputRecord {    

    my $filename = "getInstagram.txt";
    
    $filename = strftime("%Y%m%d%H%M", localtime()) . "_" . $filename;
    open (FILE, '> ' . $filename) or die "Can't open file" . $filename;
    
    print FILE $_[0];
    print FILE "\n\n";
    
    close (FILE);
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

# Get command line options utility
#
# Usage:
#    &getOptions([[\$x, $a], [\$y, $b], [\$z, $c]]);
#
#      Getting command line options from @ARGV,
#      and set reference variable (ex. \$x, \$y, \$z).
#      Second parameter is default value, if options are omitted.
#
sub getOptions{
    
    my $array = $_[0];
    my $i = 0;
    
    foreach (@{$$array->[0]}) {
        ${$$array->[$i]->[0]} = defined($ARGV[$i]) ? $ARGV[$i] : $$array->[$i]->[1] ;
        $i += 1;
    }        
}

# 前後の空白文字列を削除する
sub trim{
    $_[0] =~ s/^\s*(.*?)\s*$/$1/;
    $_[0];
}