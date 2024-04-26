// This is the starter code for the CS 6491 Ray Tracing project.
//
// The most important part of the code is the interpreter, which will help
// you parse the scene description (.cli) files.
import java.util.*;

boolean debug_flag = false;
int rays_per_pixel = 1;
float fov;
ArrayList<Shape> shapes;
Stack<float[][]> stack= new Stack<>();
ArrayList<Light> lights;
color surface_color;
Surface surface;
ArrayList<PVector> vertices;

color bg_color;
float[][] trans_mat;
Dictionary named_objects = new Hashtable();

Lens lens = new Lens(0, 1);


void setup() {
  size (300, 300);  
  noStroke();
  background (0, 0, 0);
}

void keyPressed() {
  reset_scene();
  switch(key) {
      case '1': interpreter("s01a.cli"); break;
      case '2': interpreter("s02a.cli"); break;
      case '3': interpreter("s03a.cli"); break;
      case '4': interpreter("s04a.cli"); break;
      case '5': interpreter("s05a.cli"); break;
      case '6': interpreter("s06a.cli"); break;
      case '7': interpreter("s07a.cli"); break;
      case '8': interpreter("s08a.cli"); break;
      case '9': interpreter("s09a.cli"); break;
      case '!': interpreter("s01b.cli"); break;
      case '@': interpreter("s02b.cli"); break;
      case '#': interpreter("s03b.cli"); break;
      case '$': interpreter("s04b.cli"); break;
      case '%': interpreter("s05b.cli"); break;
      case '^': interpreter("s06b.cli"); break;
      case '&': interpreter("s07b.cli"); break;
      case '*': interpreter("s08b.cli"); break;
      case '(': interpreter("s09b.cli"); break;
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

    if (token[0].equals("fov")) 
    {
      fov = radians(float(token[1]));
    }
    else if (token[0].equals("lens"))
    {
      float radius = float(token[1]);
      float dist = float(token[2]);
      
      lens = new Lens(radius, dist);
    }
    else if (token[0].equals("background")) 
    {
      float r = float(token[1]);  // this is how to get a float value from a line in the scene description file
      float g = float(token[2]);
      float b = float(token[3]);
      println ("background = " + r + " " + g + " " + b);
      
      bg_color = color(int(r*255), int(g*255), int(b*255));
    }
    else if (token[0].equals("light")) 
    {
      float x = float(token[1]);
      float y = float(token[2]);
      float z = float(token[3]);
      float r = float(token[4]);  
      float g = float(token[5]);
      float b = float(token[6]);
      
      lights.add(new Light(new PVector(x, y, z), color(int(r*255), int(g*255), int(b*255))));
    }
    else if (token[0].equals("disk_light")) 
    {
      float x = float(token[1]);
      float y = float(token[2]);
      float z = float(token[3]);
      
      float radius = float(token[4]);
      
      float dx = float(token[5]);  
      float dy = float(token[6]);
      float dz = float(token[7]);
      
      float r = float(token[8]);
      float g = float(token[9]);
      float b = float(token[10]);
      
      lights.add(new Disk_Light(new PVector(x, y, z), color(int(r*255), int(g*255), int(b*255)),  radius, new PVector(dx, dy, dz)));
      
    }
    else if (token[0].equals("surface")) 
    {
      float r = float(token[1]);  
      float g = float(token[2]);
      float b = float(token[3]);
      
      surface_color = color(int(r*255), int(g*255), int(b*255));
      surface = new Surface(surface_color, color(0, 0, 0), 0, 0, 0);
    }  
    else if (token[0].equals("glossy")) 
    {
      float dr = float(token[1]);  
      float dg = float(token[2]);
      float db = float(token[3]);
      float sr = float(token[4]);  
      float sg = float(token[5]);
      float sb = float(token[6]);
      float spec_pow = float(token[7]);
      float k_refl = float(token[8]);
      float gloss_radius = float(token[9]);
      
      color diffuse_color = color(int(dr*255), int(dg*255), int(db*255));
      color spec_color = color(int(sr*255), int(sg*255), int(sb*255));
      surface = new Surface(diffuse_color, spec_color, spec_pow, k_refl, gloss_radius);
    }  
    else if (token[0].equals("begin")) 
    {
      vertices = new ArrayList<PVector>();
    }
    else if (token[0].equals("vertex")) 
    {
      float x = float(token[1]);  
      float y = float(token[2]);
      float z = float(token[3]);
      PMatrix3D C = new PMatrix3D(trans_mat[0][0], trans_mat[0][1], trans_mat[0][2], trans_mat[0][3],
                                        trans_mat[1][0], trans_mat[1][1], trans_mat[1][2], trans_mat[1][3],
                                        trans_mat[2][0], trans_mat[2][1], trans_mat[2][2], trans_mat[2][3],
                                        trans_mat[3][0], trans_mat[3][1], trans_mat[3][2], trans_mat[3][3]);
      
      PVector res = mat_vect_mult(C,  new PVector(x, y, z));
      vertices.add(res);
 
    }
    else if (token[0].equals("end")) 
    {
      PVector normal = PVector.sub(vertices.get(0), vertices.get(1)).cross(PVector.sub(vertices.get(1), vertices.get(2)));
      float d = -normal.dot(vertices.get(0));
      Triangle t = new Triangle(vertices, surface, normal, d);
      
      shapes.add(t);
    }
    else if (token[0].equals("render")) 
    {
      draw_scene();   // this is where you actually perform the scene rendering
    }
    else if (token[0].equals("read")) 
    {
        interpreter(token[1]);
    }
    else if (token[0].equals("push")) 
    {
        stack.push(trans_mat);
    }
    else if (token[0].equals("pop")) 
    {
        trans_mat = stack.pop();
    }
    else if (token[0].equals("translate")) 
    {
      float tx = float(token[1]);  
      float ty = float(token[2]);
      float tz = float(token[3]);
      
      float[][] tr_matrix = translate_mat(new PVector(tx, ty, tz));
      trans_mat = mat_mult(trans_mat, tr_matrix);
    }
    else if (token[0].equals("rotate")) 
    {
      float angle = radians(float(token[1]));
      float rx = float(token[2]);  
      float ry = float(token[3]);
      float rz = float(token[4]);
      
      float[][] rt_matrix = rotate_mat(angle, new PVector(rx, ry, rz));
      trans_mat = mat_mult(trans_mat, rt_matrix);
    }
    else if (token[0].equals("scale")) 
    {
      float sx = float(token[1]);  
      float sy = float(token[2]);
      float sz = float(token[3]);
      
      float[][] sc_matrix = scale_mat(new PVector(sx, sy, sz));
      trans_mat = mat_mult(trans_mat, sc_matrix);
    }
    else if (token[0].equals("sphere")) 
    {
      float radius = float(token[1]);  
      float x = float(token[2]);
      float y = float(token[3]);
      float z = float(token[4]);
      PMatrix3D C = new PMatrix3D(trans_mat[0][0], trans_mat[0][1], trans_mat[0][2], trans_mat[0][3],
                                        trans_mat[1][0], trans_mat[1][1], trans_mat[1][2], trans_mat[1][3],
                                        trans_mat[2][0], trans_mat[2][1], trans_mat[2][2], trans_mat[2][3],
                                        trans_mat[3][0], trans_mat[3][1], trans_mat[3][2], trans_mat[3][3]);

      Sphere sphere = new Sphere(surface, radius, mat_vect_mult(C, new PVector(x, y, z))); 
      shapes.add(sphere);
    }
    else if (token[0].equals("named_object")) 
    {
      String object_name = token[1];  
      named_objects.put(object_name, shapes.remove(shapes.size() - 1));

    }
    else if (token[0].equals("instance")) 
    {
      String object_name = token[1];  
      
      Shape object = (Shape)named_objects.get(object_name);
      PMatrix3D C = new PMatrix3D(trans_mat[0][0], trans_mat[0][1], trans_mat[0][2], trans_mat[0][3],
                                        trans_mat[1][0], trans_mat[1][1], trans_mat[1][2], trans_mat[1][3],
                                        trans_mat[2][0], trans_mat[2][1], trans_mat[2][2], trans_mat[2][3],
                                        trans_mat[3][0], trans_mat[3][1], trans_mat[3][2], trans_mat[3][3]);
         
      Instance instance = new Instance(object_name, C, object);
      shapes.add(instance);                               
    }
    else if (token[0].equals("lens")) 
    {
      float radius = float(token[1]);
      float dist = float(token[2]);
      lens = new Lens(radius, dist);
      
    }
     else if (token[0].equals("rays_per_pixel"))
    {
      rays_per_pixel = int(token[1]);
    } 
    else if (token[0].equals("moving_object"))
    {
      float dx = float(token[1]);
      float dy = float(token[2]);
      float dz = float(token[3]);

      Shape s = shapes.remove(shapes.size() - 1);

      Instance instance = new Instance("moving_object", new PMatrix3D(), s);
      instance.move_dir = new PVector(dx, dy, dz);

      shapes.add(instance);
    }
    else if (token[0].equals("#")) {
      // comment (ignore)
    }
    else {
      println ("unknown command: " + token[0]);
    }
  }
}



color get_pixel_color(Ray ray, int depth, float time){
  if(depth == 5)
    return color(0, 0, 0);
    
  PVector origin = ray.origin, direction = ray.direction; 
  float min_dist = Float.MAX_VALUE;
  color c = bg_color;
  
  
  PMatrix3D C = new PMatrix3D();
  PMatrix3D inverse_C = new PMatrix3D();
  
  PVector ip = new PVector(), fip = new PVector(), normal = new PVector(), fnormal = new PVector();

  Surface surface = new Surface(color(0, 0, 0), color(0, 0, 0), 0, 0, 0); 
  Surface fsurface = new Surface(color(0, 0, 0), color(0, 0, 0), 0, 0, 0); 

  
  for(int i=0; i<shapes.size(); i++)
  {
    Shape shape = shapes.get(i);

    if(shape instanceof Instance)
    {
      Instance instance = (Instance) shape;
      C = instance.transform_mat.get();
      inverse_C = C.get();
      inverse_C.invert();
      
      PVector time_disp = PVector.mult(instance.move_dir , time);
      
      // inverse transform the ray not the object
      direction = mat_vect_mult(inverse_C , direction);
      origin = new PVector(inverse_C.m03, inverse_C.m13, inverse_C.m23);
      
      origin = PVector.sub(origin, time_disp);
      shape = instance.shape;
    }
    
    Ray t_ray = new Ray(origin, direction);
    Hit h = shape.get_intersection(t_ray, C);
    ip = h.point;
     normal = h.normal;
     surface = shape.surface;

    float hit_dist = PVector.dist(ip, origin);
    
    if(ip.z != Float.MIN_VALUE  && hit_dist > 0.001 &&  hit_dist < min_dist && PVector.dot(PVector.sub(ip, origin), direction) > 0)
    {
       min_dist = hit_dist;
       fip = ip;
       fnormal = normal;
       fsurface = surface;
    }
  }
  
  ip = fip;
  normal = fnormal;
  surface = fsurface;
  
  if(min_dist != Float.MAX_VALUE){
      
      // normalize ray and normal but why?
      float red = 0, green = 0, blue = 0;
      PVector incident_ray = PVector.sub(origin, ip).normalize();
      normal = normal.normalize();
      
      PVector reflected_ray = PVector.sub(PVector.mult(normal, 2 * PVector.dot(incident_ray, normal)), incident_ray);
      
      // take case of reflection and gloss
      /*
        for gloss use randomization and set the magniture of the vector to the radius of the gloss. how to do that? check documentation apparantly there is a method.
        get updated ray for reflection. keep track of reflection
        TODO: check if after 3 reflections if the reflected ray has any effect
      */
      if(surface.gloss_radius != 0)
      {
        PVector gloss_vect = new PVector(random(-1, 1), random(-1, 1), random(-1, 1));
        gloss_vect.setMag(surface.gloss_radius);
        reflected_ray.add(gloss_vect);
      }
      if(surface.k_refl != 0)
      {
        Ray r = new Ray(ip ,  reflected_ray);
        color new_color = get_pixel_color(r, depth + 1, time);
        
        // should I divide by 255 here?
        red += surface.k_refl * red(new_color);
        green += surface.k_refl * green(new_color);
        blue += surface.k_refl * blue(new_color);
      }
      
      for(int j=0; j<lights.size(); j++)
      {
        Light light = lights.get(j);
        PVector light_position = light.vertex.copy();
        
        // generate a random pvector, multiply by radius and add to the dl.vertex this will be light from the disk
        if(light instanceof Disk_Light)
        {
          Disk_Light dl = (Disk_Light) light; 
          PVector rand_vector = new PVector(random(0, 1), random(0, 1), random(0, 1));
          rand_vector = rand_vector.cross(dl.normal).normalize();
          light_position = PVector.add(dl.vertex, PVector.mult(rand_vector, dl.radius));
        }
        // get direction of ray origin hit point and light and hit point normalize ??
        
        PVector light_ray = PVector.sub(light_position, ip).normalize();
        PVector o_ray = PVector.sub(origin, ip).normalize();
        PVector light_origin = PVector.add(light_ray, o_ray).normalize();

        
        if(PVector.dot(normal, o_ray) < 0)
          normal = PVector.mult(normal, -1);
          
        float diff_coeff = max(PVector.dot(light_ray, normal), 0) / 255.0;
        float spec_coeff = max(pow(PVector.dot(light_origin, normal), surface.spec_pow), 0) / 255.0;
        
        if(!is_shadow(light_position, ip, C, time))
        {
          // diffuse * N + spec * N + k_refl * N 
          //remove k_refl part from here and add it to the top because we take reflection into consideration with depth.
          red += red(surface.diffuse_color) * red(light.light_color) * diff_coeff + red(surface.spec_color) * red(light.light_color) * spec_coeff;
          green += green(surface.diffuse_color) * green(light.light_color) *diff_coeff + green(surface.spec_color) * green(light.light_color) * spec_coeff;
          blue += blue(surface.diffuse_color) * blue(light.light_color) * diff_coeff + blue(surface.spec_color) * blue(light.light_color) * spec_coeff;
        }
      }
     c = color(min(red, 255), min(green, 255), min(blue, 255));
   }
  return c;
}

void reset_scene() {
  // reset your scene variables here
  debug_flag = false;
  fov = 0;
  rays_per_pixel = 1;
  lens = new Lens(0, 1);
  bg_color = color(0, 0, 0);
  lights = new ArrayList<Light>();
  shapes = new ArrayList<Shape>();
  trans_mat = new float[][]{{1, 0, 0, 0}, {0, 1, 0, 0}, {0, 0, 1, 0}, {0, 0, 0, 1}};
  stack = new Stack<>();
  stack.push(trans_mat);
 
}

// This is where you should put your code for creating eye rays and tracing them.
void draw_scene() {
  for(int y = 0; y < height; y++) {
    for(int x = 0; x < width; x++) {
      
      // Maybe set debug flag true for ONE pixel.
      // Have your routines (like ray/triangle intersection) 
      // print information when this flag is set.
      debug_flag = false;
      if (x == 150 && y == 150)
        debug_flag = true;

      // create and cast an eye ray in order to calculate the pixel color
      float r = 0, g = 0, b = 0; 
      for(int p=0; p<rays_per_pixel; p++){
        
        float x1 = x + random(0, 1);
        float y1 = y + random(0, 1);
        float time = random(0, 1);
        
        PVector origin = new PVector(random(-lens.radius, lens.radius), random(-lens.radius, lens.radius), 0);
        // z will be constant
        PVector new_d = new PVector(((x1 - width/2) * tan(fov/2)) / (width/2), ((height/2 - y1) * tan(fov/2)) / (height/2), -1);
        PVector direction = PVector.sub(PVector.mult(new_d, lens.dist), origin);
        
        Ray ray = new Ray(origin, direction);
        color pc = get_pixel_color(ray, 1, time);
      
        r += red(pc);
        g += green(pc);
        b += blue(pc);
      }
      // set the pixel color
      color c = color(int(r/rays_per_pixel), int(g/rays_per_pixel), int(b/rays_per_pixel));  // you should use the correct pixel color here
      set (x, y, c);                   // make a tiny rectangle to fill the pixel
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
