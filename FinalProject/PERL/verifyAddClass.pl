#!/usr/bin/perl

use CGI qw(:standard);
use CGI::Session;
use File::Spec;
use DBI;
use DBD::mysql;


#get the client-side cookie, the link to the server cookie

my $sessionID = cookie ('perl260');

my $session = new CGI::Session (undef, $sessionID,  {Directory=>File::Spec->tmpdir() } );
if ($session->param ('loggedin'))
{
   
   #and let's get 60 more seconds of "logged in" time
   my $cookie = cookie (-name=>'perl260',
                        -value => $session->id,
                        -expires => '+1m' );
    my $username = "root";
    my $password = "password";

    my $dsn = "DBI:mysql:f16final:localhost";
    my $dbh = DBI->connect ("DBI:mysql:f16final:localhost", "root", "password") or die ("Couldn't make connection to database: $DBI::errstr");
    
    my $classname;
    my $department;
    my $classnum;
    my $grade;
    my $credits;
    

    if (-t)
    {
        $classname = "Computer Science I";
        $department = "CSCI";
        $classnum = "160";
        $grade = "C";
        $credits = 3;
    }
    else
    {
         
         $classname = param ('txtClassName');
        $department = param ('txtDepartment');
        $classnum = param ('txtClassNum');
        $grade = param ('rdoGrade');
        $credits = param ('txtCredits');
    }

    
    if (!$dbh)
    {
        print header();
        print start_html(-title=>"Add Class | UND Course Manager");
        print "<body>";
        print "Could not connect to the database.";
        print "</body>";
        print end_html();
        exit;
    }
    
    my $sql = qq{INSERT INTO tblclasses (classname, department, classnum, grade, credits) VALUES ("$classname", "$department", "$classnum", "$grade", $credits)};
    my $sth = $dbh->prepare($sql);
    my $recordCount = $sth->execute();
    
    
    print header(), start_html(-title=>"Add Class | UND Course Manager");
    #print redirect (-cookie=>$cookie, -location=>'/cgi-bin/index.pl'), start_html(), end_html();
    print br, "<h1 align=center>UND Course Manager</h1>","<p align=center><span style=\"font-size:large;\">Addition successful.</span></p>", br;
    print "<p align=center>Click <a href=\"/cgi-bin/index.pl\"><span style=\"font-weight:bold;\">here</span></a> to return home.</p>";
}
else
{
   print header(), start_html(-title=> "Session Expired | UND Course Manager");
   print br, "<h1 align=center>UND Course Manager</h1>","<p align=center><span style=\"font-size:large;\">You do not have permission to run this page. Your session may have expired.</span></p>", br;
   print "<p align=center>To return to the home page, please click <a href=\"/html/\"><span style=\"font-weight:bold;\">here.</span></a>", br;
   print end_html();
}
