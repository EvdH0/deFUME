<?php
# Always include this file
include "cbs_std.php";
# Create a html header, give the title
standard_head("deFUME-1.0 server");
# Create CBS menu. Format is:
# Keyword, Path, Name_of_this_page
# Keyword is the keyword for the menu color/area.
# Name_of_this_page is what this page is called in the hieraki
# Path format is a number of comma separated entries in parenthesis
# showing the path to this page; (services/,'CBS Prediction Servers')
standard_menu("CBSPS","(services/,'CBS Prediction Servers')","deFUME");
define_blink();
?>

<!-- START INDHOLD -->

<h1>deFUME 1.0 - Dynamic Exploration of Functional Metagenomics Sequencing Data
</h1>

<script>
    function setvalue(f,v) {
        document.getElementById(f).value=v;
    }
    function getvalue(f) {
        return document.getElementById(f).value;
    }
</script>
<!-- Server introduction text starts here -->

<div class="bulk">



    <h1>Instructions</h1>
    <p>deFUME is an easy-to-use web-server for trimming, assembly and functional annotation of Sanger sequencing data derived from functional selection experiments. As input the user simply provides raw Sanger sequencing chromatograms or pre-assembled sequencing projects. Upon submission the web-server processes the information by integrating multiple analysis steps into one single workflow: read trimming, assembly of reads into contigs, open reading frame prediction, BLAST and enrichment with available metadata. As output, deFUME delivers a comprehensive sequence-overview that include functional annotations and sequence statistics. The following section provides instructions to the deFUME web-server.</p>
    <h2>Table of contents</h2>
    <BLOCKQUOTE>
<pre>
<h3>
   <a href="#input">Input options</a>
                   <a href="#chromatogram">Input options for raw chromatogram reads</a>
                   <a href="#assembledcontig">Input options for pre-assembled projects</a>
           <a href="#recommend">Recommended input options</a>
                   <a href="#primer">Specification of sequencing primer directionality</a>
                   <a href="#email">Email for InterPro queries</a>
           <a href="#advanced">Advanced input options</a>
                   <a href="#vector">Trimming of cloning vector sequences</a>
                   <a href="#basecalling">Base calling error rate</a>

   <a href="#output">The Visual Output Page</a>
           <a href="#sampledata">Example output page</a>
           <a href="#general">General overview</a>
           <a href="#contig">Expand a contig</a>
           <a href="#orf">Expand an ORF</a>
           <a href="#interpro">InterPro</a>
           <a href="#assocgo">Associated GO Terms</a>
      <a href="#explore">Exploring your data</a>
           <a href="#filter">left menu box</a>
           <a href="#GO">GO annotation</a>
           <a href="#sorting">Sorting</a>
           <a href="#filtering">Filtering</a>
      <a href="#export">Exporting your data</a>

   <a href="#submit">Submit the job</a>
   <a href="#browser">Browser compatibility</a>
   <a href="#restrictions">Restrictions</a>

</h3>

</pre>
    </BLOCKQUOTE>




    <h2 id="input">Input</h2>
    <img src="http://www.dnacoil.com/wp-content/uploads/2015/02/screenshot_inputlanding.png"><br>
    As input, you can either choose to upload raw chromatograms in ab1 file format (.ab1), or provide pre-assembled contigs as plain sequence in Fasta format. In the latter case, deFUME will skip the chromatogram trimming and assembly process and the submitted sequence will directly be subject to functional annotation by Blast and InterPro. </p>

    <h3 id="chromatogram">Input options for raw chromatogram reads</h3>
    <p>Chromatograms (.ab1 format) must be compressed into an archive (Zip or tar) file. From the deFUME interface, select your zip or tar file from your local disk and upload. The zip file may contain multiple ab1 files. In order to compress multiple chromatogram (.ab1) files in one compressed archive you can use the following command: <i>tar -cvzf YourCompressedFiles.tar.gz *.ab1</i></p>

    <h3 id="assembledcontig">Input options for pre-assembled projects</h3>
    <img src="http://www.dnacoil.com/wp-content/uploads/2015/02/screenshot_preass.png">
    <p>An alternative input to raw sequencing data is pre-assembled sequence, and the user simply loads or copy-paste his/hers sequence in fast format in the specified input window. When choosing this option, deFUME will skip the phred assemby step. This option is useful for a variety of functional annotation analysis and expands the input to other sequencing techniques than Sanger sequencing such as next generation sequencing (NGS).</p>

    <h2 id="recommend">Recommended input options</h2>
    <h3 id="primer">Specification of sequencing primer directionality</h3>
    <p>As a useful option, deFUME allows the user to specify the directionality of the primers used for Sanger sequencing. By specifying an identifier that matches a part of the name of chromatograms generated with a forward this will be visible in the output. Example: if a users chromatograms are named FORW_01.ab1, FORW_02.ab1, FORW_03.ab1,‚Äö√Ñ¬∂ REV_E01.ab1, REV_02.b1, REV_03.ab1,‚Äö√Ñ¬∂, etc. then specifying a ‚Äö√Ñ√∫Forward primer identifier‚Äö√Ñ√π as ‚Äö√Ñ√∫FORW_‚Äö√Ñ√π informs deFUME that all chromatograms with this identifier as part of their name is a chromatogram generated with a forward primer. This will generate a more intuitive visualization of the output. If the user inputs an identifier that does not match the chromatogram name or leaves the field empty, deFUME will randomly choose the directionality in the output. <br><img src="http://www.dnacoil.com/wp-content/uploads/2015/02/primer_box.png"><br> In case you have a folder with reads from a forward primer and another folder containing ab1 files from the reverse primer. You can run the following command (on a Mac or Unix machine) in the directory containing the forward primer reads, it will add the postfix _FOR to all your .ab1 files.
        <i>for file in *.ab1; do mv $file $(basename $file .ab1)_FOR.ab1; done</i>
        The same can me done in the directory containing all the reverse reads, adding the postfix _REV to all your .ab1 files:
        <i>for file in *.ab1; do mv $file $(basename $file .ab1)_REV.ab1; done</i>
        On a Windows system the following commands will do the job for the forward reads:
        <i>for /f "tokens=*"%a in ('dir *.ab1 /b') do @ren "%a" "FORWARD_%a"</i> and for the reverse reads:
        <i>for /f "tokens=*"%a in ('dir *.ab1 /b') do @ren "%a" "REVERSE_%a"</i>


    </p>

    <h3 id="email">Email for InterPro queries</h3>
    <p>Assembled open reading frames are further annotated using the InterPro server. In order to use this service at EMBL-EBI a valid email address is required.</p>

    <h2 id="advanced">Advanced input options</h2>

    <h3 id="vector">Trimming of cloning vector sequences</h3>
    <img src="http://www.dnacoil.com/wp-content/uploads/2015/02/cloningvector.png">
    <p>For sequencing data generated from a cloning vector, loading vector sequence in this field (as Fasta format) enables deFUME to remove vector sequence from the user sequencing data. This is performed prior to assembly and improves the accuracy of the assembly process.</p>


    <h4 id="basecalling">Base calling error rate</h4>

    <p>Accuracy of base calls expressed as error probability. The standard probability is 0.01, which corresponds to a base call probability of 99% (or 1 error in 100 bases). <a href="http://en.wikipedia.org/wiki/Phred_quality_score">Read more in the Wiki article</a> or <a href="http://www.ncbi.nlm.nih.gov/pubmed/9521921">the phred accuracy assessment</a> and <a href="http://www.ncbi.nlm.nih.gov/pubmed/9521922">phred  error probabilities</a>.</p>


    <h2 id="output">The Visual Output Page </h2>

    <p>After submitting the job the output page will load when the processing is completed. While processing, it is possible to type in an email address and get notified when the job is complete. </p>

    <p> The deFUME output page is a table containing all assembled contigs per row and includes a visual and interactive overview of each assembled contig, specifying chromatogram areas, predicted open reading frames, Blast results and InterPro hits.
    </p>

    <h3 id="sampledata">Example output page</h3>
    <p> Note that a small sample set is prepared containing a few assembled contigs that enables the user to play around with the different filter capabilities of deFUME. In order to directly view the results of this sample set click <a href="http://www.cbs.dtu.dk//services/deFUME/tmp/TESTSET/output.html">here</a>. </p>

    <h3 id="general">General overview</h3>

    <p><img src="http://www.dnacoil.com/wp-content/uploads/2014/12/generaloverview1.png" alt="Overview" title="" />
        <BR>Each contig is represented by a thick green line at the top, followed by the Open Read Frames (ORFs) found by MetaGeneMark <img src="http://www.dnacoil.com/wp-content/uploads/2014/12/ORFmarker-e1418639237308.png" alt="" title="" />. The BlastP hits of each ORF are represented by red lines (5 individual hits are represented by 1 line) <img src="http://www.dnacoil.com/wp-content/uploads/2014/12/blastArrow-e1418639333583.png" alt="" title="" />. In parallel the ORFS are analyzed by InterPro and the individual hits are visualized using a yellow line<img src="http://www.dnacoil.com/wp-content/uploads/2014/12/interPro-arrow-e1418639407781.png" alt="" title="" />.
        The reads (extracted from the ab1 files) that make up a contig are represented by a green arrow <img src="http://www.dnacoil.com/wp-content/uploads/2014/12/readArrow-e1418639078205.png" alt="" title="" /></p>

    <h3 id="contig">Expand a contig</h3>

    <p><img src="http://www.dnacoil.com/wp-content/uploads/2014/12/expandContig.png" alt="" title="" width="600" height="91"/>
        <BR>By clicking on the + sign, the contig will expand and show the BlastP hit with the highest E-value as a representative for the ORF. </p>

    <h3 id="orf">Expand an ORF</h3>

    <p><img src="http://www.dnacoil.com/wp-content/uploads/2014/12/expandORF1.png" alt="" title="" />
        <BR> By clicking on the + sign of the ORF a new table will open showing the 25 most significant BLAST hits. </p>

    <p><img src="http://www.dnacoil.com/wp-content/uploads/2014/12/sortBLAST.png" alt="" title="" />
        <BR>On the BlastP level more information is shown for the individual BlastP hits.
    <ul>
        <li>E-value: The e value are calculated by the BLASTP algorithm. A small value represent a more significant hit.</li>
        <li>Coverage %: This value indicates how much percent of the amino acids in the BlastP database are covered by this particular Open Reading Frame.</li>
        <li>Hit id [%]: The sequence identity as output by BlastP</li>
        <li>Hit length: The total length of the ORF in amino acids</li></p>
    </ul>
    <h3 id="interpro">InterPro</h3>

    <p><img src="http://www.dnacoil.com/wp-content/uploads/2014/12/interpro.png" alt="" title="" />
        <BR> The Open Reading Frames are enriched with InterPro data shown as yellow lines. To inspect the detailed InterPro results, click on the link "InterPro" in the designated column to open a popup with the page as rendered by the InterPro server. In case the Open Reading Frame didn't came back with an InterPro hit a "-" is shown.</p>

    <h3 id="assocgo">Associated GO Terms</h3>

    <p><img src="http://www.dnacoil.com/wp-content/uploads/2014/12/GOtermsAssoc.png" alt="" title="" />
        <BR>     Since InterPro can associate multiple GO terms these are reported in the "Associated GO terms" column. By hovering over the corresponding cell all the associate GO terms are visible. To investigate more in-depth the GO annotations click on the "InterPro" link. In case there are no InterPro hits for this ORF, or the InterPro data do not contain any GO annotations a "-" is shown.
        The GO terms here are used to retrieve the top-level GO term as shown in the menu box to the right of the main results table.</p>

    <h2 id="explore">Exploring your data</h2>

    <h3 id="filter">Left menu box</h3>

    <p><img src="http://www.dnacoil.com/wp-content/uploads/2014/12/upAn.png" alt="RightMenu" title="" /></p>
    <BR>
    <p>The menu on the right side contains additional filtering options. The following visual cues can be turned on and off to easy the browse-ability
    <ul>
        <li>Red BlastP lines</li>
        <li>Yellow Interpro lines</li>
        <li>Green AB1 read arrows</li>
        <li>Removal of all the hits that are annotated with "hypothetical" or "unknown"</li>
    </ul>
    </p>

    <p>Furthermore, the E-value cutoff can be adjust interactively so that only hits with an E-value below this cutoff are shown</p>

    <h3 id="GO">GO annotation</h3>

    <p><img src="http://www.dnacoil.com/wp-content/uploads/2014/12/downAN.png" alt="" title="" />
        <BR>An important feature of deFUME is the interactive browsing of the GO terms. The GO annotations is composed of three main categories: "Molecular Function", "Biological Process" and "Cellular Component". Each ORF is annotated using InterPro with 0 or more GO terms. Of these GO terms the top-level GO term is extracted from the GO hierarchy and shown as a histogram in this menu.
        <BR> <img src="http://www.dnacoil.com/wp-content/uploads/2014/12/hiog.png" alt="" title="" />
        <BR>By clicking on one of the bars in the bar plot, the deFUME tables adjust to visualize only contigs that are annotated with the selected GO term. This will update both the interactive table and the GO term chart.</p>

    <p>In order to inspect the individual GO terms associated with an ORF you can click over the cell containing the 'Associate GO Terms' on ORF level.
        <BR><img src="http://www.dnacoil.com/wp-content/uploads/2014/12/selectedGO.png" alt="" title="" />
        <BR>To reset the filtering on a particular GO term just click on the current GO term filter that is active.</p>

    <h3 id="sorting">Sorting</h3>

    <p><img src="http://www.dnacoil.com/wp-content/uploads/2014/12/sort-e1418639547478.png" alt="" title="" />
        <BR>By clicking on the small up and down arrows a deFUME list can be sorted ascending or descending. These features are also available on the ORF and BlastP level.</p>

    <h3 id="filtering">Filtering</h3>

    <p><img src="http://www.dnacoil.com/wp-content/uploads/2014/12/interactivesearch-e1418639614869.png" alt="" title="" />
        <BR>By typing in a (part) of a particular read name or contig name the deFUME tables will automatically update to match the search criteria. By typing "cont" only contigs that are not composed of single reads are found. </p>

    <h2 id="export">Exporting your data</h2>

    <h3>Right menu box</h3>

    <p><img src="http://www.dnacoil.com/wp-content/uploads/2014/12/upAn.png" alt="RightMenu" title="" />
        <BR>The total set of assembled reads can be exported in three formats: <ul>
        <li>GenBank (a zip file containing the individual contigs as .gb files)</li>
        <li>        FASTA </li>
        <li>        CSV</li></uL>
    This allows for further manipulation and use in sequence analysis programs like Vector NTI, CLC, etc.</p>

    <h3>On Contig and ORF level</h3>

    <p><img src="http://www.dnacoil.com/wp-content/uploads/2014/12/exportGBFASTA.png" alt="" title="" />
        <BR>  By clicking on one of the export buttons the current individual contig or BlastP hit will be exported to a Genbank or FASTA file.</p>

    <h2 id="submit">Submit the job</h2>

    <p>Click on the "Submit" button. The status of your job (either 'queued' or 'running') will be displayed and constantly updated until it terminates and the server output appears in the browser window.
        At any time during the wait you may enter your e-mail address and simply leave the window. Your job will continue; you will be notified via e-mail when it has completed. The e-mail message will contain the URL under which the results are stored; they will remain on the server for 24 hours for you to collect</p>
    <h2 id="browser">Browser compatibility</h2>
    <p>deFUME is compatible with the major browsers available, however be sure to use the latest version. deFUME was successfully tested with Chrome 39.0.2171.95, Firefox 4.0.5, Safari Version 6.1.3, Internet Explorer 11.0.15. deFUME will for example not render properly on Internet Explorer 10.</p>
    <h2 id="restrictions">Restrictions</h2>

    <p>Please read the <a href="http://www.cbs.dtu.dk/cgi-bin/nph-access">CBS access policies</a> for information about limitations on the daily number of submissions.</p>

</div>
<?php
# Displays a standard footer; two parameters:
# First a simple headline like: "GETTING HELP:"
# then a list of emails like this:
# "('Tech assist','Frank','frank@foo.net'),('Scient assist','Bent','bent@foo.net')"
standard_foot("GETTING HELP","('Scientific problems','Eric van der Helm','evand@biosustain.dtu.dk'),('Technical problems','Henrik Marcus Geertz-Hansen','hmgh@cbs.dtu.dk')");
?>


