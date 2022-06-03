// !preview r2d3 data = {source("r2d3-data.R"); d3Data}, options = list(meta = colnames(md)), container = "div", viewer = "browser"

//// !preview r2d3 data = cbind(d0 = c(0, 0, 3, 8), d1 = c(0, 0, 3, 8), d2 = c(3, 3, 0, 5), d3 = c(8, 8, 5, 0), mappedX = c(1, 1, 0, 0), mappedY = c(1, 0, 0, 1), cluster = c(1, 1, 2, 3), Cluster_col = c("red", "red", "steelblue", "green"), read.csv("Testing_Nextstrain_Metadata.csv", row.names = 1)[1:4, ], Age_col = c("red", "orange", "yellow", "grey"), Gender_col = c("pink", "blue", "blue", "pink"), Vaccination_status_col = c("red", "green", "red", "red")), options = list(col = hcl.colors(4), txt = letters[1:4], meta = c("Gender", "Location", "Age", "Vaccination_status")), container = "div", viewer = "browser"

div.selectAll('*').remove();

const linkMax = 200;
const linkMod = 42 / linkMax;
var linkMult = linkMod * linkMax / 2;
const radMax = 200;
const radMod = 25 / radMax;
var radMult = radMod * radMax / 2;


var links = function() {
      var ret = [];
      for (i = 0; i != data.length; ++i) {
        for (j = 0; j != i; ++j) {
          ret.push({"source": i, "target": j, "distance": data[i]["d" + j]});
        }
      }
      return ret;
    }
    
function radius (d) {
  return radMult * (typeof(d.radius) === "undefined" ? 1 : d.radius);
}

function fill_col(d) {
  fill_opt = div.select("#colSelect").property("value");
  return fill_opt == "Uniform" ? "steelblue" : d[fill_opt + "_col"];
}

const fade = d3.transition()

function mouseOver(d) {
  const my_id = d3.select(this).attr("id").replace("circle", "#tooltip");
  div.select(my_id)
    .transition()
    .ease(d3.easeLinear)
    .style("visibility", "visible");
}

function mouseOut(d, i) {
  
  const my_id = d3.select(this).attr("id").replace("circle", "#tooltip");
  div.select(my_id)
    .transition()
    .ease(d3.easeLinear)
    .style("visibility", "hidden");
}

function ticked() {
  var u = div
      .selectAll(".node-group")
      .data(data)
      .join(enter => {
        var node = enter
            .append("div")
            .attr("class", "node-group")
            .style("position", "absolute")
            .style("border-style", "solid")
            .style("border-color", fill_col)
            .style("border-width", function(d, i) {
              return radius(d, i) + "px";
            })
            .style("width", "0px")
            .style("height", "0px")
            .style("border-radius", "1000px")
            .style("overflow", "visible")
            .style("text-align", "center")
            .style("line-height", "0")
            .style("user-select", "none")
            .style("white-space", "nowrap")
            .text(function(d, i) {return i;})
            .on("mouseover", mouseOver)
            .on("mouseout", mouseOut)
          ;
          
        node.append("text")
            .text("")
            .attr("font-family", "\"Gill Sans\", \"Gill Sans MT\", Arial")
            .attr("text-anchor", "middle")
            .attr("dominant-baseline", "central")
          ;
            
        node.append("text")
            .text("Tooltip text.")
            .style("visibility", "hidden")
            .attr("font-family", "\"Gill Sans\", \"Gill Sans MT\", Arial")
            .attr("id", function (d, i) {return "tooltip_" + i;})
            ;
      })
      .style("left", function(d) {return d.x + "px";})
      .style("top", function(d) {return d.y + "px";});
}

function update() {
  var u = div
   .selectAll(".node-group")
   .data(data)
   .join("div")
     .style("border-color", fill_col)
     .text(function(d, i) {
       txt_opt = div.select("#txtSelect").property("value");
       switch (txt_opt) {
         case "None": return "";
         case "Index": return i;
         case "ID": return d["_row"];
         default: {
           return d[txt_opt];
         }
       }
     })
  ;
  
  
  let fill_opt = div.select("#colSelect").property("value");
  let values = [];
  if (fill_opt != "Cluster" && fill_opt != "Uniform") {
    data.forEach(function(dat) {
      d_opt = dat[fill_opt];
      if (!values.find(el => el.val == d_opt)) {
        values.push({"val": d_opt, "col": dat[fill_opt + "_col"]});
      }
    })
  }
  
  var legend = div
    .selectAll(".legend-entry")
    .data(values)
    .join(enter => {
      var entry = enter
          .append("div")
          .attr("class", "legend-entry")
          .style("float", "right")
          .style("clear", "right")
          .style("border-right-style", "solid")
          .style("height", "1.1em")
          .style("line-height", "1.1em")
          .style("border-color", function(d) {
            return d.col;
          })
          .style("border-width", "10px")
          .style("margin", "5px")
          .style("padding-right", "5px")
          .style("overflow", "visible")
          .style("text-align", "left")
          .text(function(d, i) {return d.val;})
        ;
    })
    .style("left", function(d) {return d.x + "px";})
    .style("top", function(d) {return d.y + "px";});
    
}

var simulation = d3.forceSimulation(data)
  .force("charge", d3.forceManyBody().strength(0.1))
  .force("x", d3.forceX()
    .x(function(d) {return d.mappedX * width;})
    .strength(0.01))
  .force("y", d3.forceY()
    .y(function(d) {return d.mappedY * height;})
    .strength(0.01))
  .force("center", d3.forceCenter(width / 2, height / 2))
  .force("link", d3
    .forceLink()
    .links(links())
    .distance(function(link) {return link.distance * linkMult;})
    .strength(0.9)
  )
  .force("collision", d3.forceCollide().radius(radius))
  .on("tick", ticked)
;
  


function dragSubject(e) {
  xy = d3.pointer(e);
  return simulation.find(xy[0], xy[1], 50);
}

function dragStarted(e) {
  if (!e.active) {
    simulation.alphaTarget(0.3).restart();
  }
  simulation.force("x", null).force("y", null).force("center", null);
  e.subject.fx = e.x;
  e.subject.fy = e.y;
}  

function dragged(e) {
  e.subject.fx = e.x;
  e.subject.fy = e.y;
}

function dragEnded(e) {
  if (!e.active) {
    simulation.alphaTarget(0);
  }
  e.subject.fx = null;
  e.subject.fy = null;
}

div
  .call(d3.drag()
    .container(div)
    .subject(dragSubject)
    .on("start", dragStarted)
    .on("drag", dragged)
    .on("end", dragEnded)
  )
;

var lblColSelect = div.append("label")
      .attr("for", "colSelect")
      .style("float", "left")
      .text("Colour by:")
      
var colSelect = div.append("select")
      .attr("name", "colSelect")
      .attr("id", "colSelect")
      .style("float", "left")
      .on("change", update)
      ;
      
var colOptions = colSelect.selectAll("option")
      .data(["Cluster", "Uniform"].concat(options["meta"]))
      .enter()
      .append("option");

colOptions.text(d => d).attr("value", d => d)
      
var lblTxtSelect = div.append("label")
      .attr("for", "colSelect")
      .style("float", "left")
      .text("Label:")
      
var txtSelect = div.append("select")
      .attr("name", "txtSelect")
      .attr("id", "txtSelect")
      .style("float", "left")
      .on("change", update)
      ;
      
var txtOptions = txtSelect.selectAll("option")
      .data(["Index", "ID", "None"].concat(options["meta"]))
      .enter()
      .append("option");
txtOptions.text(d => d).attr("value", d => d)

function mouseX(e) {
  let elem = e.target.getBoundingClientRect();
  return (e.clientX - elem.left) / elem.width;
}

var updatingSpacing = 0;
function updateSpacing(e) {
  if (updatingSpacing) {
    x = e.offsetX;
    linkMult = linkMod * x;
    
    div.select("#setSpacing")
        .style("background-image", sliderGradient(x))
    
    simulation.force("link", d3
        .forceLink()
        .links(links())
        .distance(function(link) {return link.distance * linkMult;})
        .strength(0.9)
      )
      .alpha(0.5)
      .alphaTarget(0)
      .restart();
  }
}

function spacingStart(e) {
  updatingSpacing = 1;
  updateSpacing(e)
}

function spacingEnd(e) {
  updatingSpacing = 0;
  simulation.alphaTarget(0).restart();
}


var updatingRadius = 0;
function updateRadius(e) {
  if (updatingRadius) {
    x = e.offsetX
    radMult = radMod * x;
    
    div.select("#setRadius")
        .style("background-image", sliderGradient(x))
        
    div.selectAll(".node-group")
      .data(data)
      .style("border-width", function(d, i) {
        return radius(d, i) + "px";
      })
    ;
    
    simulation.force("collision", d3.forceCollide().radius(radius))
      .alpha(0.5)
      .alphaTarget(0.3)
      .restart()
    ;
  }
}

function radiusStart(e) {
  updatingRadius = 1;
  updateRadius(e)
}

function radiusEnd(e) {
  updatingRadius = 0;
  simulation.alphaTarget(0).restart();
}

function sliderGradient(px) {
  return "linear-gradient(90deg, steelblue, transparent " + px + "px, steelblue)";
}

var setSpacing = div.append("div")
      .attr("id", "setSpacing")
      .style("background-image", sliderGradient(100))
      .style("width", "200px")
      .style("height", "20px")
      .style("margin", "5px")
      .style("user-select", "none")
      .style("text-align", "center")
      .style("float", "left")
      .style("clear", "left")
      .text("Spacing")
      .on("mousedown", spacingStart)
      .on("mouseout", spacingEnd)
      .on("mouseup", spacingEnd)
      .on("mousemove", updateSpacing)
      ;
      
var setRadius = div.append("div")
      .attr("id", "setRadius")
      .style("background-image", sliderGradient(100))
      .style("width", "200px")
      .style("height", "20px")
      .style("margin", "5px")
      .style("user-select", "none")
      .style("text-align", "center")
      .style("float", "left")
      .text("Radius")
      .on("mousedown", radiusStart)
      .on("mouseout", radiusEnd)
      .on("mouseup", radiusEnd)
      .on("mousemove", updateRadius)
      ;
