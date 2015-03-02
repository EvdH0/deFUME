<?php
/**
 * Class file defines the GenBank object
 * Created by PhpStorm.
 *
 * User: evdh
 * Date: 7/7/14
 * Time: 11:34 PM
 * As defined in http://www.insdc.org/files/feature_table.html
 */


include "GenBankFeature.php";

class GenBank {

    //TODO: remove header and origin class, they are not needed


    public $header;
    public $origin;
    public $features;

    private $baseLength;
    private $locusName;
    private $sourceName;
    private $organism;
    private $sequence;


    public function __construct()
    {
        //echo 'The class "', __CLASS__, '" was initiated!<br />';


        //$this->origin = new GenBankOrigin();
        //$this->feature = new GenBankFeature();
        //$this->features[] = new GenBankFeature();

        $this->features = array();
    }

    public function setLocus($_locusName,$_bp)
    {
        $this->locusName = $_locusName;
        $this->baseLength = $_bp;
    }
    public function setSource($_sourceName)
    {
        $this->sourceName = $_sourceName;
    }

    public  function setOrganism ($_organism)
    {
        $this->organism = $_organism;
    }
    public function getLocus()
    {
        /** LOCUS       Sc_16        7000 bp    DNA*/

        //TODO: Validate the locus name
        //return "LOCUS" .  $this->putSpace(7) . $this->locusName . "   " . $this->baseLength . "bp   " . "DNA\n\r";
        return sprintf ("%-12s%-15s%13s %s%4s%-8s%-8s %3s %-s\n",
            'LOCUS', $this->locusName, $this->baseLength,
            'bp','','', 'linear', 'UNK', '');
    }

    private function putSpace($amount)
    {
        $writeBuffer = "";
        for ($i=0;$i<$amount;$i++)
        {
            //$writeBuffer .= '&nbsp;';
            $writeBuffer .= ' ';


        }

        return $writeBuffer;
    }


    public function getSource()
    {

        /** SOURCE      baker's yeast. */
        if (isSet($this->sourceName))
            return "SOURCE      " . $this->sourceName . "\n\r";

        //return sprintf("SOURCE %*s \n\r",20,$this->sourceName);

    }

    public function getOrganism()
    {
        if (isSet($this->organism))
            return "  ORGANISM  " . $this->organism . "\n\r";
    }



    public function setCDS($_gene,$_begin,$_end,$_db_xref,$_translation)
    {
        $feature = new GenBankFeature();
        $feature->setCDS($_gene,$_begin,$_end,$_db_xref,$_translation);
        array_push($this->features,$feature); //Pushes the new feature in the features stack.
    }

    public function setReadSource($_readName,$_begin,$_end)
    {
        $feature = new GenBankFeature();

        $feature->setReadSource($_readName,$_begin,$_end);
        array_push($this->features,$feature); //Pushes the new feature in the features stack.
    }





    public function validateDNA($_sequence)
    {
        //Validation functions
        return $_sequence;
    }

    public function setOrigin($_sequence)
    {

        $this->sequence = $this->validateDNA($_sequence);
        $this->baseLength = strlen($_sequence);
    }

    public function getOrigin()
    {

        return "ORIGIN\r\n" . $this->formatSequence();
    }
    public function formatSequence()
    {

        //chuck up 60
        //chuck up 10

        $writeBuffer = "";

        $numLines = ceil(strlen($this->sequence)/60);
        for ($x=0; $x<$numLines; $x++) {
            $currentLine = substr($this->sequence,$x*60,60);


            $chunks = ceil(strlen($currentLine) / 10);

            $writeBuffer .= sprintf('%9d',$x*60+1);
            for ($j=0;$j<=$chunks;$j++)
            {
                $writeBuffer .= " " . substr($currentLine,$j*10,10);
            }
            $writeBuffer .= "\r\n";

        }

        return $writeBuffer;
    }


    public function getFeatureHeader()
    {
        return  "FEATURES" . $this->putSpace(13) . "Location/Qualifiers\n\r";
    }

    public function getTotal()
    {
        $writeBuffer = "";
        $writeBuffer .= $this->getLocus();
        $writeBuffer .= $this->getSource();
        $writeBuffer .= $this->getOrganism();

        $writeBuffer .= $this->getFeatureHeader(); //Returns the first row to start the feature part
        foreach ($this->features as $feature){ //Loop through the features stack.
            $writeBuffer .= $feature->getFeatures();
        }
        $writeBuffer .= $this->getOrigin(); //Returns the DNA Origin section




        return $writeBuffer;

    }


}



?>
