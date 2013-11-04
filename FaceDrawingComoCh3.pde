import java.util.*;

int imgCount = 12;
PImage imgs[] = new PImage[imgCount];

NonLinearFunc func;

int windowWidth = 720;
int windowHeight = 480;
int popArtWidth = 100;
int popArtHeight = 100;
int popArtCount = 7 * 5 + 1; //(windowWidth / popArtWidth) * (windowHeight / popArtHeight) - 1;
Vector popArtVector;

int[] showIndexes = new int[popArtCount];
int[] showCounts = new int[popArtCount];
int[] showDelayIndexes = new int[popArtCount];
int[] showDelays = new int[popArtCount];
boolean[] isRunnings = new boolean[popArtCount];

int offset = 20;

boolean isSave = false;
int saveIndex = 0;
int saveCount = 1000;

void setup() {
  size(720, 480, P2D);
  smooth();
  
  for(int i = 0; i < imgCount; i++) {
//    PImage img = loadImage("img" + (i + 1) + ".jpg");
    PImage img = loadImage("PFD_100x100_" + (i + 101 + "").substring(1) + ".jpg");
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
  
  func = new NonLinearFunc(0.0, 0.0, 255.0, 255.0, 3.0);
  func.make(12.0); // alpha value
  
  popArtVector = new Vector();
  for(int i = 0; i < popArtCount; i++) {
    PopArt popArt;
    if (i < 8) {
      popArt = new PopArt(i * popArtWidth, -offset, popArtWidth, popArtHeight);
    } else if (i < 8 + 7 * 1) {
      popArt = new PopArt((i - 7)* popArtWidth - 20, popArtHeight - offset, popArtWidth, popArtHeight);
    } else if (i < 8 + 7 * 2) {
      popArt = new PopArt((i - 7 * 2)* popArtWidth - 20 * 2, popArtHeight * 2 - offset, popArtWidth, popArtHeight);
    } else if (i < 8 + 7 * 3) {
      popArt = new PopArt((i - 7 * 3)* popArtWidth - 20 * 3, popArtHeight * 3 - offset, popArtWidth, popArtHeight);
    } else {
      popArt = new PopArt((i - 7 * 4)* popArtWidth - 20 * 4, popArtHeight * 4 - offset, popArtWidth, popArtHeight);
    }
    int index = round(random(0, imgCount-1));
//        println(index);
    popArt.setImage(imgs[index], true);
    popArt.setImage(imgs[(index + 1) % imgCount], true);
    popArtVector.add(popArt);
    
    showIndexes[i] = 0;
    showCounts[i] = 200;
    showDelayIndexes[i] = 0;
    showDelays[i] = 5 * i;
  }
}

void draw() {
  Iterator iter = popArtVector.iterator();
  int i = 0;
  while (iter.hasNext()) {
    PopArt popArt = (PopArt)iter.next();
    if (showDelayIndexes[i] < showDelays[i]) {
      showDelayIndexes[i]++;
    } else if (showIndexes[i] < showCounts[i]) {
      showIndexes[i]++;
    } else {
      
      isRunnings[i] = popArt.transition(10,func);
      if (isRunnings[i]) {
      } else {
//        showDelayIndexes[i] = 0;
        showIndexes[i] = 0;
//        showCounts[i] = int(random(100, 200));
        int index = round(random(0, imgCount-1));
        popArt.setImage(imgs[index], false);
      }
    }
  
    popArt.update();
    popArt.display();
    
    i++;
  }

  if (isSave) {
    if (saveIndex < saveCount / 2 + 1) {
      saveFrame("frames/" +  String.valueOf(10000 + saveIndex).substring(1));
      saveFrame("frames/" +  String.valueOf(10000 + saveCount - saveIndex).substring(1));
      saveIndex++;
    }
  }
}

void mouseClicked() {
//  isSave = true;
}

void keyDown( ) {
  
}
