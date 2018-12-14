#!/usr/bin/perl

use CGI qw(:standard);
use CGI::Session;
use File::Spec;
use DBI;
use DBD::mysql;

my $username = param ('txtUsername');
my $password = param ('txtPassword');

my $dsn = "DBI:mysql:f16final:localhost";
#my $dbh = DBI->connect ($dsn, $username, $password, {PrintError => 0});
my $dbh = DBI->connect ("DBI:mysql:f16final:localhost", "root", "password") or die ("Couldn't make connection to database: $DBI::errstr");

my $sql = qq{SELECT userID FROM tblusers WHERE login=? AND password=?};
my $sth = $dbh->prepare($sql) or die $dbh->errstr;
$sth->execute($username, $password) or die $sth->errstr;
my ($userID) = $sth->fetchrow_array;

#my $success = ($userID) ? 
#    qq{{"success" : "login is successful", "userid" : "$userID"}} : 
#    qq{{"error" : "username or password is wrong"}};
    
my $success = ($userID) ? qq{login was successful} : qq{};

#get user's actual name
my $sql = qq{SELECT name FROM tblusers WHERE login=? AND password=?};
$sth = $dbh->prepare($sql) or die $dbh->errstr;
$sth->execute($username, $password) or die $sth->errstr;

my ($name) = $sth->fetchrow_array;

#here is where you would verify the username and password against a table in the database
#if ($username eq "admin" && $password eq "password")

   #1st argument - dsn info - leave blank (undef)
   #2nd argument - session id, set to undef to create a new session 
   #3rd argument - where should the cookie be store on the server
   my $session = new CGI::Session (undef, undef,  {Directory=>File::Spec->tmpdir()});
   
if ($success)
{
   
   #add user info to cookie on the server
   
   $session->param ('loggedin', 'yes');
   $session->param('username', $username);
   $session->param('successString', $success);
   $session->param('actualName', $name);
   $session->close();

   my $cookie = cookie (-name=>'perl260',
                        -value => $session->id,
                        -expires => '+1m' );
   print redirect (-cookie=>$cookie, -location=>'/cgi-bin/index.pl'), start_html(), end_html();
   
}
else
{
    #login was unsuccessful
    $session->close();
    #go back to getlogininfo and notify login was incorrect using cookie
    
    my $cookie = cookie (-name=>'badLoginCookie', -value => $session->id, -expires => '+1s');
    print redirect (-cookie=>$cookie, -location=>'/cgi-bin/getLoginInfo.pl'), start_html(), end_html();
}

