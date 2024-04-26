// This is the starter code for the CS 6491 Ray Tracing project.
//
// The most important part of the code is the interpreter, which will help
// you parse the scene description (.cli) files.
import java.util.Stack;
import java.util.ArrayList;
import java.util.Arrays;

boolean debug_flag = false;
float fov,k;
Color bgColor;

ArrayList<Light> lights = new ArrayList<>();
ArrayList<Triangle> triangles = new ArrayList<>();
ArrayList<Surface> surfaces = new ArrayList<>();
ArrayList<PVector> pts;
Stack<float[][]> stack = new Stack<>();


void setup() {
  size (300, 300);  
  noStroke();
  background (0, 0, 0);
}

void keyPressed() {
  reset_scene();
  switch(key) {
    case '1': interpreter("s1.cli"); break;
    case '2': interpreter("s2.cli"); break;
    case '3': interpreter("s3.cli"); break;
    case '4': interpreter("s4.cli"); break;
    case '5': interpreter("s5.cli"); break;
    case '6': interpreter("s6.cli"); break;
  }
}

// this routine parses the text in a scene description file
void interpreter(String file) {
  
  println("Parsing '" + file + "'");
  String str[] = loadStrings (file);
  if (str == null) println ("Error! Failed to read the file.");
  
    for (int i = 0; i < str.length; i++) {
    
    String[] token = splitTokens (str[i], " ");   // get a line and separate the tokens
    if (token.length == 0) continue;              // skip blank lines

    if (token[0].equals("fov")) {
      fov = PApplet.parseFloat(token[1]);
      k =  (float)Math.tan(Math.toRadians(fov/2));
      println("fov:" + fov);
    }
    else if (token[0].equals("background")) {
      //TODO: color is suppose to be from 0 - 255 but given values are in decimal
      bgColor = new Color(PApplet.parseFloat(token[1]), PApplet.parseFloat(token[2]), PApplet.parseFloat(token[3]));
    }
    else if (token[0].equals("light")) {
      float x = PApplet.parseFloat(token[1]);
      float y = PApplet.parseFloat(token[2]);
      float z = PApplet.parseFloat(token[3]);
      PVector vector = new PVector(x, y, z);
      float r = PApplet.parseFloat(token[4]);
      float g = PApplet.parseFloat(token[5]);
      float b = PApplet.parseFloat(token[6]);
      Color colour = new Color(r,g,b);
      Light light = new Light(vector, colour);
      lights.add(light);
    }
    else if (token[0].equals("surface")) {
      float dr = PApplet.parseFloat(token[1]);
      float dg = PApplet.parseFloat(token[2]);
      float db = PApplet.parseFloat(token[3]);
      
      surfaces.add(new Surface(new Color(dr, dg, db)));
    }    
    else if (token[0].equals("begin")) {

      pts = new ArrayList<>();
      
    }
    else if (token[0].equals("vertex")) {
      
        float v1 = PApplet.parseFloat(token[1]);
        float v2 = PApplet.parseFloat(token[2]);
        float v3 = PApplet.parseFloat(token[3]);
        float[][] vector = new float[][]{{v1}, {v2}, {v3}, {1f}};


        float[][] res = multiply(stack.peek(),vector);
//        print("vertex:" + " " + res[0][0] + ":" + res[1][0] + ":" + res[2][0]);
        pts.add(new PVector(res[0][0], res[1][0], res[2][0]));
    }
    else if (token[0].equals("end")) {
      triangles.add(new Triangle(pts.get(0), pts.get(1), pts.get(2), surfaces.get(surfaces.size() - 1)));
    }
    else if(token[0].equals("scale"))
    {
      float x = PApplet.parseFloat(token[1]);
      float y = PApplet.parseFloat(token[2]);
      float z = PApplet.parseFloat(token[3]);
      float[][] scaleMatrix = getScaleMatrix(x, y, z);
      stack.push(multiply(stack.pop() , scaleMatrix));
    }
    else if(token[0].equals("translate"))
    {

      float x = PApplet.parseFloat(token[1]);
      float y = PApplet.parseFloat(token[2]);
      float z = PApplet.parseFloat(token[3]);
      float[][] scaleMatrix = getTranslationMatrix(x, y, z);
      stack.push(multiply(stack.pop() , scaleMatrix));
    }
    else if(token[0].equals("rotate"))
    {
      float angle = (float) Math.toRadians(PApplet.parseFloat(token[1]));
      float x = PApplet.parseFloat(token[2]);
      float y = PApplet.parseFloat(token[3]);
      float z = PApplet.parseFloat(token[4]);
      float[][] rotateMat = new float[4][4];
      if(x == 1.0f)
      {
         rotateMat = getRotXMatrix(angle);

      }else if(y == 1.0f)
      {
        rotateMat = getRotYMatrix(angle);
      }
      else if(z == 1.0f)
      {
        rotateMat = getRotZMatrix(angle);
      }
      stack.push(multiply(stack.pop(), rotateMat));
    }
    else if (token[0].equals("render")) {
      draw_scene();   // this is where you should perform the scene rendering
    }
    else if (token[0].equals("read")) {
      interpreter (token[1]);
    }
    else if(token[0].equals("push"))
    {
      stack.push(copyMatrix(stack.peek()));
    }
    else if(token[0].equals("pop"))
    {
      stack.pop();
    }
    else if (token[0].equals("#")) {
      // comment (ignore)
    }
    else {
      println ("unknown command: " + token[0]);
    }
  }
}

void reset_scene() {
    // reset your scene variables here
    debug_flag = false;
  
    lights.clear();
    surfaces.clear();
    triangles.clear();
    stack.clear();
    stack.push(getIdentityMatrix());
  
    bgColor = null;
    k = 0;
}

public float[][] multiply(float[][] mat1, float[][] mat2)
{
  int r1 = mat1.length;
  int c1 = mat1[0].length;
  int c2 = mat2[0].length;

  float[][] result = new float[r1][c2];

  for (int i = 0; i < r1; i++) {
    for (int j = 0; j < c2; j++) {
      for (int k = 0; k < c1; k++) {
        result[i][j] += mat1[i][k] * mat2[k][j];
      }
    }
  }

  return result;

}



// This is where you should put your code for creating eye rays and tracing them.
public void draw_scene() {
  for(int y = 0; y < height; y++) {
    for(int x = 0; x < width; x++) {

      float xPrime = (x - width / 2f) * (2 * k / width);
      float yPrime = -(y - height / 2f) * (2 * k / height);

      Ray ray = new Ray(new PVector(0, 0, 0), new PVector(xPrime, yPrime, -1));

      Hit hitDetails = getHitDetails(ray);
      Color c = new Color(0, 0, 0);

      if(hitDetails == null) c = bgColor;
      else
      {
//          Color diffuse = new Color(0, 0, 0);
          for(Light light : lights)
          {
            PVector l = PVector.sub(light.vertex, hitDetails.vertex).normalize();
            PVector n = hitDetails.triangle.normal.copy().normalize();

            Ray shadowRay = new Ray(hitDetails.vertex, PVector.sub(light.vertex, hitDetails.vertex));
//            Ray shadowRay = new Ray(hitDetails.vertex, l);
            boolean isShadowIntersecting = false;

            for(Triangle t : triangles)
            {
              if(t.equals(hitDetails.triangle)) {continue;}
//             shadow.vertex -> hit.vertex > light - > hit
              PVector intersection = t.getIntersection(shadowRay);
              if( intersection!= null  && intersection.dist(hitDetails.vertex) < light.vertex.dist(hitDetails.vertex) ) isShadowIntersecting = true;
            }

            if(isShadowIntersecting)
            {
              continue;
            }

            float dotProd = Math.abs(n.dot(l));
            var dr = c.r + light.colour.r * dotProd * hitDetails.triangle.surface.colour.r;
            var dg = c.g + light.colour.g * dotProd * hitDetails.triangle.surface.colour.g;
            var db = c.b + light.colour.b * dotProd * hitDetails.triangle.surface.colour.b;

            //  MAtrix class -> List<List<float>> 2d matrix
            // IDENTITY MATRIX, copy constructor, transform, matrix multiplication, matrixPVEctor multiplication
            // Stack store matrices

            c = new Color(dr, dg, db);
            //println(c);
          }
      }
      //TODO: check if color accepts range in float or do we need to bring it in 0-255
      set(x, y, color(c.r*255, c.g* 255, c.b* 255));
    }
  }
}


// prints mouse location clicks, for help in debugging
void mousePressed() {
  println ("You pressed the mouse at " + mouseX + " " + mouseY);
}

// you don't need to add anything in the "draw" function for this project
void draw() {
}


public float[][] copyMatrix(float[][] mat)
{
  int m = mat.length, n = mat[0].length;
  float[][] res = new float[m][n];
  for(int i = 0; i< m; i++)
  {
    res[i] = Arrays.copyOf(mat[i], mat[i].length);
  }
  return res;
}

public float[][] getIdentityMatrix()
{
  float[][] matrix = new float[][]{{1f, 0f, 0f, 0f}, {0f, 1f, 0f, 0f}, {0f, 0f, 1f, 0f}, {0f, 0f, 0f, 1f}};
  return matrix;

}
public float[][] getScaleMatrix(float x, float y, float z)
{
  float[][] matrix = new float[][]{{x, 0f, 0f, 0f}, {0f, y, 0f, 0f}, {0f, 0f, z, 0f}, {0f, 0f, 0f, 1f}};
  return matrix;

}

public float[][] getTranslationMatrix(float x, float y, float z)
{
  float[][] matrix = new float[][]{{1f, 0f, 0f, x}, {0f, 1f, 0f, y}, {0f, 0f, 1f, z}, {0f, 0f, 0f, 1f}};
  return matrix;
}

public float[][] getRotZMatrix(float angle)
{
  float[][] matrix = new float[][]{{cos(angle), -sin(angle), 0f, 0f}, {sin(angle), cos(angle), 0f, 0f}, {0f, 0f, 1f, 0f}, {0f, 0f, 0f, 1f}};
  return matrix;
}

public float[][] getRotXMatrix(float angle)
{
  float[][] matrix = new float[][]{{1f, 0f, 0f, 0f}, {0f, cos(angle), -sin(angle), 0f}, {0f, sin(angle), cos(angle), 0f}, {0f, 0f, 0f, 1f}};
  return matrix;
}
public float[][] getRotYMatrix(float angle)
{
  float[][] matrix = new float[][]{{cos(angle), 0f, sin(angle), 0f}, {0f, 1f,0f, 0f}, {-sin(angle), 0f, cos(angle), 0f}, {0f, 0f, 0f, 1f}};
  return matrix;
}

public Hit getHitDetails(Ray ray)
{
  var minDist = Float.MAX_VALUE;
  Hit hit = null;
  for(Triangle triangle : triangles) {
    PVector pt = triangle.getIntersection(ray);
    if(pt == null) continue;
    float dist = ray.origin.dist(pt);
    if(dist < minDist)
    {
      minDist = dist;
      hit = new Hit(pt, triangle);
    }
  }
  return hit;
}

class Hit
{
  public PVector vertex;
  public Triangle triangle;

  public Hit(PVector vertex, Triangle triangle)
  {
    this.vertex = vertex;
    this.triangle = triangle;
  }
}

 class Color{
  public float r, g, b;
  public Color(float r,float g, float b)
  {
    this.r = r;
    this.g = g;
    this.b = b;
  }
}

class Light
{
  PVector vertex;
  Color colour;
  public Light(PVector vertex, Color colour)
  {
    this.vertex = vertex;
    this.colour = colour;

  }
}

class Triangle
{
  public PVector v1, v2, v3, ab, bc, ac, normal;
  public Surface surface;
  float d;

  
  public Triangle(PVector v1, PVector v2, PVector v3, Surface surface)  {
    this.v1 = v1;
    this.v2 = v2;
    this.v3 = v3;
    this.surface = surface;
    this.ab = PVector.sub(v2 , v1);
    this.bc = PVector.sub(v3 , v2);
    this.ac = PVector.sub(v3 , v1);
    this.normal = ab.cross(ac);
    this.d = -normal.dot(v1);
  }


  PVector getIntersection(Ray ray) {
    var t = -(normal.dot(ray.origin) + d) / normal.dot(ray.direction);
    if (t < 0) return null;
    PVector pt = PVector.add(ray.origin, PVector.mult(ray.direction, t));
    
    PVector ap = PVector.sub(pt, v1);
    PVector bp = PVector.sub(pt, v2);
    PVector cp = PVector.sub(pt, v3);
    
    return normal.dot(ab.cross(ap)) >= 0 &&
            normal.dot(bc.cross(bp)) >= 0 &&
            normal.dot(PVector.mult(ac, -1).cross(cp)) >= 0 ? pt : null;
  }



}

class Ray{
  PVector origin;
  PVector direction;

  public Ray(PVector origin, PVector direction)
  {
    this.origin = origin;
    this.direction = direction;
  }
}

class Surface
{
  public Color colour;
  
  public Surface(Color colour)
  {
    this.colour = colour;
  }
}
