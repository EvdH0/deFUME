<?php
/**
 * Class file defines the GenBank feature object
 * Created by PhpStorm.
 * User: evdh
 * Date: 7/8/14
 * Time: 10:40 PM
 */

class GenBankFeature {

    public $geneName;
    public $location;
    public $readName;
    public $readLocation;


    private function validateLocation($_begin,$_end)
    {
        //check if the location input is correct
        if ($_begin < 1)
        {
         $_begin = 1; //Should yield an error

        }

        if ( $_end < 1)
        {

            $_end = 1;
        }
        return array($_begin,$_end);
    }
    public function setCDS($_geneName,$_begin,$_end,$_db_xref,$_translation)
    {
        $this->geneName = $_geneName;
        list($begin, $end) = $this->validateLocation($_begin,$_end);
        $this->location = $this->formatLocation($begin,$end);
        $this->db_xref = $_db_xref;
        $this->translation = $_translation;


    }
    public function setReadSource($_readName,$_begin,$_end)
    {

        $this->readName = $_readName;
        list($begin, $end) = $this->validateLocation($_begin,$_end);

        $this->readLocation = $this->formatLocation($begin,$end);

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

    public function formatLocation($begin,$end)
    {
        if ($begin<$end)
            return "$begin..$end";
        else
            return "complement($end..$begin)";

    }

    public function getFeatures()
    {

        $writeBuffer = "";
        //$writeBuffer .= "FEATURES" . $this->putSpace(12) . "Location/Qualifiers\n\r";

        if (!empty($this->geneName))
        {
        $writeBuffer .= $this->putSpace(5) . "CDS" . $this->putSpace(13) . $this->location . "\n\r";

        //$writeBuffer .= sprintf("%8s %s\n\r",'CDS',$this->location);
        $writeBuffer .= $this->putSpace(21) . '/product="'.$this->geneName.'"' . "\n\r";
        $writeBuffer .= $this->putSpace(21) . '/db_xref="' .$this->db_xref .  '"' . "\n\r";
        $writeBuffer .= $this->putSpace(21) . '/translation="' .$this->translation .  '"' . "\n\r";

        }

        if (!empty($this->readName))
        {
            $writeBuffer .= $this->putSpace(5) . "source" . $this->putSpace(11) . $this->readLocation . "\n\r";

            //$writeBuffer .= sprintf("%8s %s\n\r",'CDS',$this->location);
            $writeBuffer .= $this->putSpace(21) . '/readName="'.$this->readName.'"' . "\n\r";

        }

        return $writeBuffer;
    }

}

