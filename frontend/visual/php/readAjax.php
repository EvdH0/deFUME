<?php

//ini_set('error_reporting', E_ALL);
//header('Cache-Control: no-cache, must-revalidate');
//header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
//header('Content-type: application/json');
/**
 * Fetches the JSON file from the server and presents in to the frontend
 * Created by PhpStorm.
 *
 * User: ericvanderhelm
 * Date: 5/28/14
 * Time: 12:31 AM
 */


if (empty($_GET['JSONFilename']))
{
    header('HTTP/1.0 419 JSONFilename not set');
    exit;
}
if ($_GET['JSONFilename']=="undefined" )
{
    header('HTTP/1.0 419 No JSON Filename specified (undefined)');
    exit;


}

if ($_GET['JSONFilename']=="" )
{
    header('HTTP/1.0 419 No JSON Filename specified (=empty)');
    exit;


}



if(!file_exists('../../tmp/'.sanitize($_GET['JSONFilename'],false) .'/'. sanitize('results',false) . '.json')) {
    header('HTTP/1.0 419 JSON file not found: ' . sanitize($_GET['JSONFilename'],false) );
    exit;
} else {


    $input = file_get_contents('../../tmp/'.sanitize($_GET['JSONFilename'],false) .'/'. sanitize('results',false) . '.json', 10000000);
}


$JSON = json_decode($input, true);
foreach ($JSON as $thisContigList => $listname) {
    //  echo $thisContigList;

    foreach ($JSON[$thisContigList] as $thisContig => $contigname) {

        if (array_key_exists("ORF", $JSON[$thisContigList][$thisContig])) {
            foreach ($JSON[$thisContigList][$thisContig]["ORF"] as $thisORF => $thisORFvalue) {

                if (array_key_exists("BLAST", $JSON[$thisContigList][$thisContig]["ORF"][$thisORF] )) { //Check if the ORF has BLAST values
                    foreach ($JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"] as $thisBLAST => $thisBLASTvalue) {

                        if (isset($_GET['filterhypo'])) { //Filter only the hyothetical proteins out if it's set
                            if ((stristr($JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"][$thisBLAST]["h_desc"], "putative uncharacterized protein")) OR (stristr($JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"][$thisBLAST]["h_desc"], "hypothetical")) OR (stristr($JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"][$thisBLAST]["h_desc"], "putative uncharacterized protein"))) {
                                if ($JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"][(max(array_keys($JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"])))]["h_desc"] == "Hypo placeholder") {
                                    $JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"][(max(array_keys($JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"])))]["eval"]++;

                                } else {
                                    $end = sizeof($JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"]) - 1; //Find the end
                                    $JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"][$end + 1] = $JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"][$thisBLAST]; //Copy from the last one
                                    $JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"][$end + 1]["h_desc"] = "Hypo placeholder";
                                    $JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"][$end + 1]["eval"] = 1;

                                }

                                unset($JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"][$thisBLAST]);
                                continue;
                                //


                            }


                        }

                        if (isset($_GET['filtereval'])) {

                            if ($JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"][$thisBLAST]["eval"] > 1e-40){
                                unset($JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"][$thisBLAST]);

                            }


                        }
                    }

                    $JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"] = array_values($JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"]); //Fix the array index numbers
                }

            }
        } else {
            //echo "empty array";
        }


    }


    echo json_encode($JSON); //Output the JSON code


}


//Close here
exit();





/**
 * Function: sanitize
 * Returns a sanitized string, typically for URLs.
 *
 * Parameters:
 *     $string - The string to sanitize.
 *     $force_lowercase - Force the string to lowercase?
 *     $anal - If set to *true*, will remove all non-alphanumeric characters.
 */
function sanitize($string, $force_lowercase = true, $anal = false) {
    $strip = array("~", "`", "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "=", "+", "[", "{", "]",
        "}", "\\", "|", ";", ":", "\"", "'", "&#8216;", "&#8217;", "&#8220;", "&#8221;", "&#8211;", "&#8212;",
        "â€”", "â€“", ",", "<", ".", ">", "/", "?");
    $clean = trim(str_replace($strip, "", strip_tags($string)));
    $clean = preg_replace('/\s+/', "-", $clean);
    $clean = ($anal) ? preg_replace("/[^a-zA-Z0-9]/", "", $clean) : $clean ;

    //TODO: Put in a more stringent filter!

    return ($force_lowercase) ?
        (function_exists('mb_strtolower')) ?
            mb_strtolower($clean, 'UTF-8') :
            strtolower($clean) :
        $clean;
}

?>