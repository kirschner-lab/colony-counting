name = getTitle()
run("Crop");
run("Stack to Images");
run("Jpeg...");
close();
run("Tiff...")
close();



