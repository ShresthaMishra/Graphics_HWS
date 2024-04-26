class Light {
  PVector vertex;
  color light_color;
  
  Light(PVector vertex, color light_color){
      this.vertex = vertex;
      this.light_color = light_color;
  }
}

class Disk_Light extends Light {
  float radius;
  PVector normal;
  
  Disk_Light(PVector vertex, color light_color, float radius, PVector normal){
    super(vertex, light_color);
    this.radius = radius;
    this.normal = normal;
    
  }
}
