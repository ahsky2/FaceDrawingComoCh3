
class PopArt {
  float x;
  float y;
  float width;
  float height;
  int imgCount = 2;
  PImage[] imgs = new PImage[imgCount]; // [front image, back image]
  int imgIndex = 0; // 0 : front image
  int status = 0; // 0 : image showing, 1 : transition

  int fadeInDelayIndex = 0;
  int fadeInDelay = 0;

  float interval = 2.0;
  NonLinearFunc transitionFunc;

  int fadeInIndex = 0;
  int fadeInCount;
  float fadeInAlpha = 0.0;
  int fadeOutIndex = 0;
  int fadeOutCount;
  float fadeOutAlpha = 0.0;

  boolean isRunning = false;

  PopArt (float x, float y, float w, float h) {
    // empty frame
    this.x = x;
    this.y = y;  
    this.width = w;
    this.height = h;
  }

  void setImage(PImage img, boolean isFront) {
    if (isFront) {
      imgs[imgIndex] = img;
      imgIndex = (imgIndex + 1) % imgCount;
    } else {
      imgs[(imgIndex + 1) % imgCount] = img;
    }
  }

  void update() {
    if (status == 1) {
      if (fadeOutIndex < fadeOutCount) {        
        fadeOutAlpha = fadeOut(fadeOutIndex, transitionFunc);
        fadeOutIndex++;
      } 
      else {
        fadeOutAlpha = 0.0;
      }

      if (fadeInDelayIndex < fadeInDelay) {
        fadeInAlpha = 0.0;
        fadeInDelayIndex++;
      } 
      else {
        if (fadeInIndex < fadeInCount) {
          fadeInAlpha = fadeIn(fadeInIndex, transitionFunc);
          fadeInIndex++;
        } 
        else {
          fadeInIndex = 0;

          fadeOutIndex = 0;
          fadeInDelayIndex = 0;

          status = 0; // change status to show
          imgIndex = (imgIndex + 1) % imgCount; // change front image index
        }
      }
    }
  }

  void display() {
    
    translate(x, y);
    fill(255);
    noStroke();
    rect(0, 0, width, height);
//    rotate(PI/2);
    if (status == 0) {
      noTint();
      image(imgs[imgIndex], 0, 0);
    } 
    else {
      tint(255, fadeOutAlpha); // alpha value
      image(imgs[imgIndex], 0, 0);

      tint(255, fadeInAlpha);
      image(imgs[(imgIndex + 1) % imgCount], 0, 0);
    }
    translate(-x, -y);
    
    if (x > 6 * width) {
      translate(x - width * 7 - 20, y + height);
      fill(255);
      noStroke();
      rect(0, 0, width, height);
  //    rotate(PI/2);
      if (status == 0) {
        noTint();
        image(imgs[imgIndex], 0, 0);
      } 
      else {
        tint(255, fadeOutAlpha); // alpha value
        image(imgs[imgIndex], 0, 0);
  
        tint(255, fadeInAlpha);
        image(imgs[(imgIndex + 1) % imgCount], 0, 0);
      }
      translate(-(x - width * 7 - 20), -(y + height));
    }
  }

  boolean transition(int fadeInDelay, NonLinearFunc transitionFunc) {
    if (isRunning) {
      if (status == 0) {
        isRunning = false;
      }
    } 
    else {
      this.fadeInDelay = fadeInDelay;
      this.transitionFunc = transitionFunc;
      fadeInCount = fadeOutCount = transitionFunc.count;

      this.status = 1;

      isRunning = true;
    }

    return isRunning;
  }

  float fadeOut(int index, NonLinearFunc func) {
    return func.getValue(func.count - index - 1);
  }

  float fadeIn(int index, NonLinearFunc func) {
    return func.getValue(index);
  }
}
