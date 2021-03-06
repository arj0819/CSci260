#!/usr/bin/perl


use File::Spec;
use CGI qw(:standard);
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
    my $name = $session->param('actualName');
    my $success = $session->param('successString');
   
    my $username = "root";
    my $password = "password";

    my $dsn = "DBI.mysql:f16final:localhost";
    my $dbh = DBI->connect ("DBI:mysql:f16final:localhost", "root", "password") or die ("Couldn't make connection to database: $DBI::errstr");

    if (!$dbh)
    {
        print start_html(-title=>"Home | UND Course Manager");
        print "<body>";
        print "Could not connect to the database, please try again later.";
        print  "</body>";
        print end_html();
        exit;
    }
    
    my $orderby;
    
    if (param('orderBy'))
    {
        $orderBy = "ORDER BY ".param('orderBy');
    }
    else
    {
        $orderBy = "";
    }
    
    my $searchType;
    my $searchText;
    
    if (param('rdoSearchType') eq 'Department')
    {
        $searchType = 'department'
    }
    else
    {
        $searchType = 'classname';
    }
    
    $searchText = param('txtSearch');
    

    print header(-cookie=>$cookie);
    print start_html(-title=>"Home | UND Course Manager");
    
    
    print "<body>";
    my $sql;
    if ($searchText ne "")
    {
        $sql = qq{SELECT * FROM tblclasses WHERE $searchType LIKE "\%$searchText%" $orderBy};
    }
    else
    {
        $sql = qq{SELECT * FROM tblclasses $orderBy};
    }
    
    my $sth = $dbh->prepare($sql);
    my $recordCount = $sth->execute();

    if ($recordCount > 0)
    {
        print br, "<h1 align=center>UND Course Manager</h1>";
        print "<p align=center><span style=\"font-size:large;\">Hello, $name. Your courses are listed below:</span></p>", br;
        print "<table align=center border=1 cellpadding=15>";
        print "<tr>
                    <td colspan=7 align=center>";
        
               
                         print start_form(-action=>'/cgi-bin/index.pl', -method=>'get');
                         print radio_group (-name=>'rdoSearchType', -value=>['Class Name', 'Department'], -default=>'Class Name'), "&nbsp;&nbsp;&nbsp;";
                         print "<input name=txtSearch type=text>&nbsp;<input name=btnSearch type=submit value=Search>";
                         print end_form();
                    print "</td></tr><tr>
                    <td align=center>
                        <a href=\"/cgi-bin/index.pl?orderBy=classname&txtSearch=$searchText\">Class Name</a>
                    </td>
                    <td align=center>
                        <a href=\"/cgi-bin/index.pl?orderBy=department&txtSearch=$searchText\">Departnemt</a>
                    </td>
                    <td align=center>
                        Class #
                    </td>
                    <td align=center>    
                        <a href=\"/cgi-bin/index.pl?orderBy=grade&txtSearch=$searchText\">Grade</a>
                    </td>
                    <td align=center>    
                        <a href=\"/cgi-bin/index.pl?orderBy=credits&txtSearch=$searchText\">Credits</a>
                    </td>
              </tr>";
        while (my $hashRef = $sth->fetchrow_hashref())
        {
            print Tr (td($hashRef->{'classname'}), "\n",
                      td($hashRef->{'department'}), "\n",
                      td($hashRef->{'classnum'}), "\n",
                      td($hashRef->{'grade'}), "\n",
                      td($hashRef->{'credits'}), "\n",
                      td("<form method=\"post\" action=\"/cgi-bin/editClass.pl\" enctype=\"multipart/form-data\"><input name=btn".$hashRef->{'classid'}." type=submit value=Edit>", "<input name=classid type=hidden value=".$hashRef->{'classid'}."></form>"), "\n",
                      td("<form method=\"post\" action=\"/cgi-bin/verifyDeleteClass.pl\" enctype=\"multipart/form-data\"><input name=btn".$hashRef->{'classid'}." type=submit value=Delete>", "<input name=classid type=hidden value=".$hashRef->{'classid'}."></form>")), "\n";

        }
        print "<tr>
                    <td colspan=5 align=center>
                        <a href=\"/cgi-bin/addClass.pl\">Add a Class</a>
                    </td>
                    <td colspan=2 align=center>
                        <a href=\"/cgi-bin/transcript.pl\">View Transcript</a>
                    </td>
              </tr>";
        print "</table>";
    }
    else
    {
        print br, "<h1 align=center>UND Course Manager</h1>";
        print "<p align=center><span style=\"font-size:large;\">Sorry, no records were found.</span></p>", br;
        print "<table align=center border=1 cellpadding=15>";
        print "<tr>
                    <td colspan=7 align=center>";
        
               
                         print start_form(-action=>'/cgi-bin/transcript.pl', -method=>'get');
                         print radio_group (-name=>'rdoSearchType', -value=>['Class Name', 'Department'], -default=>'Class Name'), "&nbsp;&nbsp;&nbsp;";
                         print "<input name=txtSearch type=text>&nbsp;<input name=btnSearch type=submit value=Search>";
                         print end_form();
                         print "</td></tr><tr>
                    <td align=center>
                        <a href=\"#\">Class Name</a>
                    </td>
                    <td align=center>
                        <a href=\"#\">Departnemt</a>
                    </td>
                    <td align=center>
                        Class #
                    </td>
                    <td align=center>    
                        <a href=\"#\">Grade</a>
                    </td>
                    <td align=center>    
                        <a href=\"#\">Credits</a>
                    </td>
              </tr>";
        print "<tr>
                    <td colspan=5 align=center>
                        <a href=\"/cgi-bin/addClass.pl\">Add a Class</a>
                    </td>
              </tr>";
        print "</table>", br;
        print "<p align=center>To return to the home page, please click <a href=\"/cgi-bin/index.pl\"><span style=\"font-weight:bold;\">here.</span></a>";
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










