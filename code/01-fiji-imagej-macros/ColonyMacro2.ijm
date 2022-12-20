// Rotates the image to a drawn vertical line ROI.

// Measure the amount to rotate from the existing line ROI.
rotangle = 90-abs(getValue("Angle"))
// Rotate the image with bicubic interpolation to minimize artifacts.
run("Rotate... ", "angle=rotangle grid=0 interpolation=Bicubic")
// Select the line tool for the next step of background subtraction.
setTool("line");
