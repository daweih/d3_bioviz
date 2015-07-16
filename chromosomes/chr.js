chr_figure();
                         
function chr_figure(log) {
	var fig_width = 900;
	var fig_height = 300;
	var fig_legend_height = 50;
	var login = d3.select("body div.canvas").append("svg");
						login.attr({
						"height": fig_height,
						"width": fig_width,
					});
	var chr_width = 70;
	var chr_band_width = 6;
	var left_margin = 50;
	d3.tsv("example_data/rice_chr_lgth.txt", function(data) {
		var max_Length_bp = 0;
		data.forEach(
			function(d, index) {
				if(max_Length_bp < d.Length_bp){
					max_Length_bp = d.Length_bp;
				}
			}
		);
		function chr_figure_loc(location_abs){
			//return chr_figure_loc(d.chr_lgth);
			//	   (fig_height-fig_legend_height- (fig_height-fig_legend_height)*d.Length_bp/max_Length_bp)/2
			return (fig_height-fig_legend_height- (fig_height-fig_legend_height)*location_abs/max_Length_bp)/2;
		}
		data.forEach(
			function(d, index) {
				console.log(d.Sequence, max_Length_bp, d.Length_bp/max_Length_bp, d.Length_bp, index);
				login
					.append("rect")
					.attr({
						"y": function(y) {
								return chr_figure_loc(d.Length_bp);//(fig_height-fig_legend_height- (fig_height-fig_legend_height)*d.Length_bp/max_Length_bp)/2;
						},
						"x": function(x) {return left_margin+index*chr_width;},
						"rx": function(h) {
								return 4;
						},
						"height": function(h) {
								if((fig_height-fig_legend_height)*d.Length_bp/max_Length_bp<5){
									return 5;
								}else{
									return (fig_height-fig_legend_height)*d.Length_bp/max_Length_bp;
								}
						},
						"width": chr_band_width,
						"fill": "steelblue",
						"opacity": 1
					});
				login
					.append("text")
					.style("text-align", "center")
					.text(function(x) {return d.Sequence;})
					.style("font-size", "12px")
					.style("fill", "black")
					.style("font-family", "Helvetica Neue Ultralight")
					.attr({
						"y": function(y) {return fig_height-30;},
						"x": function(x) {return 10+index*chr_width+chr_width/2;},
					});
	d3.tsv("example_data/"+d.Sequence+".sort.txt", function(data) {
		var fig_text_unit = (fig_height-fig_legend_height)/data.length;
		var fig_p_unit    = (fig_height-fig_legend_height)/max_Length_bp;
		data.forEach(
			function(d, index) {
//				console.log(d.Chr, d.POS, d.chr_index, index, data.length);
				login.append("path")
                            .attr("d", function(p){
                            if(index%2!=0){
									return "M"+(left_margin+d.chr_index*chr_width)+","+(chr_figure_loc(d.chr_lgth)+fig_p_unit*d.POS)
									+"L"+(left_margin+d.chr_index*chr_width+7)+","+(chr_figure_loc(d.chr_lgth)+fig_p_unit*d.POS)
									+"L"+(left_margin+d.chr_index*chr_width+25)+","+(fig_text_unit*index+0.7)
									+"L"+(left_margin+d.chr_index*chr_width+26)+","+(fig_text_unit*index+0.7)
									;
                            	}else{
									return "M"+(left_margin+d.chr_index*chr_width+chr_band_width)+","+(chr_figure_loc(d.chr_lgth)+fig_p_unit*d.POS)
									+"L"+(left_margin+d.chr_index*chr_width-7 +chr_band_width)+","+(chr_figure_loc(d.chr_lgth)+fig_p_unit*d.POS)
									+"L"+(left_margin+d.chr_index*chr_width-25+chr_band_width)+","+(fig_text_unit*index+0.7)
									+"L"+(left_margin+d.chr_index*chr_width-26+chr_band_width)+","+(fig_text_unit*index+0.7)
									;
                            	}
                            })
                            .attr("stroke", function(c) {return d.color;})
                            .attr("id", function(c) {return d.SNPName;})
//                            .attr("stroke", "black")
                            .attr("stroke-width", 0.2)
                            .attr("opacity", 1)
                            .attr("fill", "none");
                            						

//Chr	POS	SNPName	process	trait	chr_index	color	chr_lgth
				login
					.append("text")
					.attr({
						"y": function(y) {
								return fig_text_unit*index+1;
						},
						"x": function(x) {
                            if(index%2!=0){
								return left_margin+d.chr_index*chr_width+26;
							}else{
								return left_margin+d.chr_index*chr_width-26+chr_band_width;
							}
								},
					})
					.attr("id", function(c) {return d.SNPName;})
					.text(function(x) {
							if(d.process!="-"){
								return d.SNPName+": "+d.process;
//								return d.SNPName;
							}
							else{
								return d.SNPName;
							}
						})
					.style("font-size", "1.2px")
					.style("cursor", "crosshair")
					.style("text-anchor", 
						function(x) {
                            if(index%2!=0){
								return "left";
							}else{
								return "end";
							}
								}					
						)
					.style("fill", function(x) {
							if(d.trait!="-"){
								return d.color;
//								return "green";
							}
							else{
								return d.color;
							}
						})
					.style("font-family", "Helvetica")
					.on("click", function(){
						d3.select('path#'+d.SNPName).attr("stroke", "red");
						d3.select('text#'+d.SNPName).style("fill", "red");
//						d3.select('path#'+d.SNPName).remove();
//						d3.select('text#'+d.SNPName).remove();
					});
			}
				
		);
	});
			}
				
		);
	});

}

