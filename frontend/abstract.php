<?php
# Always include this file
include "cbs_std.php";
# Create a html header, give the title
standard_head("deFUME-1.0 Abstract");
# Create CBS menu. Format is:
# Keyword, Path, Name_of_this_page
# Keyword is the keyword for the menu color/area.
# Name_of_this_page is what this page is called in the hieraki
# Path format is a number of comma separated entries in parenthesis
# showing the path to this page; (services/,'CBS Prediction Servers')
standard_menu("CBSPS","(services/,'CBS Prediction Servers'),(services/deFUME-1.0/,'deFUME')","Abstract");
?>

<!-- START INDHOLD -->

<h1>Paper abstract</h1>
<hr>
<h3>REFERENCE</h3>

<!-- Reference starts here -->

<b>deFUME: Dynamic Exploration of Functional Metagenomic Sequencing Data</b><br>
<i>Eric van der Helm1,*, Henrik Marcus Geertz-Hansen1,2,3, Hans Jasper Genee1, Sailesh Malla1, and Morten O. A. Sommer1,4</i><br>
<b>REFERENCE</b>.
<p>
    <font size="-1">
        <sup>*</sup>to whom correspondence should be addressed, e-mail:
        <a href="mailto:evand@biosustain.dtu.dk">evand@biosustain.dtu.dk</a>
        <p>
            1 Novo Nordisk Foundation Center for Biosustainability, Technical University of Denmark, DK-2870 H√∏rsholm, Denmakr<BR> 2 Center for Biological Sequence Analysis, Department of Systems Biology, , Building 208, Technical University of Denmark, DK-2800 Lyngby, Denmark<BR> 3 Novozymes A/S, Krogsh√∏jvej 36, DK-2880 Bagsv√¶rd, Denrk<BR> 4 Department of Systems Biology, Technical University of Denmark, DK-2800 Lyngby, Denmark</font>
    <br><br><br>

    <!-- Reference ends here -->
<hr>
<h3>ABSTRACT</h3>
<div class="bulk">

    <!-- Abstract starts here -->
    <B>Summary:</B> With the advent of functional genomics, a major chal-lenge is the analysis and interpretation of the ever-increasing se-quencing data. deFUME is an easy-to-use web-based interface for processing and annotation of functional metagenomics sequencing data, tailored to meet the requirements of non-bioinformaticians. The web-server integrates multiple analysis steps into one single work-flow: read assembly, open reading frame prediction and finally anno-tation with BLAST, InterPro and GO classifiers. This provides a fast track from raw sequence to a comprehensive visual data overview that facilitates effortless inspection of gene function, clustering and distribution.
    <BR><B>Availability and implementation:</B> The deFUME webserver is freely available at http://www.cbs.dtu.dk/services/deFUME.

    <!-- Abstract ends here -->

    <hr>
    The electronic version of this article is found here: <a href="notactiveyet">view</a>

</div>

<?php
# Displays a standard footer; two parameters:
# First a simple headline like: "GETTING HELP:"
# then a list of emails like this:
# "('Tech assist','Frank','frank@foo.net'),('Scient assist','Bent','bent@foo.net')"
standard_foot("GETTING HELP","('Scientific problems','Eric van der Helm','evand@biosustain.dtu.dk'),('Technical problems','Henrik Marcus Geertz-Hansen','hmgh@cbs.dtu.dk')");
?>
