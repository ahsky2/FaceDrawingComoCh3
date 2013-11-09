import java.util.*;

int imgCount = 90;
int imgIndex = 1;
PImage imgs[] = new PImage[imgCount];

int windowWidth = 720;
int windowHeight = 480;
int popArtWidth = 100;
int popArtHeight = 100;
int popArtFirstRowHeight = 80;
int popArtCount = 7 * 5 + 1; //(windowWidth / popArtWidth) * (windowHeight / popArtHeight) - 1;

Vector popArtVector;
int[] savedIndexes = new int[popArtCount];
int[] viewedIndexes = new int[popArtCount];

int[] showIndexes = new int[popArtCount];
int[] showCounts = new int[popArtCount];
int[] showDelayIndexes = new int[popArtCount];
int[] showDelays = new int[popArtCount];
boolean[] isRunnings = new boolean[popArtCount];

int offset = 20;

boolean isSave = false;
int saveIndex = 0;

int maskCount = 120; // velocity of transition
PGraphics[] fadeOutFirstRowMasks = new PGraphics[maskCount];
PGraphics[] fadeInFirstRowMasks = new PGraphics[maskCount];
PGraphics[] fadeOutMasks = new PGraphics[maskCount];
PGraphics[] fadeInMasks = new PGraphics[maskCount];

int transitionCount = 10; // # of transition

void setup() {
  frameRate(30);
  size(720, 480, P2D);
  smooth();
  background(0);
  
  for(int i = 0; i < imgCount; i++) {
    PImage img = loadImage("PFD_100x100_" + ((i + imgIndex + 100) + "").substring(1) + ".jpg");
    img.resize(popArtWidth, popArtHeight);
    imgs[i] = createImage(img.height, img.width, RGB);
    img.loadPixels();
    imgs[i].loadPixels();
    for(int y = 0 ; y < img.height; y++) {
      for(int x = 0 ; x < img.width; x++) {
        imgs[i].pixels[img.width - y - 1 + x * img.height] = img.pixels[x + y * img.width];
      } 
    }
    imgs[i].updatePixels();
  }
  
  for(int i = 0; i < maskCount; i++) {
    fadeOutFirstRowMasks[i] = createMask(i, maskCount, popArtWidth, popArtFirstRowHeight, true);
    fadeInFirstRowMasks[i] = createMask(i, maskCount, popArtWidth, popArtFirstRowHeight, false);
    fadeOutMasks[i] = createMask(i, maskCount, popArtWidth, popArtHeight, true);
    fadeInMasks[i] = createMask(i, maskCount, popArtWidth, popArtHeight, false);
  }
  
  popArtVector = new Vector();
  for(int i = 0; i < popArtCount; i++) {
    PopArtCube popArt;
    if (i < 8) {
      popArt = new PopArtCube(i * popArtWidth, 0, popArtWidth, popArtHeight);
      popArt.setFirstRow(popArtFirstRowHeight);
      popArt.setFirstRowMasks(fadeOutFirstRowMasks, fadeInFirstRowMasks);
    } else if (i < 8 + 7 * 1) {
      popArt = new PopArtCube((i - 7)* popArtWidth - 20, popArtHeight - offset, popArtWidth, popArtHeight);
    } else if (i < 8 + 7 * 2) {
      popArt = new PopArtCube((i - 7 * 2)* popArtWidth - 20 * 2, popArtHeight * 2 - offset, popArtWidth, popArtHeight);
    } else if (i < 8 + 7 * 3) {
      popArt = new PopArtCube((i - 7 * 3)* popArtWidth - 20 * 3, popArtHeight * 3 - offset, popArtWidth, popArtHeight);
    } else {
      popArt = new PopArtCube((i - 7 * 4)* popArtWidth - 20 * 4, popArtHeight * 4 - offset, popArtWidth, popArtHeight);
    }
    
    if ((i > 0 && i < popArtCount-1) && (i % 7) == 0) {
      popArt.setLastCol();
    }
    
    boolean isSame = true;
    while(isSame) {
      int index = round(random(0, imgCount-1));
      
      isSame = false;
      for(int j = 0; j < i; j++) {
        if(savedIndexes[j] == index) {
          isSame = true;
          break;
        }
      }
      if (!isSame) {
        viewedIndexes[i] = savedIndexes[i] = index;
        break;
      }
    }
    
    popArt.addImage(imgs[savedIndexes[i]], savedIndexes[i]);
    popArt.addImage(imgs[(savedIndexes[i] + 1) % imgCount], (savedIndexes[i] + 1) % imgCount);
    popArt.setDirection();
    popArt.setMasks(fadeOutMasks, fadeInMasks);
    popArtVector.add(popArt);
    
    showIndexes[i] = int(random(0, 600));
    showCounts[i] = 600;
    showDelayIndexes[i] = 0;
    showDelays[i] = int(random(0, 100));
  }
}

void draw() {
  Iterator iter = popArtVector.iterator();
  int i = 0;
  while (iter.hasNext()) {
    PopArtCube popArt = (PopArtCube)iter.next();
    if (showDelayIndexes[i] < showDelays[i]) {
      showDelayIndexes[i]++;
    } else if (showIndexes[i] < showCounts[i]) {
      showIndexes[i]++;
    } else {
      isRunnings[i] = popArt.transition();
      if (isRunnings[i]) {
      } else {
        if (popArt.transitionCount < transitionCount) {
          showDelayIndexes[i] = int(random(0, 100));
          showIndexes[i] = 0;
          showCounts[i] = int(random(400, 600));
          
          int index;
          if (popArt.transitionCount == transitionCount - 1) {
            index = savedIndexes[i];
          } else {
            index = (popArt.getImgIndex() + 1) % imgCount;
          }
          popArt.addImage(imgs[index], index);
          popArt.setDirection();
        } else {
          popArt.transitionStop();
        }
      }
    }
  
    popArt.update();
    popArt.display();
    
    i++;
  }

  if (isSave) {
    saveFrame("frames/" +  String.valueOf(10000 + saveIndex).substring(1));
    saveIndex++;
  }
}

void keyPressed() {
  if (key == 's' || key == 'S') {
    if (isSave) {
      isSave = false;
      println("Save Start");
    } else {
      isSave = true;
      println("Save End");
    }
  }
}

PGraphics createMask(int maskIndex, int maskCount, int maskWidth, int maskHeight, boolean isFadeOut) {
  PGraphics mask = createGraphics(maskWidth, maskHeight);
  mask.beginDraw();
  for(int h = 0; h < maskHeight; h++) {
    if (isFadeOut) {
      mask.stroke(map(h, 0, maskHeight - 1, map(maskIndex, 0, maskCount - 1, 255, 0), 255));
    } else {
      mask.stroke(map(h, 0, maskHeight - 1, 255, map(maskIndex, 0, maskCount - 1, 0, 255)));
    }
    mask.line(0, h, maskWidth, h);
  }
  mask.endDraw();
  
  return mask;
}
