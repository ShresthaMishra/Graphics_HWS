class Sphere extends Shape
{
  float radius;
  PVector center;
  
  Sphere(Surface surface, float radius, PVector center){
    super(surface);
    this.radius = radius;
    this.center = center;
  }
  
  Hit get_intersection(Ray ray, PMatrix3D C)
  {
    PVector t_origin = ray.origin, t_dir = ray.direction;
    PMatrix3D inverse_C = C.get();
    inverse_C.invert();
    
    
    Hit hit = new Hit(new PVector(Float.MIN_VALUE, Float.MIN_VALUE, Float.MIN_VALUE), new PVector(Float.MIN_VALUE, Float.MIN_VALUE, Float.MIN_VALUE));
    
    float a = t_dir.magSq();
    float b = 2 * t_dir.dot(PVector.sub(t_origin , center));
    float c = t_origin.magSq() + center.magSq() - radius * radius - 2*(t_origin.dot(center));
    
   if(b*b - 4*a*c < 0)
      return hit;
      
    float r1 = (-b + sqrt(b*b - 4*a*c))/(2*a);
    float r2 = (-b - sqrt(b*b - 4*a*c))/(2*a);
    
    PVector p1 = PVector.add(t_origin, PVector.mult(t_dir, r1));
    PVector p2 = PVector.add(t_origin, PVector.mult(t_dir, r2));
    
    if(PVector.dist(t_origin, p1) < PVector.dist(t_origin, p2))
        hit.point = p1;
    else 
        hit.point = p2;
    
    PMatrix3D inverse_C_transpose = inverse_C.get();
    inverse_C_transpose.transpose(); 
    
    PVector normal = PVector.sub(hit.point, center);
    hit.normal = mat_vect_mult(inverse_C_transpose ,  normal);
    
                           
    hit.point = mat_vect_mult(C, hit.point);
    return hit;
  }
  
  boolean is_point_blocking_light(Ray ray, PVector hit_point, PVector light_position, PMatrix3D C){
     
    Hit hit = get_intersection(ray, C);
    if(hit.point.x == Float.MIN_VALUE && hit.point.y == Float.MIN_VALUE && hit.point.z == Float.MIN_VALUE)
      return false;
    
    float point_dist = hit.point.dist(light_position);   
    float hit_dist = hit_point.dist(light_position);
    
    if(hit_dist - point_dist > 0.01)
      return true;

      return false;
  }

}
