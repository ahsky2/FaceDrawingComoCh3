/*
float x = 0.0;
NonLinearFunc func;

void setup() {
  size(256, 256, P2D);
  smooth();
  func = new NonLinearFunc(0.0, 0.0, 256.0, 256.0, 1.0);
}

void draw() {
  point(x, height - func.call(x));
  x = x + 0.5;
  
  if (x > width) {
    noLoop();
  }
}
*/

/*
float x = 0.0;
NonLinearFunc func;
float interval = 2.0;
int index = 0;

void setup() {
  size(256, 256, P2D);
  smooth();
  func = new NonLinearFunc(0.0, 0.0, 256.0, 256.0, 1.0);
  func.make(interval);
  
  println(func.count);
}

void draw() {
  println(index);
  point(x + interval * index, height - func.getValue(index));
  index = index + 1;
  if (index > func.count - 1) {
    noLoop();
  }
}
*/

class NonLinearFunc {
  float xMin, yMin;
  float xMax, yMax;
  float factorA, factorB;
  float[] values;
  int count;
  
  NonLinearFunc(float xMin, float yMin, float xMax, float yMax, float factor) {
    super();
    this.xMin = xMin;
    this.yMin = yMin;
    this.xMax = xMax;
    this.yMax = yMax;
    this.factorB = 10 * exp(1.0) * factor;
    this.factorA = (this.yMax/2) / (exp((this.xMax/2) / (this.factorB)) - 1.0);
  }
  
  float call(float x) {
    float y;
    if ( x < xMax/2) {
      y = factorA * (exp(x / factorB) - 1.0);
    } else {
      y = yMax - factorA * (exp((xMax - x) / factorB) - 1.0); 
    }
    
    return y;
  }
  
  int make(float interval) {
    count = int((xMax - xMin) / interval);
    values = new float[count];
    
    for (int i = 0; i < count; i++) {
      values[i] = this.call(i * interval + xMin);
    }
    
    return count;
  }
  
  float getValue(int index) {
    return values[index];
  }
}
