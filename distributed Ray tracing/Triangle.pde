class Triangle extends Shape
{
  ArrayList<PVector> vertices = new ArrayList<>();

  PVector normal;
  float  d;
  PVector v1, v2, v0;
  
  Triangle(ArrayList<PVector> vertices, Surface surface, PVector normal, float d)
  {
     super(surface);
     this.vertices = vertices; 
     this.normal = normal;
     this.d = d;
     
     this.v0 = vertices.get(0);
     this.v1 = vertices.get(1);
     this.v2 = vertices.get(2);
     
     this.box_min.x = min(v0.x, min(v1.x, v2.x));
     this.box_min.y = min(v0.y, min(v1.y, v2.y));
     this.box_min.z = min(v0.z, min(v1.z, v2.z));
     
     this.box_max.x = max(v0.x, max(v1.x, v2.x));
     this.box_max.y = max(v0.y, max(v1.y, v2.y));
     this.box_max.z = max(v0.z, max(v1.z, v2.z));
  }
  
  Hit get_intersection(Ray ray, PMatrix3D C)
  {
    PVector t_origin = ray.origin, t_direction = ray.direction;
    PVector normal = this.normal.copy();
    float d = this.d;
    Hit hit = new Hit(new PVector(Float.MIN_VALUE, Float.MIN_VALUE, Float.MIN_VALUE), new PVector(Float.MIN_VALUE, Float.MIN_VALUE, Float.MIN_VALUE));
    
    PMatrix3D inverse_C = C.get();
    inverse_C.invert();
    inverse_C.transpose();
    // p + td
    float t = (d + normal.dot(t_origin)) / (normal.dot(t_direction));
    PVector hit_pt = PVector.add(t_origin , PVector.mult(t_direction, -t));
    
    PVector a = PVector.sub(v1, v0).cross(PVector.sub(hit_pt, v0));
    PVector b = PVector.sub(v2, v1).cross(PVector.sub(hit_pt, v1));
    PVector c = PVector.sub(v0, v2).cross(PVector.sub(hit_pt, v2));
    
    if(PVector.dot(a, b)/(a.mag()*b.mag()) >= 0 && PVector.dot(b, c)/(b.mag()*c.mag()) >= 0 && PVector.dot(c, a)/(c.mag()*a.mag()) >= 0)
    {
      
      hit_pt = mat_vect_mult(C , hit_pt);
      normal = mat_vect_mult(inverse_C , normal);
      
      hit.point = hit_pt;
      hit.normal = normal;
      return hit;
    }
          
    return hit;
  }
  
  boolean is_point_blocking_light(Ray ray, PVector ip, PVector light_position, PMatrix3D C)
  {
      Hit hit = get_intersection(ray, C);
      if(hit.point.x == Float.MIN_VALUE && hit.point.y == Float.MIN_VALUE && hit.point.z == Float.MIN_VALUE)
        return false;
      
      float point_dist = hit.point.dist(light_position);
      float ip_dist = ip.dist(light_position);
      
      
      if(ip_dist - point_dist > 0.001){       
          return true;
      }
    return false;
  }
  
}
