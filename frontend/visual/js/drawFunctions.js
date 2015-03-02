/**
 * The javascript functions to draw the sequence data
 *
 * Created by ericvanderhelm on 6/30/14.
 */

///////////WRITING PICTURE

function updateCanvas()
{
    writePicture(document.getElementById('setDrawBLAST').checked,document.getElementById('setDrawInterpro').checked,document.getElementById('setDrawReads').checked);
    //alert (document.getElementById('setDrawInterpro').checked);
}
function writePicture(setDrawBLAST,setDrawInterpro,setDrawReads) {


    //Different draw methods:
        // drawBLAST
        // drawInterpro
        // drawReads

    //Write the picture


    for (var thisContig in obj.Contig) {
        counter = String(obj.Contig[thisContig].contig.split('.').join(""));

        var y = 5;

        //document.write('<canvas id="canvas' + counter + '" width="500" height="50" ></canvas>'); //style="zoom:50%" one way to make smaller
        clearCanvas(counter)
        drawContig(counter, 0, obj.Contig[thisContig].length);
        CONTIGCOUNTER++;
        //document.write("dow e reach this?")
        y = y + 5;
        y2 = 5

        //Draw the Reads as supplied

        if (setDrawReads == true)
        {
            for (var thisRead in obj.Contig[thisContig].reads) {
                if (testObject(obj.Contig[thisContig].reads[thisRead])) {
                    drawRead(counter, Number(obj.Contig[thisContig].reads[thisRead].start), Number(obj.Contig[thisContig].reads[thisRead].end), 35 + y2, Number(obj.Contig[thisContig].reads[thisRead].direction))
                    y2 = y2 + 10

                }
            }
        }


        //Draw the PredictedORFS
        if (testObject(obj.Contig[thisContig].predicted_genes)) //Test if the contig has an predicted_genes key
        {


            for (var thisPredictedORF in obj.Contig[thisContig].predicted_genes) {
                if (testObject(obj.Contig[thisContig].predicted_genes[thisPredictedORF])) {
                    //Math.round(Math.random() * 5
                    drawPredictedORF(counter, obj.Contig[thisContig].predicted_genes[thisPredictedORF].start, obj.Contig[thisContig].predicted_genes[thisPredictedORF].end, 25, +obj.Contig[thisContig].predicted_genes[thisPredictedORF].dir, "Pred");
                    y = y + 4;
                    y = 30

                }
            }
        }


        if (testObject(obj.Contig[thisContig].ORF)) //Test if the contig has an ORF
        {

            // output(getLength(obj.Contig[thisContig].ORF)); //Show how many ORFS are present

            for (var thisORF in obj.Contig[thisContig].ORF) {
                if (testObject(obj.Contig[thisContig].ORF[thisORF])) {
                    ORFCOUNTER++;

                    drawORF(counter, obj.Contig[thisContig].ORF[thisORF].start, obj.Contig[thisContig].ORF[thisORF].end, 15, obj.Contig[thisContig].ORF[thisORF].name, obj.Contig[thisContig].ORF[thisORF].dir);
                    y = y + 4;
                    y = 30


                    operator = obj.Contig[thisContig].ORF[thisORF].dir;

                    //Draw the InterPro

                    if(setDrawInterpro==true)
                    {
                        for (var thisInterPro in obj.Contig[thisContig].ORF[thisORF].InterPro) {


                            if (testObject(obj.Contig[thisContig].ORF[thisORF].InterPro[thisInterPro])) {
                                //console.log("interpor!")
                                IPCOUNTER++;

                                drawInterPro(counter, obj.Contig[thisContig].ORF[thisORF].start + ( (obj.Contig[thisContig].ORF[thisORF].InterPro[thisInterPro].start * 3)), obj.Contig[thisContig].ORF[thisORF].start + (obj.Contig[thisContig].ORF[thisORF].InterPro[thisInterPro].end * 3), 45 + y2)
                                y2 = y2 + 10

                            }
                        }
                    }

                    if (setDrawBLAST == true)
                    {
                        for (var thisBlast in obj.Contig[thisContig].ORF[thisORF].BLAST) {
                            //output(obj.Contig[thisContig].ORF[thisORF].BLAST[thisBlast].h_desc)
                            //console.log(obj.Contig[thisContig].ORF[thisORF].BLAST[thisBlast].q_start);
                            drawBLAST(counter, obj.Contig[thisContig].ORF[thisORF].start + obj.Contig[thisContig].ORF[thisORF].BLAST[thisBlast].q_start*3, obj.Contig[thisContig].ORF[thisORF].start + obj.Contig[thisContig].ORF[thisORF].BLAST[thisBlast].q_end*3, y);
                            //console.log(obj.Contig[thisContig].ORF[thisORF].BLAST[thisBlast].q_start); //Something is wrong here :)
                            y = y + 3;

                            // drawShape('canvas' + counter, obj.Contig[thisContig].ORF[thisORF].BLAST[thisBlast].q_start,obj.Contig[thisContig].ORF[thisORF].BLAST[thisBlast].q_end);
                            //drawShape('canvas' + counter, 0,obj.Contig[thisContig].length);
                            //counter++;
                        }
                    }
                }


            }


            //counter++;
        }
        else {

            //output("empty");
        }

    }


}

////////////////////////////////////DRAWING FUNCTIONS///////////////

function drawContig(canvasName, startX, endX) {
    drawShape(canvasName, startX, endX, 2, "green")
}
function drawORF(canvasName, startX, endX, y, ORFid,dir) {
    drawShape(canvasName, startX, endX, y, "blue")


         drawArrow(canvasName,  startX, endX, y, "blue", dir)

    drawText(canvasName, startX, endX, y, "blue", ORFid)

}
function drawBLAST(canvasName, startX, endX, y) {
    //drawShape(canvasName,startX,endX,y,"red") //ctx.strokeStyle = 'rgba(255,0,0,0.7)';
    drawShape(canvasName, startX, endX, y, 'rgba(255,0,0,0.5)')
}

function drawRead(canvasName, startX, endX, y, direction) {
    //Math.round(Math.random()*150)
    drawShape(canvasName, startX, endX, y, "teal", 3)
    drawArrowRead(canvasName, startX, endX, y, "teal", 3, direction)
}


function drawInterPro(canvasName, startX, endX, y) {
    //Math.round(Math.random()*150)
    drawShape(canvasName, startX, endX, y, "yellow", 4)

}


function drawPredictedORF(canvasName, startX, endX, y, frame, ORFid) {
    drawShape(canvasName, startX, endX, y, "blue", 2, true)
    drawArrow(canvasName, startX, endX, y, "blue", frame)
    if (ORFid != "Pred") //Standard a "Pred" will be passed, if the JSON file changes in the future a more describtive term can be used
    {
        drawText(canvasName, startX, endX, y, "blue", ORFid)
    }


}


function clearCanvas(canvasName) {




    var testName = String("canvas" + canvasName)


    var canvas = document.getElementById(testName);

    if (canvas) {
        canvas.width = canvas.width;
        if (canvas.getContext) {

            // use getContext to use the canvas for drawing
            var ctx = canvas.getContext('2d');

            // var point = (startX>endX)? endX-startX : startX-endX;





        } else {

            alert('No browser support for the canvas function, please update your browser');
        }
    }

}


function drawText(canvasName, startX, endX, y, color, text) {


    lineWidth = (typeof lineWidth == "undefined") ? 2 : lineWidth //Default lineWidth =2 if not defined

    // get the canvas element using the DOM
    var testName = String("canvas" + canvasName)


    var canvas = document.getElementById(testName);

    if (canvas) {
        if (canvas.getContext) {

            // use getContext to use the canvas for drawing
            var ctx = canvas.getContext('2d');

            // var point = (startX>endX)? endX-startX : startX-endX;


            ctx.font = "bold 10px sans-serif";
            ctx.textAlign = "center"
            ctx.fillText("ORF: " + String(text), (startX / RESIZE + ((endX / RESIZE - startX / RESIZE) / 2)), y - 2);


        } else {
            alert('No browser support for the canvas function, please update your browser');
        }
    }

}


function drawShape(canvasName, startX, endX, y, color, lineWidth, isDash) {
    isDash = (typeof isDash !== 'undefined') ? isDash : false; //If not passed set isDash to false
    lineWidth = (typeof lineWidth == 'undefined') ? 2 : lineWidth //Default lineWidth =2 if not defined


    // get the canvas element using the DOM
    var testName = String("canvas" + canvasName)


    var canvas = document.getElementById(testName);

    if (canvas) {
        if (canvas.getContext) {

            // use getContext to use the canvas for drawing
            var ctx = canvas.getContext('2d');


            ctx.beginPath();

            ctx.moveTo(startX / RESIZE, y)//+Math.round(Math.random()*100));
            if (isDash === true) {
                ctx.setLineDash([2]);
            }

            ctx.lineTo(endX / RESIZE, y);
            //ctx.lineTo(startX,105);
            ctx.lineWidth = lineWidth;

            // set line color
            ctx.strokeStyle = color;
            ctx.stroke();
            ctx.setLineDash([0]);


        } else {
            alert('No browser support for the canvas function, please update your browser');
        }
    }


}

// Draw read arrows
function drawArrowRead(canvasName, startX, endX, y, color, lineWidth, direction) {

// get the canvas element using the DOM
    //var canvas = document.getElementById(canvasName);

    //var canvas = document.getElementById("first").getElementsByTagName("canvas")[canvasName];
    var canvas = document.getElementById("canvas" + canvasName);
    //alert(canvas)
    // Make sure we don't execute when canvas isn't supported
    if (canvas) {
        if (canvas.getContext) {

            // use getContext to use the canvas for drawing
            var ctx = canvas.getContext('2d');


            ctx.beginPath();

            if (direction == 1) {
                //Forward
                ctx.moveTo((endX - 50) / RESIZE, y - 5)//+Math.round(Math.random()*100));
                ctx.lineTo(endX / RESIZE, y);
            }
            else {
                //Reverse

                ctx.moveTo((Number(startX) + 50) / RESIZE, y - 5)//+Math.round(Math.random()*100));
                ctx.lineTo(startX / RESIZE, y);
            }


            //ctx.lineTo(startX,105);
            ctx.lineWidth = lineWidth;

            // set line color
            ctx.strokeStyle = color;
            ctx.stroke();


        } else {
            alert('No browser support for the canvas function, please update your browser');
        }
    }
}

/// Draw  ORF arrows
function drawArrow(canvasName, startX, endX, y, color, frame) {

    // get the canvas element using the DOM
    //var canvas = document.getElementById(canvasName);
    // var canvas = document.getElementById("first").getElementsByTagName("canvas")[canvasName];
    var canvas = document.getElementById("canvas" + canvasName);
    //alert(canvas)
    // Make sure we don't execute when canvas isn't supported
    if (canvas) {
        if (canvas.getContext) {

            // use getContext to use the canvas for drawing
            var ctx = canvas.getContext('2d');


            ctx.beginPath();

            if (frame > 0) {
                //Forward
                ctx.moveTo((endX - 50) / RESIZE, y - 5)//+Math.round(Math.random()*100));
                ctx.lineTo(endX / RESIZE, y);
            }
            else {
                //Reverse

                ctx.moveTo((Number(startX) + 50) / RESIZE, y - 5)//+Math.round(Math.random()*100));
                ctx.lineTo(startX / RESIZE, y);
            }


            //ctx.lineTo(startX,105);
            ctx.lineWidth = 2;

            // set line color
            ctx.strokeStyle = color;
            ctx.stroke();


        } else {
            alert('No browser support for the canvas function, please update your browser');
        }
    }
}

/// Render the GO chart
function renderChart(GO, data) {



    d3.select(GO).select("svg").remove(); //Remove old GO chart


    var valueLabelWidth = 40; // space reserved for value labels (right)
    var barHeight = 10; // height of one bar
    var barLabelWidth = 120; // space reserved for bar labels
    var barLabelPadding = 5; // padding between bar and bar labels (left)
    var gridLabelHeight = 3; // space reserved for gridline labels
    var gridChartOffset = 3; // space between start of grid and first bar
    var maxBarWidth = 100; // width of the bar with the max value
    var darksteelblue = d3.hcl("hsl(207, 44%, 49%)").darker();
// accessor functions
    var barLabel = function(d) { return d['category']; };
    var barValue = function(d) { return parseFloat(d['hits']); };

// sorting
    var sortedData = data.sort(function(a, b) {
        return d3.descending(barValue(a), barValue(b));
    });

// scales
    var yScale = d3.scale.ordinal().domain(d3.range(0, sortedData.length)).rangeBands([0, sortedData.length * barHeight]);
    var y = function(d, i) { return yScale(i); };
    var yText = function(d, i) { return y(d, i) + yScale.rangeBand() / 2; };
    var x = d3.scale.linear().domain([0, d3.max(sortedData, barValue)]).range([0, maxBarWidth]);
// svg container element
    var chart = d3.select(GO).append("svg")
        .attr('width', maxBarWidth + barLabelWidth + valueLabelWidth)
        .attr('height', gridLabelHeight + gridChartOffset + sortedData.length * barHeight);
// grid line labels


    var gridContainer = chart.append('g')
        .attr('transform', 'translate(' + barLabelWidth + ',' + gridLabelHeight + ')');
    /*
     gridContainer.selectAll("text").data(x.ticks(10)).enter().append("text")
     .attr("x", x)
     .attr("dy", -3)
     .attr("text-anchor", "middle")
     .text(String);
     */
// vertical grid lines
    gridContainer.selectAll("line").data(x.ticks(10)).enter().append("line")
        .attr("x1", x)
        .attr("x2", x)
        .attr("y1", 0)
        .attr("y2", yScale.rangeExtent()[1] + gridChartOffset)
        .style("stroke", "#ccc");
// bar labels
    var labelsContainer = chart.append('g')
        .attr('transform', 'translate(' + (barLabelWidth - barLabelPadding) + ',' + (gridLabelHeight + gridChartOffset) + ')');
    labelsContainer.selectAll('text').data(sortedData).enter().append('text')
        .attr('y', yText)
        .attr('stroke', 'none')
        .attr('fill', 'black')
        .attr("dy", ".35em") // vertical-align: middle
        .attr('text-anchor', 'end')
        .text(barLabel);
// bars
    var barsContainer = chart.append('g')
        .attr('transform', 'translate(' + barLabelWidth + ',' + (gridLabelHeight + gridChartOffset) + ')');
    barsContainer.selectAll("rect").data(sortedData).enter().append("rect")
        .attr('y', y)
        .attr('height', yScale.rangeBand())
        .attr('width', function(d) { return x(barValue(d)); })
        .attr('stroke', 'white')
        //.attr('fill', 'steelblue')
        .attr('fill', function(d){ if (d.category == document.getElementById("setGO").getAttribute("parent")){ return darksteelblue;}else{return 'steelblue';} })


        .on('click',function(d) { console.log(GO + " in " + d.category);

            if (d.category == document.getElementById("setGO").getAttribute("parent"))
            {
                //We clicked on the category that is already selected. Reset!
                document.getElementById('setGO').setAttribute('category', '');document.getElementById('setGO').setAttribute('parent', '');reloadGrid(currentJSONFilename); drawGO();
            }
            else
            {
                // Make new GO selection
            document.getElementById("setGO").setAttribute("category",GO.substring(1)); document.getElementById("setGO").setAttribute("parent", d.category); reloadGrid(currentJSONFilename); drawGO(); }
            }) //Define the onClick of the GO bar
        .append("svg:title")
        .text(function(d) { return d.hover; }); //Add tooltip with the full GO term

// bar value labels
    barsContainer.selectAll("text").data(sortedData).enter().append("text")
        .attr("x", function(d) { return x(barValue(d)); })
        .attr("y", yText)
        .attr("dx", 3) // padding-left
        .attr("dy", ".35em") // vertical-align: middle
        .attr("text-anchor", "start") // text-align: right
        .attr("fill", "black")
        .attr("stroke", "none")
        .text(function(d) { return d3.round(barValue(d), 2); });
// start line
    barsContainer.append("line")
        .attr("y1", -gridChartOffset)
        .attr("y2", yScale.rangeExtent()[1] + gridChartOffset)
        .style("stroke", "#000");

}

function drawGO(){
    unique = [];
    for(var thisCategory in TopParents)
    {
        console.log(uniqueFrequency(TopParents[thisCategory]));
        graphObject = [];
        unique = uniqueFrequency(TopParents[thisCategory]);

        for(var key in unique)
        {
            if (key.length>24)
            {GOlabel = key.substr(0,22) + "...";}
            else
            {  GOlabel = key;}

            graphObject.push({"category": GOlabel, "hits": unique[key],"hover": key});
        }

        console.log(graphObject);
        renderChart('#' + thisCategory ,graphObject);

    }
}