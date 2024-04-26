class Surface
{
  color diffuse_color;
  color spec_color;
  float spec_pow;
  float k_refl;
  float gloss_radius;
  
  Surface(color diffuse_color, color spec_color, float spec_pow, float k_refl, float gloss_radius)
  {
    this.diffuse_color = diffuse_color;
    this.spec_color = spec_color;
    this.spec_pow = spec_pow;
    this.k_refl = k_refl;
    this.gloss_radius = gloss_radius;
  }
}


class Hit
{
  PVector point;
  PVector normal;
  
  Hit(PVector point, PVector normal)
  {
    this.normal = normal;
    this.point = point;
  }
}
