PImage img;     // image to process
PImage button;  // control button
float displayWidth, displayHeight;
int buttonX, buttonY;

int windowWidth = 1000;
int windowHeight = 560;
int spaceBetweenImages = 20;
int maxImageWidth = (windowWidth - spaceBetweenImages) / 2;
int maxImageHeight;  // calculated further down when button.height is known

int xOffsetForImageDisplay;
int yOffsetForImageDisplay;
int xOffsetForOutputDisplay;
int yOffsetForOutputDisplay;

// variables used for displaying image at lower resolutions
int downsampleFactor = 1;
int maxDownsampleFactor;

void setup() {
  //size(windowWidth, windowHeight);
  size(1000, 560);  // have to specify dimensions for applet

  img = loadImage("image.jpg");
  button = loadImage("pixel.jpg");
  
  maxImageHeight = windowHeight - button.height;
  buttonX = 0;
  buttonY = maxImageHeight;

  /* calculate display width and height of input image so it fits optimally within available area */
  displayWidth = img.width;
  displayHeight = img.height;
  if ((img.width > maxImageWidth) && (img.height > maxImageHeight)) {
    float aspectRatio = (float)img.width / (float)img.height;
    float aspectRatioMaxImage = (float)maxImageWidth / (float)maxImageHeight;
    if (aspectRatio > aspectRatioMaxImage) {
      displayWidth = maxImageWidth;
      displayHeight = img.height * maxImageWidth / img.width;
    } else {
      displayHeight = maxImageHeight;
      displayWidth = img.width * maxImageHeight / img.height;
    }
  } else if (img.width > maxImageWidth) {
    displayWidth = maxImageWidth;
    displayHeight = img.height * maxImageWidth / img.width;
  } else if (img.height > maxImageHeight) {
    displayHeight = maxImageHeight;
    displayWidth = img.width * maxImageHeight / img.height;
  }

  /* position offsets for centering input/output images in respective display areas */
  xOffsetForImageDisplay = (int)((maxImageWidth - displayWidth) / 2);
  yOffsetForImageDisplay = (int)((maxImageHeight - displayHeight) / 2);
  xOffsetForOutputDisplay = maxImageWidth + spaceBetweenImages + xOffsetForImageDisplay;
  yOffsetForOutputDisplay = yOffsetForImageDisplay;

  /* maximum downsample factor variable used to calculate minimum resolution for output display */
  if (displayWidth > displayHeight) {
    maxDownsampleFactor = (int)displayWidth;
  } else {
    maxDownsampleFactor = (int)displayHeight;
  }
}

void draw() {
  background(255, 255, 255);

  image(img, xOffsetForImageDisplay, yOffsetForImageDisplay, displayWidth, displayHeight);  // image(img, x, y, width, height)
  smooth();
  image(button, buttonX, buttonY);  // image(img, x, y)
  smooth();

  downsampleBlocks(downsampleFactor);
}

void mouseDragged() {
  /* relevant mouseX values range from (button.width / 2) to (windowWidth - (button.width / 2))
   * downSampleFactor values range from 1 to the greater of displayWidth and displayHeight
   * mouseX values have to be scaled for usable input as downSampleFactor values
   * example:
   * 50--950 needs to be scaled to produce 1--490 (or 0--489)
   * subtracting 50 and dividing by 900 gives a range of 0--1
   * multipling by 489 and adding 1 gives a range of 1--490
   */

  if (mouseX < (button.width / 2)) {  // case where mouseX falls below range of usable values (mouseX too far to left)
    buttonX = 0;
    downsampleFactor = 1;
  } else if (mouseX >= (windowWidth - (button.width / 2))) {  // mouseX falls above range of usable values (mouseX too far to right)
    buttonX = windowWidth - button.width - 1;
    downsampleFactor = maxDownsampleFactor;
  } else {  // mouseX input scaled to produce downsampleFactor for downsampling image to output resolution
    buttonX = mouseX - (button.width / 2);
    downsampleFactor = (int)(((mouseX - (button.width / 2)) * (maxDownsampleFactor - 1) / (windowWidth - button.width)) + 1);
  }
}

void downsampleBlocks(int downsampleFactor) {
  /* variables used in calculating average color of "downsampled" block representing lower output display resolution */
  int downsampleBlocksize = downsampleFactor * downsampleFactor;
  color[] blockColors = new color[downsampleBlocksize];
  float[] blockRedChannels = new float[downsampleBlocksize];
  float[] blockGreenChannels = new float[downsampleBlocksize];
  float[] blockBlueChannels = new float[downsampleBlocksize];

  int i = 0;
  int j = 0;
  while (i < displayWidth) {
    while (j < displayHeight) {

      /* cycle through block reading each pixel's color and respective R, G & B channels */
      int blockIndex;
      for (int blockI = 0; blockI < downsampleFactor; blockI++) {
        for (int blockJ = 0; blockJ < downsampleFactor; blockJ++) {
          blockIndex = blockI * downsampleFactor + blockJ;
          if (((i + blockI) < displayWidth) && ((j + blockJ) < displayHeight)) {
            blockColors[blockIndex] = get(xOffsetForImageDisplay + i + blockI, yOffsetForImageDisplay + j + blockJ);
            blockRedChannels[blockIndex] = red(blockColors[blockIndex]);
            blockGreenChannels[blockIndex] = green(blockColors[blockIndex]);
            blockBlueChannels[blockIndex] = blue(blockColors[blockIndex]);
          } else {  // if this block has coordinates outside actual image coordinates, RGB values are assigned -1
            blockRedChannels[blockIndex] = -1;
            blockGreenChannels[blockIndex] = -1;
            blockBlueChannels[blockIndex] = -1;
          }
        }
      }
      
      /* calculate average R, G & B values for pixels in the block */
      float r, g, b;
      color cc;
      int pixelcounter = 0;
      
      r = 0;
      g = 0;
      b = 0;
      for (int ii = 0; ii < downsampleBlocksize; ii++) {
        if (blockRedChannels[ii] != -1) {  // only calculate average color of block pixels that were inside actual image coordinates
          r = r + blockRedChannels[ii];
          g = g + blockGreenChannels[ii];
          b = b + blockBlueChannels[ii];
          pixelcounter++;  // keep track of how many actual pixels are used to compute average color of the block
        }
      }
      r = r / pixelcounter;
      g = g / pixelcounter;
      b = b / pixelcounter;
      cc = color(r, g, b);

      /* set each pixel in the block to the average color, ensuring that pixel was also within the actual image coordintes */
      for (int blockI = 0; blockI < downsampleFactor; blockI++) {
        for (int blockJ = 0; blockJ < downsampleFactor; blockJ++) {
          if (((i + blockI) < displayWidth) && ((j + blockJ) < displayHeight)) {
            set(xOffsetForOutputDisplay + i + blockI, yOffsetForOutputDisplay + j + blockJ, cc);
          }
        }
      }
      
      j = j + downsampleFactor;
    }
    j = 0;
    i = i + downsampleFactor;
  }
}
