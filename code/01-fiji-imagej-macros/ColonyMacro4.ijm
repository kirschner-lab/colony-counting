// Crops to the plate circle ROI and adds the reference mask.

// Run faster with batch mode.
setBatchMode(true);
// Crop to the plate.
run("Crop");
// Add a blank channel to indicate the plate area.
run("Add Slice");
// Use white color.
setForegroundColor(255, 255, 255);
// Fill in the plate area with white color in the new channel.
run("Fill", "slice");
// Show the original plate to crop out the quadrant of interest.
setSlice(1);

// Return to interactive mode.
setBatchMode(false);
// Select the rectangle tool for the next step of cropping the quadrant.
setTool("rectangle");
