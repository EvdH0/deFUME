<?php
# Always include this file
include "cbs_std.php";
# Create a html header, give the title
standard_head("MetaParser-1.0 Output format");
# Create CBS menu. Format is:
# Keyword, Path, Name_of_this_page
# Keyword is the keyword for the menu color/area.
# Name_of_this_page is what this page is called in the hieraki
# Path format is a number of comma separated entries in parenthesis
# showing the path to this page; (services/,'CBS Prediction Servers')
standard_menu("CBSPS","(services/,'CBS Prediction Servers'),(services/MetaParser-1.0,'MetaParser')","Output format");
?>

<!-- START INDHOLD -->

<h1>Output format</h1>
<p>
<h3>Short description:</h3>
<p>
HERE IS A SHORT DESCRIPTION

<!-- Output format description ends here -->
<h3>Example:</h3>
<p><pre>
# HERE COULD BE AN EXAMPLE

</pre>
</font>
</b>

<?php
# Displays a standard footer; two parameters:
# First a simple headline like: "GETTING HELP:"
# then a list of emails like this:
# "('Tech assist','Frank','frank@foo.net'),('Scient assist','Bent','bent@foo.net')"
standard_foot("GETTING HELP","('Scientific problems','Eric van der Helm','evand@biosustain.dtu.dk'),('Technical problems','Henrik Marcus Geertz-Hansen','hmgh@cbs.dtu.dk')");
?>
