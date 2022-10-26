radius = 1/2*(getValue("Length"))
run("Subtract Background...", "rolling=radius");
run("Median...", "radius=2");
setTool("oval");
