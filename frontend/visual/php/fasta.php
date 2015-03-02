<?php
/**
 * Created by PhpStorm.
 * User: ericvanderhelm
 * Date: 8/7/14
 * Time: 11:02 AM
 */

///// This requires two directories, tmp and tmp2 that are writable by the webinstance.


if (!isSet($_GET['JSONFilename'])) {

    die('JSONFilename must be supplied');
}

$input = file_get_contents('../../tmp/'.sanitize($_GET['JSONFilename'],false) .'/'. sanitize('results',false) . '.json', 10000000);


//Decide the method based on the parameters given
if (empty($_GET['contig'])) {
    $download = "total";
} else {
    $download = "single";
}

$return = ""; //Initialize the return statement

$JSON = json_decode($input, true);
foreach ($JSON as $thisContigList => $listname) {
    //  echo $thisContigList;

    foreach ($JSON[$thisContigList] as $thisContig => $contigname) {

        if ($download == "total" OR strcmp($JSON[$thisContigList][$thisContig]['contig'], $_GET['contig']) == 0) //Find the contig in the contig list

        {
            //echo "This contig: " . $JSON[$thisContigList][$thisContig]['contig']. "\n\r";
            // echo "This Get: " . $_GET['contig'] . "\n\r";

            if (empty($_GET['blast'])) {
                $return .= ">" . $JSON[$thisContigList][$thisContig]['contig'] . "\n\r";
                $return .= $JSON[$thisContigList][$thisContig]['dna_seq'] . "\n\r";
            }

            if (!empty($_GET['blast'])) {

                if (array_key_exists("ORF", $JSON[$thisContigList][$thisContig])) {
                    foreach ($JSON[$thisContigList][$thisContig]["ORF"] as $thisORF => $thisORFvalue) {

                        if (array_key_exists("BLAST", $JSON[$thisContigList][$thisContig]["ORF"][$thisORF])) {
                        foreach ($JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"] as $thisBLAST => $thisBLASTvalue) {

                            if (strcmp($JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"][$thisBLAST]["h_acc"], $_GET['blast'])== 0) { //Find the acc  code in the JSON Blast stack
                                $return .= ">" . $JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"][$thisBLAST]["h_acc"] . "\r\n";
                                $return .= $JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"][$thisBLAST]["q_seq"] . "\r\n";
                            }

                        }
                        }



                    }
                }
            }

            /*

                        if (array_key_exists("ORF", $JSON[$thisContigList][$thisContig])) {
                            foreach ($JSON[$thisContigList][$thisContig]["ORF"] as $thisORF => $thisORFvalue) {


                                foreach ($JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"] as $thisBLAST => $thisBLASTvalue) {
                                    $obj->setCDS($JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"][$thisBLAST]["h_desc"],
                                        $JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"][$thisBLAST]["q_start"],
                                        $JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"][$thisBLAST]["q_end"],
                                        $JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"][$thisBLAST]["h_id"],
                                        $JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"][$thisBLAST]["q_seq"]
                                    );
                                    break; //Only take the first one

                                }


                            }
                        }
            */


        }


    }


}


if ($download == "single") {


    header("Content-Type:text/plain");
    header("Content-Disposition:attachment;filename=" . $JSON[$thisContigList][$thisContig]['contig'] . ".fasta");

    echo $return;
}
if ($download == "total") {
    header("Content-Type:text/plain");
    header("Content-Disposition:attachment;filename=" . sanitize($_GET['JSONFilename']) . ".fasta");

    echo $return;
}

function sanitize($string, $force_lowercase = true, $anal = false)
{
    $strip = array("~", "`", "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "=", "+", "[", "{", "]",
        "}", "\\", "|", ";", ":", "\"", "'", "&#8216;", "&#8217;", "&#8220;", "&#8221;", "&#8211;", "&#8212;",
        "â€”", "â€“", ",", "<", ".", ">", "/", "?");
    $clean = trim(str_replace($strip, "", strip_tags($string)));
    $clean = preg_replace('/\s+/', "-", $clean);
    $clean = ($anal) ? preg_replace("/[^a-zA-Z0-9]/", "", $clean) : $clean;

    //TODO: Put in a more stringent filter!

    return ($force_lowercase) ?
        (function_exists('mb_strtolower')) ?
            mb_strtolower($clean, 'UTF-8') :
            strtolower($clean) :
        $clean;
}