abstract class Shape
{
  Surface surface;
  PVector box_min = new PVector(0, 0, 0);
  PVector box_max = new PVector(0, 0, 0);
  
  PVector move_dir = new PVector(0, 0, 0);
  
  Shape(Surface surface)
  {
    this.surface = surface;
  }
  
  public abstract boolean is_point_blocking_light(Ray t_ray, PVector ip, PVector light_position, PMatrix3D C);
  public abstract Hit get_intersection(Ray t_ray, PMatrix3D C);
}

class Instance extends Shape
{
  String name;
  Shape shape;
  PMatrix3D transform_mat ;

  Instance(String name, PMatrix3D transform_mat, Shape shape)
  {
    super(shape.surface);
    this.name = name;
    this.transform_mat = transform_mat;
    this.shape = shape;
  }
  boolean is_point_blocking_light(Ray t_ray, PVector ip, PVector light_position, PMatrix3D C)
  {
    return false;
  }
  
  Hit get_intersection(Ray t_ray, PMatrix3D C)
  {
    return null;
  }
}
