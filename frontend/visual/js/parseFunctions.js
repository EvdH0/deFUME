/**
 * The javascript parse functions that read in the JSON file from the server and process this file
 * Created by ericvanderhelm on 6/30/14.
 */


//Extra functions to manipulate arrays etc.

function onlyUnique(value, index, self) {
    return self.indexOf(value) === index;
}

function uniqueFrequency(thisArray)
{
    var counts = {};

    for( var thisIndex in thisArray)
    {
        var key = thisArray[thisIndex];
        counts[key] = (counts[key])? counts[key] + 1 : 1 ;

    }
    return counts;

}


/////////


/// Find the hypothetical BLAST hits
function filterHypo(element)
{
    if  ( (element.h_desc.indexOf("hypothetical protein") > -1) || (element.h_desc.indexOf("hypothetical") > -1) || (element.h_desc.indexOf("putative uncharacterized protein") > -1))

    {


        //console.log("found a hypo")

    }
    else
    {
        return element;
    }

}



/// Find GO terms
function filterGO(category,parent)
{
    return function(element){
        //console.log('filter Called' +category+ parent);
        if (testObject(element.GO)) { //Does this ORF has a GO child?
            for (var thisGO in element.GO) { //Go though each individual GO term
                //console.log("this GO: " +thisGO)
                for (var thisTopParent in element.GO[thisGO].top_parent){ //Go through each indiviudal top_parent of the annotated GO term
                    //console.log(element.GO[thisGO].top_parent[thisTopParent].name);
                    if (element.GO[thisGO].top_parent[thisTopParent].name.indexOf(parent) > -1)
                    {
                        return element; //it contains a ORF with topparents binding
                    }
                }
            }
        }
    }


}


/// Filter on a certain E-value cutoff
function filterEval(element)
{


    // console.log(Math.pow(10,setEvalRange))
    if  (Number(element.eval).toPrecision(2) > Math.pow(10,setEvalRange)) //The setEvalRange is a on a liniear scale depicting the exponent of the log eval scale, so need to pow 10

    {

        //console.log("found a big one" +Number(element.eval).toPrecision(2) )

    }
    else
    {
        return element;
    }

}


/// Main function to prepare the JSON file into a jqGrid readable version
function prepareJSON() {

    TopParents = [];
    TopParents.MF = [];
    TopParents.BP = [];
    TopParents.CC = [];

    try {
        document.getElementById('setRemoveHypo').checked = (typeof document.getElementById('setRemoveHypo').checked !== 'undefined') ? document.getElementById('setRemoveHypo').checked : false; //If not passed set isDash to false
        setRemoveHypo = document.getElementById('setRemoveHypo').checked;
    }
    catch (e) {

        var setRemoveHypo = false; //needs to be false

    }



    try {
        setEvalRange  = (typeof document.getElementById('setEvalRange').value !== 'undefined') ? document.getElementById('setEvalRange').value : -1; //If not passed set isDash to false
        setRemoveEval = true;
        document.getElementById("currentEval").innerHTML = setEvalRange;

    }
    catch (e) {
        console.log("YO eval catch", e);
        var setRemoveEval = true; //needs to be false
        setEvalRange = -1;
    }




    try {


        if (!document.getElementById('setGO').getAttribute("category"))
        {
            console.log("The ! test says it is indeed NOT present");
           setGOFilter = false;
            console.log("Setting setGOFilter to FALSE with: " + setGOCategory + " " + setGOParent);
        }
        else
        {
            console.log("The ! test says it IS present!");
            setGOCategory = document.getElementById('setGO').getAttribute("category");
            setGOParent = document.getElementById('setGO').getAttribute("parent");
            setGOFilter = true;
            console.log("Setting setGOFilter to TRUE with: " + setGOCategory + " " + setGOParent);

        }






    }
    catch (e) {

        var setGOFilter = false; //needs to be false
        setGO = false;
    }




    var idGen = 0;
   var setLengthWarning = false;
    var maxContigLength = 0;

    //alert("Going into prep, size of obj is : " + roughSizeOfObject(obj));

    for (var thisContig in obj.Contig) {

        var readCounter = 0;
        var readBuffer = "<BR><BR><BR>"; //Hacky way of making the readrow start with the green read arrows, in the CSS its defined every BR is 10
        for (var thisRead in obj.Contig[thisContig].reads) {
            readCounter = readCounter + 1;
            readBuffer = readBuffer + obj.Contig[thisContig].reads[thisRead].name + '<BR>';
            //Adding up the total entity counter
            totalEntity = totalEntity + 1;
            assembledReads = assembledReads + 1;

        }

        //150 takes about 13 reads ~12px per read
        //min size 150


        //Check the size of the contigs
        if (obj.Contig[thisContig].length > 3000)
        {
            setLengthWarning = true;
            if (maxContigLength < obj.Contig[thisContig].length)
            {
                maxContigLength = obj.Contig[thisContig].length;
            }


        }


        obj.Contig[thisContig].genbank = '<a href="'+ SERVERPREFIX +'php/gb.php?JSONFilename=' + currentJSONFilename + '&contig=' + obj.Contig[thisContig].contig+ '">GB</a><BR>' + '<a href="'  + SERVERPREFIX +    'php/fasta.php?JSONFilename=' + currentJSONFilename + '&contig=' + obj.Contig[thisContig].contig+ '">FASTA</a>'    ;
        var canvasheight = (readCounter < 13) ? 150 : (readCounter - 13) * 12 + 150;

        //3000 bp can fit in a 900px screen -> so make the with responsive
        var thisCanvasWidth =  obj.Contig[thisContig].length * 0.3;

        checkedNew = obj.Contig[thisContig].contig.split('.').join("");
        obj.Contig[thisContig].canvas = '<canvas id="canvas' + checkedNew + '" width="'+thisCanvasWidth+'" height="' + canvasheight + '"></canvas>';
        obj.Contig[thisContig].id = checkedNew; //ID is generated without the dots in, JS doenst like that


        if (readCounter == 0) {
            //Meaning an read and not an assambled contig
            totalEntity = totalEntity + 1;
        }

        obj.Contig[thisContig].readrow = readBuffer;



        if (setGOFilter== true) {
            obj.Contig[thisContig].ORF=obj.Contig[thisContig].ORF.filter(filterGO(setGOCategory,setGOParent)); //Filter on GO parents

            startobj.Contig[thisContig].ORF=obj.Contig[thisContig].ORF.filter(filterGO(setGOCategory,setGOParent)); //Filter on GO parents (WHY DO THIS??) Otherwise it chockes on a few lines below startobj.Contig[thisContig].ORF[thisORF].BLAST[thisBlast].idGen = idGen;
            //END GO FILTER SECTION
        }

        if (testObject(obj.Contig[thisContig].ORF)) //Test if the contig has an ORF
        {
            //Initialize (or reset to 0) the currentORF that holds the unique Topparents for each ORF. We don't want to count double
            currentORF = [];
            currentORF.MF = [];
            currentORF.BP = [];
            currentORF.CC = [];


            for (var thisORF in obj.Contig[thisContig].ORF) {

                if (testObject(obj.Contig[thisContig].ORF[thisORF])) {




                    if (obj.Contig[thisContig].ORF[thisORF].hasInterPro == "True")
                    {
                    var link = INTERPROLINK + obj.Contig[thisContig].contig + "_ORF_" + obj.Contig[thisContig].ORF[thisORF].name + ".html";
                    obj.Contig[thisContig].ORF[thisORF].interpro = '<a href="popupex.html" onclick="return ' + "popitup('" + link + "')" + '">InterPro</a>';
                    }
                    else
                    {
                        obj.Contig[thisContig].ORF[thisORF].interpro = '-';
                    }


                    if (testObject(obj.Contig[thisContig].ORF[thisORF].GO)) {

                        //td('<a href="">4: phosphorelay sensor kinase...</a>')

                        //Commented out 20141104 the GO procedures
                        /*
                         for (var thisDatabase in obj.Contig[thisContig].ORF[thisORF].GO) { //Transform the GO term into a clickable link
                         var GOstring = obj.Contig[thisContig].ORF[thisORF].GO[thisDatabase].split('|'); //Split them by | and take the first one
                         obj.Contig[thisContig].ORF[thisORF].MSGO = "<a target='_blank' href='" + GOLINK + GOstring[0] + "'>" + obj.Contig[thisContig].ORF[thisORF].GO[thisDatabase] + "</a>";
                         break; //Only take the first (doesnt mean Most Significant!) GO term
                         }
                         */
                         obj.Contig[thisContig].ORF[thisORF].MSGO = ""; //initialize the MSGO
                        for (var thisGO in obj.Contig[thisContig].ORF[thisORF].GO) { //Go though each individual GO term
                            obj.Contig[thisContig].ORF[thisORF].MSGO =  obj.Contig[thisContig].ORF[thisORF].GO[thisGO].name + ", " + obj.Contig[thisContig].ORF[thisORF].MSGO;
                            for (var thisTopParent in obj.Contig[thisContig].ORF[thisORF].GO[thisGO].top_parent){ //Go through each iniviudal top_parent of the annotated GO term
                                switch(obj.Contig[thisContig].ORF[thisORF].GO[thisGO].top_parent[thisTopParent].type) { //GO is based on three classifications
                                    case 'molecular_function':
                                        if(currentORF.MF.indexOf(obj.Contig[thisContig].ORF[thisORF].GO[thisGO].top_parent[thisTopParent].name) == -1) //Check of the topparent already exist in this ORF. if not:
                                        {
                                            TopParents.MF.push(obj.Contig[thisContig].ORF[thisORF].GO[thisGO].top_parent[thisTopParent].name); //Add to the global TopParent list
                                            currentORF.MF.push(obj.Contig[thisContig].ORF[thisORF].GO[thisGO].top_parent[thisTopParent].name); //Add to the currentORF list to keep track fo indivicdual toparents
                                        }
                                        break;

                                    case 'biological_process':
                                        if(currentORF.BP.indexOf(obj.Contig[thisContig].ORF[thisORF].GO[thisGO].top_parent[thisTopParent].name) == -1)
                                        {
                                        TopParents.BP.push(obj.Contig[thisContig].ORF[thisORF].GO[thisGO].top_parent[thisTopParent].name);
                                            currentORF.BP.push(obj.Contig[thisContig].ORF[thisORF].GO[thisGO].top_parent[thisTopParent].name);
                                        }
                                        break;

                                    case 'cellular_component':
                                        if(currentORF.CC.indexOf(obj.Contig[thisContig].ORF[thisORF].GO[thisGO].top_parent[thisTopParent].name) == -1)
                                        {
                                        TopParents.CC.push(obj.Contig[thisContig].ORF[thisORF].GO[thisGO].top_parent[thisTopParent].name);
                                            currentORF.CC.push(obj.Contig[thisContig].ORF[thisORF].GO[thisGO].top_parent[thisTopParent].name);
                                        }
                                        break;
                                    default:
                                        throw "GO top_parent should contain one of the three valid GO categories";
                                        break;
                                }


                            }

                        }
                        if (obj.Contig[thisContig].ORF[thisORF].MSGO === "")
                        {
                             obj.Contig[thisContig].ORF[thisORF].MSGO = "-"; //Show a - instead of nothing
                        }
                        else
                        {
                            obj.Contig[thisContig].ORF[thisORF].MSGO  = obj.Contig[thisContig].ORF[thisORF].MSGO.substr(0,obj.Contig[thisContig].ORF[thisORF].MSGO.length - 2);
                        }


                    }
                    else
                    {
                        obj.Contig[thisContig].ORF[thisORF].MSGO = "-"; //Show a - instead of nothing
                    }




                    if (setRemoveHypo == true) obj.Contig[thisContig].ORF[thisORF].BLAST=obj.Contig[thisContig].ORF[thisORF].BLAST.filter(filterHypo); //Filter the hypothetical proteins out

                    if (testObject(obj.Contig[thisContig].ORF[thisORF].BLAST)) { //Check of the ORF has a BLAST
                        if (setRemoveEval == true) obj.Contig[thisContig].ORF[thisORF].BLAST=obj.Contig[thisContig].ORF[thisORF].BLAST.filter(filterEval);

                        for (var thisBlast in obj.Contig[thisContig].ORF[thisORF].BLAST) {






                            len_perc = (obj.Contig[thisContig].ORF[thisORF].BLAST[thisBlast].q_end - obj.Contig[thisContig].ORF[thisORF].BLAST[thisBlast].q_start) / (obj.Contig[thisContig].ORF[thisORF].BLAST[thisBlast].h_length);
                            //document.write((obj.Contig[thisContig].ORF[thisORF].BLAST[thisBlast].end ))
                            obj.Contig[thisContig].ORF[thisORF].BLAST[thisBlast].len_perc = Number(len_perc * 100).toPrecision(3) + '%';
                            obj.Contig[thisContig].ORF[thisORF].BLAST[thisBlast].eval = Number(obj.Contig[thisContig].ORF[thisORF].BLAST[thisBlast].eval).toPrecision(2);
                            obj.Contig[thisContig].ORF[thisORF].BLAST[thisBlast].idGen = idGen;
                            obj.Contig[thisContig].ORF[thisORF].BLAST[thisBlast].h_desc = '<a href="http://www.ncbi.nlm.nih.gov/protein/'+obj.Contig[thisContig].ORF[thisORF].BLAST[thisBlast].h_acc +'" target="_new">'+ obj.Contig[thisContig].ORF[thisORF].BLAST[thisBlast].h_desc+'</a>';

                            obj.Contig[thisContig].ORF[thisORF].BLAST[thisBlast].fastalink = '<a href="' + SERVERPREFIX + 'php/fasta.php?JSONFilename=' + currentJSONFilename + '&contig=' + obj.Contig[thisContig].contig+ '&blast='+ obj.Contig[thisContig].ORF[thisORF].BLAST[thisBlast].h_acc + '">FASTA</a>';
                            startobj.Contig[thisContig].ORF[thisORF].BLAST[thisBlast].idGen = idGen;
                            idGen++;
                        }
                        for (var key in obj.Contig[thisContig].ORF[thisORF].BLAST[0]) {
                            obj.Contig[thisContig].ORF[thisORF][key] = obj.Contig[thisContig].ORF[thisORF].BLAST[0][key] // Move the MSH one hierachy level up


                        }
                    }

                }

            }

        }



    }
    //alert(' Total reads processed: ' + totalEntity + ' Assembled reads in Contig: ' + assembledReads + ' Non assembled reads: ' + (totalEntity - assembledReads));



    //Start looping again to find empty contigs



        for (var thisContig = obj.Contig.length - 1; thisContig >= 0; thisContig--) { //Reverse loop otherwise the splice() command breaks the indexing order!

        var isEmpty = true; //Initially assume each contig is empty
        if (testObject(obj.Contig[thisContig].ORF)) //Test if the contig has an ORF
        {


            for (var thisORF in obj.Contig[thisContig].ORF) {

                if (testObject(obj.Contig[thisContig].ORF[thisORF])) {

                    if (testObject(obj.Contig[thisContig].ORF[thisORF].BLAST)) { //Check of the ORF has a BLAST



                        for (var thisBlast in obj.Contig[thisContig].ORF[thisORF].BLAST) {
                            isEmpty = false; //This ORF has a BLAST, so not empty
                        }

                        }
                }
            }
        }
        console.log (obj.Contig[thisContig].id +" is isEmpty: " + isEmpty );
        if (isEmpty == true)
        {
            console.log("removing: " + obj.Contig[thisContig].id + " before length: " +obj.Contig.length);
             obj.Contig.splice(thisContig,1);

            //TODO chheck if this line is OK!
          startobj.Contig.splice(thisContig,1); //We probaly need to do this in order to keep the indexes in sync!
        }

    }



    console.log("Maximum length of contig is passed:" + setLengthWarning);

    if (setLengthWarning==true && warnedYet == false)

    {
        warnedYet = true;
        setLengthWarning=false;






        $(function() {
            $( "#dialog-confirm" ).dialog({
                resizable: false,
                autoOpen: false,
                height:140,
                modal: true,
                buttons: {
                    "Yes, resize": function() {
                        $("#list").jqGrid('setColProp','contig',{widthOrg:200});

                        $("#list").jqGrid('setColProp','readrow',{widthOrg:160});
                        $("#list").jqGrid('setColProp','canvas',{widthOrg:maxContigLength*0.3+100});
                        $("#list").jqGrid('setColProp','length',{widthOrg:40});
                        $("#list").jqGrid('setColProp','genbank',{widthOrg:50});
                        $("#list").jqGrid('setGridWidth',200+160+40+50+maxContigLength*0.3+100,true);
                        reloadGrid(currentJSONFilename);

                        $( this ).dialog( "close" );
                    },
                    Cancel: function() {
                        $( this ).dialog( "close" );
                    }
                }
            });
        });

        $( document ).ready(function() {

            $("#dialog-confirm").dialog("open")


        });





        //$(".confirm").onclick();





    }

}

///Get the length of an object
function getLength(thisObject) {
    return Object.keys(thisObject).length;
}


//This function takes the original copy of the JSON file (startobj) and deletes all the BLAST hits out of it. Then it copies in the selected BLAST hits from the "modified" JSON file (obj)
function postJSON(selected) {


    if (selected.length > 0) { //Test if any BLAST hits are selected and put in the array


        for (var thisContig in obj.Contig) {

            if (testObject(obj.Contig[thisContig].ORF)) //Test if the contig has an ORF
            {
                for (var thisORF in obj.Contig[thisContig].ORF) {
                    if (testObject(obj.Contig[thisContig].ORF[thisORF])) {

                        //clearing the BLAST in startobj
                        startobj.Contig[thisContig].ORF[thisORF].BLAST = [];

                        for (var thisBlast in obj.Contig[thisContig].ORF[thisORF].BLAST) {

                            for (var i = 0; i < selected.length; i++) {
                                if (obj.Contig[thisContig].ORF[thisORF].BLAST[thisBlast].idGen == selected[i]) {
                                    //console.log("JAAA" + selected[i]+obj.Contig[thisContig].ORF[thisORF].BLAST[thisBlast].h_desc )
                                    startobj.Contig[thisContig].ORF[thisORF].BLAST.push(obj.Contig[thisContig].ORF[thisORF].BLAST[thisBlast]); //filling the startobj BLAST with only the selected guys
                                }
                            }
                        }
                    }
                }
            }
            // document.write(JSON.stringify(newJSON, undefined, 20));
        }

        alert('Download link now available!')

        var data = "text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(startobj));
        //document.write('<a href="data:' + data + '" download="data.json">download JSON</a>')
        now = new Date().getTime();
        $('<a href="data:' + data + '" download="data' + now + '.json">download JSON</a>').appendTo('#downloadcontainer'); //Update the download container with a date specific download link
    }
    else {
        alert('No BLAST hits selected')
    }
}

//Calculate the estimate size of an object, for debug purposes
function roughSizeOfObject(object) {

    var objectList = [];
    var stack = [ object ];
    var bytes = 0;

    while (stack.length) {
        var value = stack.pop();

        if (typeof value === 'boolean') {
            bytes += 4;
        }
        else if (typeof value === 'string') {
            bytes += value.length * 2;
        }
        else if (typeof value === 'number') {
            bytes += 8;
        }
        else if
            (
            typeof value === 'object'
                && objectList.indexOf(value) === -1
            ) {
            objectList.push(value);

            for (var i in value) {
                stack.push(value[ i ]);
            }
        }
    }
    return (bytes / 1024 / 1024);
}


/// Function to test if an object exist and is an object
function testObject(Object2Test) {
    if ((typeof Object2Test == "object")) {
        return true;
    }
    else {
        return false;
    }
}

/// Fetch the JSON file from the backend
function loadJSON(callback,JSONFilename) {
    try
    {
        var xobj = new XMLHttpRequest();
        xobj.overrideMimeType("application/json");


        xobj.open('GET', SERVERPREFIX + 'php/readAjax.php?JSONFilename=' + JSONFilename, false); /// Lauch the GET
        xobj.onerror = function(){
            console.log('Error loading ajax');
            alert('Error loading AJAX');
        }
        xobj.onreadystatechange = function () {
            if (xobj.readyState == 4 && xobj.status == "200") {

                callback(xobj.responseText);
            }else
            {
                console.log("Error", xobj.statusText);
                alert('Error in loading serverside JSON file. Server returned: ' + xobj.statusText);
            }

        };
        xobj.send(null);
    }
    catch(e)
    {
        alert(e)
    }
}


/// Reload the grid with an updated JSON file
function reloadGrid(JSONFilename) {
    var actual_JSON = 0;

    loadJSON(function (response) {
        // Parse JSON string into object

        actual_JSON = JSON.parse(response);

    },JSONFilename);


    obj = actual_JSON;
    startobj = JSON.parse(JSON.stringify(obj)); //The most stupid way of copying a object without referencing it...


    var totalEntity = 0;
    var assembledReads = 0;

    prepareJSON();

    //   alert(' Total reads processed: ' + totalEntity + ' Assembled reads in Contig: ' + assembledReads + ' Non assembled reads: ' + (totalEntity - assembledReads));






    //alert(roughSizeOfObject(obj.Contig));
    console.log("reloading...");
    // $("#list").jqGrid("setGridParam", { datatype: "json" }).trigger("reloadGrid", [{ current: true }]);

    jQuery("#list").setGridParam({ data: {} }); //Used this instead of the line above, otherwise jqGrid will load in the previous data!


    $("#list").jqGrid().trigger('reloadGrid', [
        { page: 1}
    ]);


    jQuery("#list")
        .jqGrid('setGridParam',
        {
            datatype: 'local',
            data: obj.Contig

        })
        .trigger("reloadGrid");
    console.log("done...");

}


/// Handle Interpro popup
function popitup(url) {
    newwindow = window.open(url, 'name', 'height=600,width=850');
    if (window.focus) {
        newwindow.focus()
    }
    return false;
}