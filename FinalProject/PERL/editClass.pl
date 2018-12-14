#!/usr/bin/perl

use CGI qw(:standard);
use File::Spec;
use CGI::Session;
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
    
    my $classid;
    if (-t)
    {
        $classid = 1;
    }
    else
    {
         $classid = param('classid');
    }
    
   
    
    if (!$dbh || !$classid)
    {
        print start_html(-title=>"Edit Class | UND Course Manager");
        print "<body>";
        print "Could not connect to the database.";
        print "</body>";
        print end_html();
        exit;
    }
    
    
    print header(-cookie=>$cookie);
    print start_html(-title=>"Edit Class | UND Course Manager");
    print "<body>";
    
    my $sql = "SELECT * from tblclasses WHERE classid = $classid";
    my $sth = $dbh->prepare($sql);
    my $recordCount = $sth->execute();
    if ($recordCount > 0)
    {
    
        my $hashRef = $sth->fetchrow_hashref();
        
        print br, "<h1 align=center>UND Course Manager</h1>";
        print "<p align=center><span style=\"font-size:large;\">Please edit the course below and click Update when finished.</span></p>", br;
        print "<p align=center>To return to the home page, please click <a href=\"/cgi-bin/index.pl\"><span style=\"font-weight:bold;\">here.</span></a>", br, br;
        print "<form method=\"post\" action=\"/cgi-bin/verifyEditClass.pl\" enctype=\"multipart/form-data\">";
        print "<p align=center>Class Name</p>";
        print "<p align=center><input name=\"txtClassName\" maxlength=100 type=text value=\"".$hashRef->{'classname'}."\" required></p>", br;
        print "<p align=center>Department</p>";
        print "<p align=center><input name=\"txtDepartment\" maxlength=5 type=text value=\"".$hashRef->{'department'}."\" required></p>", br;
        print "<p align=center>Class #</p>";
        print "<p align=center><input name=\"txtClassNum\" maxlength=5 type=text value=\"".$hashRef->{'classnum'}."\" required></p>", br;
        print "<p align=center>Grade</p>";
        print "<p align=center>";print radio_group(-name=>'rdoGrade', -value=>['A   ', 'B   ', 'C   ', 'D   ', 'F   ', 'S   ', 'U   '], -default=>$hashRef->{'grade'}."   "); print"</p>", br;
        print "<p align=center>Credits</p>";
        print "<p align=center><input name=\"txtCredits\" maxlength=2 type=text value=\"".$hashRef->{'credits'}."\" required></p>", br;
        print "<p align=center><input name=btn".$hashRef->{'classid'}." type=submit value=Update><input name=classid type=hidden value=".$hashRef->{'classid'}."></p></form>";
       
               
        #print Tr (td($hashRef->{'classname'}), "\n",
        #              td($hashRef->{'department'}), "\n",
        #              td($hashRef->{'classnum'}), "\n",
        #              td($hashRef->{'grade'})), "\n";
                      
        #while (my $hashRef = $sth->fetchrow_hashref())
        #{
        #
        #    print Tr (td($hashRef->{'classname'}), "\n",
        #              td($hashRef->{'department'}), "\n",
        #              td($hashRef->{'classnum'}), "\n",
        #              td($hashRef->{'grade'})), "\n";
        #}
        
    }
    else
    {
        print "<p align=center>Unable to find any records</p>";
    }
    print "</body>";
    print end_html();
}
else
{
   print header(), start_html(-title=> "Session Expired | UND Course Manager");
   print br, "<h1 align=center>UND Course Manager</h1>","<p align=center><span style=\"font-size:large;\">You do not have permission to run this page. Your session may have expired.</span></p>", br;
   print "<p align=center>To return to the home page, please click <a href=\"/html/\"><span style=\"font-weight:bold;\">here.</span></a>", br;
   print end_html();
}
    
