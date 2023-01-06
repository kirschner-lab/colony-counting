// Subsets the image to a particular channel and converts to grayscale.

// CHANGE THIS NUMBER TO THE CHANNEL WITH THE HIGHEST CONTRAST!
// 1 = Red
// 2 = Green
// 3 = Blue
channel = 1;

// Run faster with batch mode.
setBatchMode(true);

// Select the requested channel.
Stack.setChannel(channel);
// Remove the other channels and discard the original image.
run("Reduce Dimensionality...", " ");
// Convert type from color to grayscale.
run(String.format("%.0f-bit", bitDepth()));
// Replace color LUT with grayscale for better visual contast.
run("Grays");

// Return to interactive mode.
setBatchMode(false);
// Select the line tool for the next step of rotation.
setTool("line");
