#!/usr/bin/perl

use CGI qw(:standard);
use CGI::Session;
use File::Spec;

#get client-side login failed cookie if available, use to print notification that username/password is incorrent
my $sessionID = cookie ('badLoginCookie');
if ($sessionID)
{
   print header();
   print start_html(-title=>"Login | UND Course Manager", -BGCOLOR=>'ffffff' );

    print start_form (-method=>'post', -action=>'/cgi-bin/checkLoginInfo.pl');

    print br, "<h1 align=center>UND Course Manager</h1>","<p align=center><span style=\"color:#ff0000; font-size:large;\">Your Username and/or Password was incorrect. Please try again.</span></p>", br;


}
else
{

print header(), start_html(-title=>"Login | UND Course Manager", -BGCOLOR=>'ffffff' );

print start_form (-method=>'post', -action=>'/cgi-bin/checkLoginInfo.pl');

print br, "<h1 align=center>UND Course Manager</h1>","<p align=center><span style=\"font-size:large;\">Please enter your Username and Password to proceed.</span></p>", br;
}
print "<table cellpadding=5 frame=box align=center bgcolor=#4cbb17>
	<tr>
	 <td>";

print "<span style=\"color:#fff; font-weight:bold; font-size:large; font-family:Arial;\">Username: </span></td><td>", textfield (-name=>'txtUsername'), "</td></tr>";

print "<tr><td><span style=\"color:#fff; font-weight:bold; font-size:large; font-family:Arial;\">Password: </span></td><td>", password_field (-name=>'txtPassword'), "</td></tr>";

print "<tr><td colspan=2 align=center>", submit( -name=>'cmdLogin', value=>'Login'), "</td></tr></table>";

print end_form(), end_html();



