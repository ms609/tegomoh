// !preview r2d3 data = {source("r2d3-data.R"); d3Data}, options = list(meta = colnames(md), contacts = contacts, from = fromI, to = toI), container = "div", viewer = "browser"

//// !preview r2d3 data = cbind(d0 = c(0, 0, 3, 8), d1 = c(0, 0, 3, 8), d2 = c(3, 3, 0, 5), d3 = c(8, 8, 5, 0), mappedX = c(1, 1, 0, 0), mappedY = c(1, 0, 0, 1), cluster = c(1, 1, 2, 3), Cluster_col = c("red", "red", "steelblue", "green"), read.csv("Testing_Nextstrain_Metadata.csv", row.names = 1)[1:4, ], Age_col = c("red", "orange", "yellow", "grey"), Gender_col = c("pink", "blue", "blue", "pink"), Vaccination_status_col = c("red", "green", "red", "red")), options = list(col = hcl.colors(4), txt = letters[1:4], meta = c("Gender", "Location", "Age", "Vaccination_status")), container = "div", viewer = "browser"

// Load in document for font references
var cssId = "fa6-css";
if (!document.getElementById(cssId)) {
    var head  = document.getElementsByTagName("head")[0];
    var link  = document.createElement("link");
    link.id   = cssId;
    link.rel  = "stylesheet";
    link.type = "text/css";
    link.href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.1.1/css/all.min.css"; //https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.11/webfonts/fa-solid-900.woff2
    link.media = "all";
    head.appendChild(link);
}

var to_i = [];
for (const value of Object.values(options["to"])) {
  to_i.push(typeof(value) === "number" ? value : -1);
}

var node_links = [];
data.forEach(function (node, j) {
  for (let i = 0; typeof(node["d" + i]) !== "undefined"; ++i) {
    node_links.push({"source": i, "target": j, "distance": node["d" + i]});
  }
});

div.selectAll("*").remove();

// Load css again to apply to shadow root
var faCss = div.append("link")
  .attr("rel", "stylesheet")
  .attr("type", "text/css")
  .attr("href", "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.1.1/css/all.min.css");

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


var some_icons = [
  "circle", "square", "star", "play", "diamond", "asterisk", "circle-dot", "square-plus", "circle-half-stroke", "bahai", "circle-notch", "circle-stop", "sun",
  "circle-pause", "hat-cowboy", "instalod", "at", "bacterium", "bacon",
  "bell", "anchor", "chess-pawn", "chess-knight",  "chess-bishop", "chess-rook", "chess-queen", "chess-king"
];
var next_icon = 0;
var chosen_icons = {};

function icon_name(str) {
  switch(str.toLowerCase()) {
    case "male": return "person";
    case "female": return "person-dress";
    
    case "vaccinated": return "syringe";
    case "unvaccinated": return "virus";
    
    case "household": return "house-chimney";
    case "church": return "cross";
    case "school": return "graduation-cap";
    
    case "hospital": 
    case "house":
      return str.toLowerCase();
    
    default: 
      if (typeof(chosen_icons[str]) === "undefined") {
        chosen_icons[str] = some_icons[next_icon];
        ++next_icon;
      }
      return chosen_icons[str];
  }
}

function fa_icon(str) {
  return "fa fas fa-solid fa-" + str;
}

function icon_class(d) {
  icon_opt = div.select("#icoSelect").property("value");
  return fa_icon(icon_name(d[icon_opt]));
}

const fade = d3.transition()

function mouseOver(d) {
  d3.select(this).style("z-index", 999);
  
  const my_id = d3.select(this).attr("id").replace("node", "#tooltip");
  div.select(my_id)
    .transition()
    .ease(d3.easeLinear)
    .style("visibility", "visible");
  
  const i_id = d3.select(this).attr("id").replace("node", "#icon");
  div.select(i_id).style("color", "black")
  
}

function mouseOut(d, i) {
  
  const my_id = d3.select(this).attr("id").replace("node", "#tooltip");
  div.select(my_id)
    .transition()
    .ease(d3.easeLinear)
    .style("visibility", "hidden");
  
  d3.select(this).style("z-index", 0);
}

function findDatum(prop, val) {
  return data.filter(obj => {return obj[prop] === val;})[0]
}

function getAttr(attr, i) {
  datum = findDatum("index", i)
  if (typeof(datum) === "object") {
    return datum[attr];
  }
}

function y01(d, i) {
  y0 = getAttr("y", d);
  y1 = getAttr("y", to_i[i]);
  return (y0 < y1) ? [y0, y1, 0] : [y1, y0, 1];
}

function x01(d, i) {
  x0 = getAttr("x", d);
  x1 = getAttr("x", to_i[i]);
  return (x0 < x1) ? [x0, x1, 0] : [x1, x0, 1];
}

function ticked() {
  
  var lines = div
      .selectAll(".node-link")
      .data(options["from"])
      .join(enter => {
        var edge = enter
          .append("div")
          .attr("class", "node-link")
          .text(function(d, i) {return `${d}_${to_i[i]}`;})
          .style("position", "absolute")
          .style("font-family", "monospace")
          .style("color", "#00000033")
        ;
      })
      .style("top", function(d, i) {
        return y01(d, i)[0] + radius(d, i) + "px";
      })
      .style("left", function(d, i) {
        return x01(d, i)[0] + radius(d, i) + "px";
      })
      .style("height", function(d, i) {
        return y01(d, i)[1] - y01(d, i)[0] + "px";
      })
      .style("width", function(d, i) {
        return x01(d, i)[1] - x01(d, i)[0] + "px";
      })
      .style("background", function(d, i) {
        return "linear-gradient(to " 
          + (y01(d, i)[2] ? "bottom" : "top") + " "
          + (x01(d, i)[2] ? "left" : "right")
          + ", #fff0 calc(50% - 1px), #0008, #fff0 calc(50% + 1px))";
      })
      .style("text-align", function(d, i) {
        return x01(d, i)[2] ? "left" : "right";
      })
      .style("line-height", function(d, i) {
        return y01(d, i)[2] ? "0px" : 2 * (y01(d, i)[1] - y01(d, i)[0]) + "px";
      })
    ;
        
  let snpDist = parseInt(div.select("#snpDist").property("value"));
  var snpLinks = div
      .selectAll(".snp-link")
      .data(links().filter(e => e.distance <= snpDist))
      .join(enter => {
        var edge = enter
          .append("div")
          .attr("class", "snp-link")
          .style("position", "absolute")
        ;
      })
      .style("top", function(d) {
        return y01(d.source, d.target)[0] + radius(d.source, d.target) + "px";
      })
      .style("left", function(d, i) {
        return x01(d.source, d.target)[0] + radius(d.source, d.target) + "px";
      })
      .style("height", function(d, i) {
        return y01(d.source, d.target)[1] - y01(d.source, d.target)[0] + "px";
      })
      .style("width", function(d, i) {
        return x01(d.source, d.target)[1] - x01(d.source, d.target)[0] + "px";
      })
      .style("background", function(d, i) {
        return "linear-gradient(to " 
          + (y01(d.source, d.target)[2] ? "bottom" : "top") + " "
          + (x01(d.source, d.target)[2] ? "left" : "right")
          + ", #fff0 calc(50% - 1px), #28a8, #fff0 calc(50% + 1px))";
      })
    ;
        
  var u = div
      .selectAll(".node-group")
      .data(data)
      .join(enter => {
        var node = enter
            .append("div")
            .attr("class", "node-group")
            .attr("id", function (d, i) {return "node" + i;})
            .style("position", "absolute")
            .style("width", "0px")
            .style("height", "0px")
            .style("border-radius", "1000px")
            .style("overflow", "visible")
            .style("text-align", "center")
            .style("line-height", "0")
            .style("user-select", "none")
            .style("white-space", "nowrap")
            .on("mouseover", mouseOver)
            .on("mouseout", mouseOut)
          ;
          
        node.append("i")
            .attr("class", "fa fas fa-solid fa-circle")
            .attr("id", function (d, i) {return "icon" + i;})
            .style("color", fill_col)
            .style("font-size", function(d, i) {
              return (1.8 * radius(d, i)) + "px";
            })
          ;
            
        var tool_div = node.append("div")
            .style("visibility", "hidden")
            .style("padding", "5px")
            .style("line-height", "revert")
            .style("font-family", "Gill Sans, Gill Sans MT, Arial")
            .attr("id", function (d, i) {return "tooltip" + i;})
        
        tool_div
          .selectAll(".tooltip-entry")
          .data(function(d, i) {
            let datum = data[i];
            let ret = [];
            for (const key of options["meta"]) {
              if (datum[key] !== null && datum[key] !== "") {
                ret.push({key: key, datum: datum[key]});
              }
            }
            return ret;
            
          })
          .join(enter => {
            var entry = enter
              .append("div")
              .attr("class", "tooltip-entry")
              .text(d => {return d.key + ": " + d.datum;})
              .style("line-height", "revert")
              .style("min-height", "1.1em")
              .style("margin", "2px")
          });
            
        
      })
      .style("left", d => {return d.x + "px";})
      .style("top", d => {return d.y + "px";});
}

function update() {
  var i = div
   .selectAll(".node-group > i")
   .data(data)
   .join("i")
     .style("color", fill_col)
     .attr("class", icon_class)
   ;
   
  var u = div
     .selectAll(".node-group > span")
     .data(data)
     .join("span")
       .style("visibility", "visible")
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
       });
  ;
  
  
  div.selectAll(".col-legend-entry").remove();
  let colValues = [];
  let fill_opt = div.select("#colSelect").property("value");
  if (fill_opt != "Cluster" && fill_opt != "Uniform") {
    data.forEach(function(dat) {
      d_opt = dat[fill_opt];
      if (!colValues.find(el => el.val == d_opt)) {
        colValues.push({"val": d_opt, "col": dat[fill_opt + "_col"]});
      }
    })
    
    var colLegend = div
      .selectAll(".col-legend-entry")
      .data(colValues)
      .join(enter => {
        var entry = enter
            .append("div")
            .attr("class", "col-legend-entry")
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
  
  div.selectAll(".ico-legend-entry").remove();
  let icoValues = [];
  let ico_opt = div.select("#icoSelect").property("value");
  if (ico_opt != "Circle") {
    data.forEach(function(dat) {
      d_opt = dat[ico_opt];
      if (!icoValues.find(el => el.val == d_opt)) {
        icoValues.push({"val": d_opt, "icon": icon_name(d_opt)});
      }
    })
    
    var icoLegend = div
      .selectAll(".ico-legend-entry")
      .data(icoValues)
      .join(enter => {
        var entry = enter
            .append("div")
            .attr("class", "ico-legend-entry")
            .style("float", "right")
            .style("clear", "right")
            .style("height", "1.1em")
            .style("line-height", "1.1em")
            .style("margin", "5px")
            .style("padding-right", "5px")
            .style("overflow", "visible")
            .style("text-align", "left")
            .text(function (d) {return d.val;})
          ;
        entry.append("i")
          .style("font-size", "18px")
          .style("padding-left", "5px")
          .attr("class", d => fa_icon(d.icon));
      })
      .style("left", function(d) {return d.x + "px";})
      .style("top", function(d) {return d.y + "px";});
  }
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
      .attr("for", "txtSelect")
      .style("float", "left")
      .text("Label:")
      
var txtSelect = div.append("select")
      .attr("name", "txtSelect")
      .attr("id", "txtSelect")
      .style("float", "left")
      .on("change", update)
      ;
      
var txtOptions = txtSelect.selectAll("option")
      .data([ "None", "ID", "Index"].concat(options["meta"]))
      .enter()
      .append("option");
txtOptions.text(d => d).attr("value", d => d)

var lblIcoSelect = div.append("label")
      .attr("for", "icoSelect")
      .style("float", "left")
      .text("Icon:")
      
var icoSelect = div.append("select")
      .attr("name", "icoSelect")
      .attr("id", "icoSelect")
      .style("float", "left")
      .on("change", update)
      ;
      
var icoOptions = icoSelect.selectAll("option")
      .data(["Circle"].concat(options["meta"]))
      .enter()
      .append("option");
icoOptions.text(d => d).attr("value", d => d)

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
        
    div.selectAll(".node-group > i")
      .data(data)
      .style("font-size", function(d, i) {
        return 1.8 * radius(d, i) + "px";
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
      
var lblSetSNP = div.append("label")
      .attr("for", "snpDist")
      .style("height", "20px")
      .style("margin", "5px")
      .style("text-align", "right")
      .style("float", "left")
      .text("SNP cluster:")
      ;
var setSNP = div.append("input")
      .attr("type", "number")
      .attr("id", "snpDist")
      .attr("value", "0")
      .style("width", "50px")
      .style("height", "20px")
      .style("margin", "5px")
      .style("text-align", "center")
      .style("float", "left")
      .on("change", ticked)
      ;
