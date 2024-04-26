class Ray
{
  PVector origin, direction;
  
  Ray(PVector origin, PVector direction)
  {
    this.origin = origin;
    this.direction = direction;
  }
  
}

boolean is_shadow(PVector light_position, PVector ip, PMatrix3D C, float time) {
  for(int i=0; i<shapes.size(); i++){
      
    Shape shape = shapes.get(i);
    PVector direction = PVector.sub(ip, light_position);
    PVector origin = light_position;

      
    // TODO: remove boolean variable, set move_dir to 0
    PVector time_disp = PVector.mult(shape.move_dir, time);
    origin = PVector.sub(origin, time_disp);
    light_position = PVector.sub(light_position, time_disp);

    
    Ray t_ray = new Ray(origin, direction);
    if(shape.is_point_blocking_light(t_ray, ip, light_position, C))
      return true;
  }
  return false;
}
