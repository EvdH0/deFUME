<?php
/**
 * Takes the JSON file and outputs a CSV file with the most important metrics
 *
 * Created by PhpStorm.
 * User: ericvanderhelm
 * Date: 8/7/14
 * Time: 11:02 AM
 */

///// This requires two directories, tmp and tmp2 that are writable by the webinstance.

//$fp = fopen('tmp/file.csv', 'w');
header("Content-Type:text/plain");
header("Content-Disposition:attachment;filename=" . sanitize($_GET['JSONFilename']) . ".csv");

$fp = fopen('php://output', 'w');

fputcsv($fp,array('Contig name','#reads','ORF','ORF start','ORF end','BLAST Sequence Identity','BLAST e value','BLAST accession','BLAST Description')); //define the header
if (!isSet($_GET['JSONFilename'])) {

    die('JSONFilename must be supplied');
}

$input = file_get_contents('../../tmp/'.sanitize($_GET['JSONFilename'],false) .'/'. sanitize('results',false) . '.json', 10000000);




$return = ""; //Initialize the return statement

$JSON = json_decode($input, true);
foreach ($JSON as $thisContigList => $listname) {
    //  echo $thisContigList;

    foreach ($JSON[$thisContigList] as $thisContig => $contigname) {


            //echo "This contig: " . $JSON[$thisContigList][$thisContig]['contig']. "\n\r";
            // echo "This Get: " . $_GET['contig'] . "\n\r";


        if (array_key_exists("reads", $JSON[$thisContigList][$thisContig])) {
            $reads = count($JSON[$thisContigList][$thisContig]["reads"]);
        }
        else{
            $reads = 1;
        }

                if (array_key_exists("ORF", $JSON[$thisContigList][$thisContig])) {
                    foreach ($JSON[$thisContigList][$thisContig]["ORF"] as $thisORF => $thisORFvalue) {

                        if (array_key_exists("BLAST", $JSON[$thisContigList][$thisContig]["ORF"][$thisORF])) {
                        foreach ($JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"] as $thisBLAST => $thisBLASTvalue) {
                            $array =  array(
                                $JSON[$thisContigList][$thisContig]['contig'],
                                $reads,
                                $JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["name"],
                                $JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["start"],
                                $JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["end"],
                                $JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"][$thisBLAST]["perc"],
                                $JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"][$thisBLAST]["eval"],
                                $JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"][$thisBLAST]["h_acc"],
                                $JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"][$thisBLAST]["h_desc"]);
                            fputcsv($fp,$array);
                           // print_r($array);


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
fclose($fp);


/*

    header("Content-Type:text/plain");
    header("Content-Disposition:attachment;filename=" . $JSON[$thisContigList][$thisContig]['contig'] . ".fasta");

    echo $return;
*/


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