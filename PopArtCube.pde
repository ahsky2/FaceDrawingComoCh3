
class PopArtCube {
  float x;
  float y;
  float width;
  float height;
  float firstRowHeight;
  int imgCount = 2;
  PImage[] imgs = new PImage[imgCount]; // [front image, back image]
  PImage[] firstRowImgs = new PImage[imgCount]; // [front image, back image]
  int[] imgIndexes = new int[imgCount];
  int imgAddIndex = 0;
  int imgIndex = 0; // 0 : front image
  int status = 0; // 0 : image showing, 1 : transition

  boolean isRunning = false;
  
  PGraphics[] fadeOutMasks;
  PGraphics[] fadeInMasks;
  PGraphics[] fadeOutFirstRowMasks;
  PGraphics[] fadeInFirstRowMasks;
  int maskCount;
  int maskIndex = 0;
  
  PImage colorImg;
  boolean isNextImg = false;
  
  int transitionCount = 0;
  boolean isStop = false;
  
  boolean isUpside = false;
  
  boolean isFirstRow = false;
  boolean isLastCol = false;

  PopArtCube (float x, float y, float w, float h) {
    // empty frame
    this.x = x;
    this.y = y;  
    this.width = w;
    this.height = h;
    
    for(int i = 0; i < imgCount; i++) {
      imgs[i] = createImage((int)width, (int)height, RGB);
    }
  }

  void addImage(PImage img, int index) {
    imgIndexes[imgAddIndex] = index;
    imgs[imgAddIndex].copy(img, 0, 0, (int)width, (int)height, 0, 0, (int)width, (int)height);
    if (isFirstRow) {
      firstRowImgs[imgAddIndex].copy(img, 
        0, int((height - firstRowHeight)/2), (int)width, (int)firstRowHeight, 
        0, 0, (int)width, (int)firstRowHeight);
    }
    imgAddIndex = (imgAddIndex + 1) % imgCount;
  }
  
  void setColor(color cubeColor) {
    this.colorImg = createImage(int(width), int(height), RGB);
    colorImg.loadPixels();
    for (int i = 0; i < colorImg.pixels.length; i++) {
      colorImg.pixels[i] = cubeColor; 
    }
    colorImg.updatePixels();
  }
  
  void setMasks(PGraphics[] fadeOutMasks, PGraphics[] fadeInMasks) {
    this.fadeOutMasks = fadeOutMasks;
    this.fadeInMasks = fadeInMasks;
    this.maskCount = fadeOutMasks.length;
  }
  
  void setFirstRowMasks(PGraphics[] fadeOutFirstRowMasks, PGraphics[] fadeInFirstRowMasks) {
    this.fadeOutFirstRowMasks = fadeOutFirstRowMasks;
    this.fadeInFirstRowMasks = fadeInFirstRowMasks;
  }

  void update() {
    if (status == 1) {
      
    }
  }

  void display() {
    float tempHeight;
    PGraphics[] tempFadeOutMasks;
    PGraphics[] tempFadeInMasks;
    PImage[] tempImgs;
    if (isFirstRow) {
      tempHeight = firstRowHeight;
      tempFadeOutMasks = fadeOutFirstRowMasks;
      tempFadeInMasks = fadeInFirstRowMasks;
      tempImgs = firstRowImgs;
    } else {
      tempHeight = height;
      tempFadeOutMasks = fadeOutMasks;
      tempFadeInMasks = fadeInMasks;
      tempImgs = imgs;
    }
    
    fill(0);
    noStroke();
    rect(x, y, width, tempHeight);
    if (isLastCol) {
      pushMatrix();
      translate(-(width * 7 + 20), tempHeight);
      rect(x, y, width, height);
      popMatrix();
    }
    
    textureMode(NORMAL);
    
    if (status == 0) {
      image(tempImgs[imgIndex], x, y);
      if (isLastCol) {
        pushMatrix();
        translate(-(width * 7 + 20), tempHeight);
        image(imgs[imgIndex], x, y);
        popMatrix();
      }
    } 
    else {
      if (isUpside) {
        
        float transValue = map(maskIndex, 0, maskCount, 0, tempHeight);
        
        tempImgs[imgIndex].mask(tempFadeOutMasks[maskIndex]);
      
        beginShape();
        texture(tempImgs[imgIndex]);
        vertex(x, y, 0, 0);
        vertex(x + width, y, 1, 0);
        vertex(x + width, y + tempHeight - transValue, 1, 1);
        vertex(x, y + tempHeight - transValue, 0, 1);
        endShape();
        
        tempImgs[(imgIndex + 1) % imgCount].mask(tempFadeInMasks[maskIndex]);
          
        beginShape();
        texture(tempImgs[(imgIndex + 1) % imgCount]);
        vertex(x, y + tempHeight - transValue, 0, 0);
        vertex(x + width, y + tempHeight - transValue, 1, 0);
        vertex(x + width, y + tempHeight, 1, 1);
        vertex(x, y + tempHeight, 0, 1);
        endShape();
        
        if (isLastCol) {
          pushMatrix();
          translate(-(width * 7 + 20), tempHeight);
          
          if (isFirstRow) {
            tempHeight = height;
            tempFadeOutMasks = fadeOutMasks;
            tempFadeInMasks = fadeInMasks;
            tempImgs = imgs;
            transValue = map(maskIndex, 0, maskCount, 0, tempHeight);
            tempImgs[imgIndex].mask(tempFadeOutMasks[maskIndex]);
            tempImgs[(imgIndex + 1) % imgCount].mask(tempFadeInMasks[maskIndex]);
          }
          
          beginShape();
          texture(tempImgs[imgIndex]);
          vertex(x, y, 0, 0);
          vertex(x + width, y, 1, 0);
          vertex(x + width, y + tempHeight - transValue, 1, 1);
          vertex(x, y + tempHeight - transValue, 0, 1);
          endShape();
          
          beginShape();
          texture(tempImgs[(imgIndex + 1) % imgCount]);
          vertex(x, y + tempHeight - transValue, 0, 0);
          vertex(x + width, y + tempHeight - transValue, 1, 0);
          vertex(x + width, y + tempHeight, 1, 1);
          vertex(x, y + tempHeight, 0, 1);
          endShape();
          
          popMatrix();
        }
      } else {
        float transValue = map(maskIndex, 0, maskCount, 0, tempHeight);
        
        tempImgs[imgIndex].mask(tempFadeInMasks[maskCount - maskIndex - 1]);
      
        beginShape();
        texture(tempImgs[imgIndex]);
        vertex(x, y + transValue, 0, 0);
        vertex(x + width, y + transValue, 1, 0);
        vertex(x + width, y + tempHeight, 1, 1);
        vertex(x, y + tempHeight, 0, 1);
        endShape();
        
        tempImgs[(imgIndex + 1) % imgCount].mask(tempFadeOutMasks[maskCount - maskIndex - 1]);
          
        beginShape();
        texture(tempImgs[(imgIndex + 1) % imgCount]);
        vertex(x, y, 0, 0);
        vertex(x + width, y, 1, 0);
        vertex(x + width, y + transValue, 1, 1);
        vertex(x, y + transValue, 0, 1);
        endShape();
        
        if (isLastCol) {
          pushMatrix();
          translate(-(width * 7 + 20), tempHeight);
          
          if (isFirstRow) {
            tempHeight = height;
            tempFadeOutMasks = fadeOutMasks;
            tempFadeInMasks = fadeInMasks;
            tempImgs = imgs;
            transValue = map(maskIndex, 0, maskCount, 0, tempHeight);
            tempImgs[imgIndex].mask(tempFadeInMasks[maskCount - maskIndex - 1]);
            tempImgs[(imgIndex + 1) % imgCount].mask(tempFadeOutMasks[maskCount - maskIndex - 1]);
          }
          
          beginShape();
          texture(tempImgs[imgIndex]);
          vertex(x, y + transValue, 0, 0);
          vertex(x + width, y + transValue, 1, 0);
          vertex(x + width, y + tempHeight, 1, 1);
          vertex(x, y + tempHeight, 0, 1);
          endShape();
          
          beginShape();
          texture(tempImgs[(imgIndex + 1) % imgCount]);
          vertex(x, y, 0, 0);
          vertex(x + width, y, 1, 0);
          vertex(x + width, y + transValue, 1, 1);
          vertex(x, y + transValue, 0, 1);
          endShape();
          
          popMatrix();
        }
      }
      
      maskIndex++;
      if (maskIndex == maskCount) {
        status = 0; // change status to show
        imgIndex = (imgIndex + 1) % imgCount; // change front image index
        maskIndex = 0;
        transitionCount++;
      }
    }
  }

  boolean transition() {
    if (isStop) {
      isRunning = false;
    } else {
      if (isRunning) {
        if (status == 0) {
          isRunning = false;
        }
      } 
      else {
        this.status = 1;
  
        isRunning = true;
      }
    }

    return isRunning;
  }
  
  void transitionStop() {
    isStop = true;
  }
  
  int getImgIndex() {
    return imgIndexes[imgIndex];
  }
  
  void setDirection() {
    if (random(1) > 0.5) {
      isUpside = true;
    } else {
      isUpside = false;
    }
  }
  
  void setFirstRow(float firstRowHeight) {
    this.isFirstRow = true;
    this.firstRowHeight = firstRowHeight;
    
    for(int i = 0; i < imgCount; i++) {
      firstRowImgs[i] = createImage((int)width, (int)firstRowHeight, RGB);
    }
  }
  
  void setLastCol() {
    this.isLastCol = true;
  }

}
