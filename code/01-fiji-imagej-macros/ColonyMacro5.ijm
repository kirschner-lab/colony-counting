// Crops the quadrant and mask and save the images.

// Crop the quadrant of interest.
run("Crop");
// Split the quadrant and it's mask into separate images.
run("Stack to Images");
// Save the quadrant.
run("Tiff...");
// Close the quadrant.
close();
// Save the mask.
run("Tiff...")
// Close the mask.
close();
