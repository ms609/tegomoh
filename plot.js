// !preview r2d3 data = cbind(d0 = c(0, 0, 3, 8), d1 = c(0, 0, 3, 8), d2 = c(3, 3, 0, 5), d3 = c(8, 8, 5, 0), mappedX = c(1, 1, 0, 0), mappedY = c(1, 0, 0, 1), cluster = c(1, 1, 2, 3), Cluster_col = c("red", "red", "steelblue", "green"), read.csv("Testing_Nextstrain_Metadata.csv", row.names = 1)[1:4, ], Age_col = c("red", "orange", "yellow", "grey"), Gender_col = c("pink", "blue", "blue", "pink"), Vaccination_status_col = c("red", "green", "red", "red")), options = list(col = hcl.colors(4), txt = letters[1:4], meta = c("Gender", "Location", "Age", "Vaccination_status")), container = "div", viewer = "browser"

div.selectAll('*').remove();

var linkMult = 10;
var linkMax = 200;
var radMult = 8;
var radMax = 200;

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
  return fill_opt == "Fixed" ? "steelblue" : d[fill_opt + "_col"];
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
            .text("agdsh")
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
     .style("border-color", fill_col);
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
  .on("tick", ticked);
  
  // simulation.find(x, y) returns nearest node
  

var lblColSelect = div.append("label")
      .attr("for", "colSelect")
      .text("Colour by:")
      
var colSelect = div.append("select")
      .attr("name", "colSelect")
      .attr("id", "colSelect")
      .on("change", update)
      ;
      
var colOptions = colSelect.selectAll("option")
      .data(["Cluster", "Fixed"].concat(options["meta"]))
      .enter()
      .append("option");

function mouseX(e) {
  let elem = e.target.getBoundingClientRect();
  return (e.clientX - elem.left) / elem.width;
}

function updateSpacing(e) {
  linkMult = 50 * mouseX(e);
  
  div.select("#setSpacing")
      .style("background-image", sliderGradient(e.offsetX))
  
  simulation.force("link", d3
      .forceLink()
      .links(links())
      .distance(function(link) {return link.distance * linkMult;})
      .strength(0.9)
    )
    .alpha(0.5)
    .alphaTarget(0.3)
    .restart();
}

function updateRadius(e) {
  radMult = 25 * mouseX(e);
  
  div.select("#setRadius")
      .style("background-image", sliderGradient(e.offsetX))
      
  div.selectAll(".node-group")
    .data(data)
    .style("border-width", function(d, i) {
      return radius(d, i) + "px";
    })
  ;
          
  
  simulation.force("collision", d3.
    forceCollide().
    radius(radius)
    )
    .alpha(0.5)
    .alphaTarget(0.3)
    .restart()
  ;
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
      .style("user-select": "none")
      .style("text-align": "center")
      .text("Spacing")
      .on("click", updateSpacing)
      .on("mousemove", function(e) {if (e.buttons) {updateSpacing(e);}})
      ;
      
var setRadius = div.append("div")
      .attr("id", "setRadius")
      .style("background-image", sliderGradient(100))
      .style("width", "200px")
      .style("height", "20px")
      .style("margin", "5px")
      .style("user-select": "none")
      .text("Radius")
      .on("click", updateRadius)
      .on("mousemove", function(e) {if (e.buttons) {updateRadius(e);}})
      ;

colOptions.text(d => d).attr("value", d => d)
