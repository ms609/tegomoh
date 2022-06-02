// !preview r2d3 data = cbind(d0 = c(0, 0, 3, 8), d1 = c(0, 0, 3, 8), d2 = c(3, 3, 0, 5), d3 = c(8, 8, 5, 0), mappedX = c(1, 1, 0, 0), mappedY = c(1, 0, 0, 1), read.csv("Testing_Nextstrain_Metadata.csv", row.names = 1)[1:4, ]), options = list(col = hcl.colors(4), txt = letters[1:4]), viewer = "internal"

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
  return typeof(d.radius) === "undefined" ? 8 : d.radius;
}

function ticked() {
  var u = svg
      .selectAll(".node-group")
      .data(data)
      .join(enter => {
        var node = enter
            .append("g")
            .attr("class", "node-group")
            ;
        
        node.append("circle")
            .attr("r", radius)
            .attr("cx", 0)
            .attr("cy", 0)
            .attr("fill", function (d, i) {
              return options.col[i];
            });
          
        node.append("text")
            .text(function(d, i) {return options.txt[i];})
            .attr("font-family", "\"Gill Sans\", \"Gill Sans MT\", Arial")
            .attr("text-anchor", "middle")
            .attr("dominant-baseline", "central");
      })
      .attr("transform", function(d) {
              return "translate(" + d.x + "," + d.y + ")";
            });
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
    .distance(function(link) {return link.distance * 10;})
    .strength(0.9)
  )
  .force("collision", d3.forceCollide().radius(radius).strength(1))
  .on("tick", ticked);
  
  // simulation.find(x, y) returns nearest node
  