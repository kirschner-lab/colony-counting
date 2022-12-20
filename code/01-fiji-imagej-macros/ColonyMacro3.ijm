// Background subtracts using the line ROI and removes speckle noise.

// Measure the largest colony in the quadrant of interest.
radius = 1/2*(getValue("Length"))
// Remove background from the media, etc across the image.
// We need to do this for the whole image instead of individual plates
// to minimize colony detection bias across replicates.
run("Subtract Background...", "rolling=radius");
// Remove speckle noise that may otherwise be counted as colonies.
run("Median...", "radius=2");
// Select the oval tool for the next step of cropping the plate.
setTool("oval");
