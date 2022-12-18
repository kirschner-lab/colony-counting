#@ Integer(label="Channel to use", min=1, max=4, style="slider") channel
// There doesn't seem to be a way to query the number channels
// in the above parameter input, so we assume a maximum of 4
// found in RGBA color photographs.

// Run faster with batch mode.
setBatchMode(true);

// Validate input.
getDimensions(width, height, channels, slices, frames);
if (channel > channels) {
	exit(String.format("This image has only %.0f channels "+
	                   "but you asked for channel %.0f!",
	                   channels, channel));
}
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
