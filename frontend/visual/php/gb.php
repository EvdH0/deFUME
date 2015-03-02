<?php
/**
 * Takes the JSON file and export either the selected contig as Genbank or the whole dataset as a Genbank wrapped in a zip
 * Created by PhpStorm.
 * User: ericvanderhelm
 * Date: 8/7/14
 * Time: 11:02 AM
 */

///// This requires two directories, tmp and tmp2 that are writable by the webinstance.

include "GenBank.class.php";


if (!isSet($_GET['JSONFilename'])) {

    die('JSONFilename must be supplied');
}

$input = file_get_contents('../../tmp/'.sanitize($_GET['JSONFilename'],false) .'/'. sanitize('results',false) . '.json', 10000000);

@mkdir('../../tmp/'.sanitize($_GET['JSONFilename'],false) .'/' . 'tmp', 0775);
@mkdir('../../tmp/'.sanitize($_GET['JSONFilename'],false) .'/' . 'tmp2', 0775);

$TMPDIR1 = '../../tmp/'.sanitize($_GET['JSONFilename'],false) .'/' . 'tmp' . '/';
$TMPDIR2 = '../../tmp/'.sanitize($_GET['JSONFilename'],false) .'/' . 'tmp2' . '/';

//Decide the method based on the parameters given
if (empty($_GET['contig'])) {
    $download = "zip";
} else {
    $download = "single";
}


$JSON = json_decode($input, true);
foreach ($JSON as $thisContigList => $listname) {
    //  echo $thisContigList;

    foreach ($JSON[$thisContigList] as $thisContig => $contigname) {

        if ($download == "zip" OR strcmp($JSON[$thisContigList][$thisContig]['contig'], $_GET['contig']) == 0) //Find the contig in the contig list

        {
            //echo "This contig: " . $JSON[$thisContigList][$thisContig]['contig']. "\n\r";
            // echo "This Get: " . $_GET['contig'] . "\n\r";
            $obj = new GenBank;

            $obj->setLocus($JSON[$thisContigList][$thisContig]['contig'], strlen($JSON[$thisContigList][$thisContig]['dna_seq']));
            $obj->setSource("Insilico"); //Latin name in CLC
            $obj->setOrganism("UNK"); //SET OTHERWISE CLC CHOKES!
            $obj->setOrigin($JSON[$thisContigList][$thisContig]['dna_seq']);


            if (array_key_exists("reads", $JSON[$thisContigList][$thisContig])) {
                foreach ($JSON[$thisContigList][$thisContig]["reads"] as $thisRead => $thisReadvalue) {
                    // echo "The real value: " . $JSON[$thisContigList][$thisContig]["reads"][$thisRead]["end"]. "\n\r";
                    if ($JSON[$thisContigList][$thisContig]["reads"][$thisRead]["direction"] == 1) {
                        $obj->setReadSource($JSON[$thisContigList][$thisContig]["reads"][$thisRead]["name"], $JSON[$thisContigList][$thisContig]["reads"][$thisRead]["start"], $JSON[$thisContigList][$thisContig]["reads"][$thisRead]["end"]);
                    } else {
                        $obj->setReadSource($JSON[$thisContigList][$thisContig]["reads"][$thisRead]["name"], $JSON[$thisContigList][$thisContig]["reads"][$thisRead]["end"], $JSON[$thisContigList][$thisContig]["reads"][$thisRead]["start"]);

                    }
                }
            }

            if (array_key_exists("ORF", $JSON[$thisContigList][$thisContig])) {
                foreach ($JSON[$thisContigList][$thisContig]["ORF"] as $thisORF => $thisORFvalue) {

                    if (array_key_exists("BLAST", $JSON[$thisContigList][$thisContig]["ORF"][$thisORF])) {
                        foreach ($JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"] as $thisBLAST => $thisBLASTvalue) {
                            $obj->setCDS($JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"][$thisBLAST]["h_desc"],
                                $JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["start"],
                                $JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["end"],
                                $JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"][$thisBLAST]["h_id"],
                                $JSON[$thisContigList][$thisContig]["ORF"][$thisORF]["BLAST"][$thisBLAST]["q_seq"]
                            );
                            break;

                        }
                    }



                }
            }


        }

        if ($download == "zip") {
            $test = $obj->getTotal();

            $File = $TMPDIR1 . $JSON[$thisContigList][$thisContig]['contig'] . ".gbk";
            $Handle = fopen($File, 'w');

            fwrite($Handle, $obj->getTotal());
            fclose($Handle);
        }

    }


}


if ($download == "single") {
    $test = $obj->getTotal();

    header("Content-Type:text/plain");
    header("Content-Disposition:attachment;filename=" . $JSON[$thisContigList][$thisContig]['contig'] . ".gbk");

    echo $test;
}
if ($download == "zip") {
    $zipfilename =sanitize($_GET['JSONFilename'],false) . '-' . date("y-m-d") . '.zip';
    $zipabsolute = $TMPDIR2 . $zipfilename;

    $zip = new ZipArchive();
    if ($zip->open($zipabsolute, ZipArchive::CREATE)!==TRUE) {
        echo "error opening zip archive ";
    }
    //echo "opning:" . $zipabsolute;




    $files = glob($TMPDIR1. '*'); // get all file names

    foreach ($files as $file) { // iterate files

        $zip->addFile($file,basename($file, ".gbk") . ".gbk"); //Add the file using full path and then put it in the archive as only the file name. So no dir hierachry
        //unlink($file); // delete file


    }
    //echo $zip->status;
    //echo "numfiles: " . $zip->numFiles . "\n";
    //echo "Packing:";
    $zip->close();
    //echo $zip->status;

    foreach ($files as $file) { // iterate files


        unlink($file); // delete file


    }
    header('Content-Type: application/zip');
    header('Content-Disposition: attachment; filename=' . $zipfilename);
    header('Pragma: no-cache');
    readfile($zipabsolute);
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