// Lambda expressions for implicit functions
//
// See the "a_sphere" lambda expression for an example of defining an implicit function

import java.lang.FunctionalInterface;

ArrayList<PVector> rand_offset = new ArrayList<PVector>();
ArrayList<PVector> color_list = new ArrayList<PVector>();


// this is a functional interface that will let us define an implicit function
@FunctionalInterface
interface ImplicitInterface {

  // abstract method that takes (x, y, z) and returns a float
  float getValue(float x, float y, float z);
}
// sphere

ImplicitInterface a_sphere = (x, y, z) -> {
  float d = sqrt (x*x + y*y + z*z);
  return d;
};

//disc
ImplicitInterface disc = (x,y,z) -> {
    float d = a_sphere.getValue(x , y * 2 , z * 5);
    return d;
};

//blobby spheres
ImplicitInterface blobby_spheres = (x,y,z) -> {
    float s1  = a_sphere.getValue(x+0.6 , y+1 , z);
    float s2  = a_sphere.getValue(x-0.6 , y+1 , z);
    float s3  = a_sphere.getValue(x+0.75 , y-1 , z);
    float s4  = a_sphere.getValue(x-0.75 , y-1 , z);
    
    float g1  = wyvill(s1);
    float g2  = wyvill(s2);
    float g3  = wyvill(s3);
    float g4  = wyvill(s4);

    return g1 + g2 + g3 + g4;
};

// random-blobbys

ImplicitInterface random_sphere = (x,y,z) ->{
    FloatList spheres = new FloatList();
    for(int i=0;i<10;i++){
        spheres.append(a_sphere.getValue((x+rand_offset.get(i).x),(y+rand_offset.get(i).y),(z+rand_offset.get(i).z)));
    }

    float d = 0;
    for(int i=0;i<spheres.size();i++){
        d += wyvill(spheres.get(i));
    }
    return d;
};

// line 
ImplicitInterface line = (x,y,z) -> {
    
    PVector p1 = new PVector(-1,0,0);
    PVector p2 = new PVector(1,0,0);
  
    float dq = get_line(x, y, z, p1, p2);

    return dq;
};

// blobby 4 line segment
ImplicitInterface four_lines = (x,y,z) -> {

    PVector c1 = new PVector(-1,1,0);
    PVector c2 = new PVector(1,1,0);
    PVector c3 = new PVector(1,-1,0);
    PVector c4 = new PVector(-1,-1,0);
    
    
    float l1 = get_line(x,y,z,c1,c2);
    float l2 = get_line(x,y,z,c2,c3);
    float l3 = get_line(x,y,z,c3,c4);
    float l4 = get_line(x,y,z,c4,c1);
    
    
    return l1 + l2 + l3 + l4;
};


// taurus

ImplicitInterface taurus = (x,y,z) -> {
    float d = taurus(x,y,z);
    return (d);
};

//taurus chain

ImplicitInterface taurus_chain = (x,y,z) -> {
  
    PVector t1 = RotatePoint(ScalePoint(new PVector(x-1.1,y,z),2,2,2),45);
    PVector t2 = ScalePoint(new PVector(x,y,z),1.8,1.8,1.8);
    PVector t3 = RotatePoint(ScalePoint(new PVector(x+1.1,y,z),1.8,1.8,1.8),-45);
    
    float g1 = wyvill(taurus(t1.x,t1.y,t1.z));
    float g2 = wyvill(taurus(t2.x,t2.y,t2.z));
    float g3 = wyvill(taurus(t3.x,t3.y,t3.z));
    return g1 + g2 + g3;

};

// long line
ImplicitInterface stretch_line = (x,y,z) -> {
  
    PVector p1 = new PVector(-2,0,0);
    PVector p2 = new PVector(2,0,0);
    float d = get_line(x* 1.4 ,y* 1.4 -1 ,z*1.4 ,p1,p2);

    return d;
};

// twist the long line
ImplicitInterface twist_line = (x,y,z) -> {
    float twist_y = y*cos((x*5)) - z*sin((x*5));
    float twist_z = y*sin((x*5)) + z*cos((x*5));

    float d = stretch_line.getValue(x * 1.25, twist_y * 1.25, twist_z * 1.25);

    return (wyvill(d));
};

// taper line
ImplicitInterface taper_line = (x,y,z) -> {

    float k1 = 0.5;
    float k2 = 1.5;
    float xmin = -1.5;
    float xmax = 1.5;
    float tx;
    if(x<xmin)
        tx = 0;
    else if(x>xmax)
        tx = 1;
    else 
      tx = (x - xmin)/(xmax - xmin);
    float kx  = (1-tx)*k1 + tx*k2;

    
    
    PVector p1 = new PVector(-1.5, 0, 0) , p2 = new PVector(1.5, 0, 0);

    float new_y = y/kx;
    float new_z = z/kx;
    
    float d = get_line(x,new_y,new_z, p1,p2);
    return d;
};

// taper twist a line

ImplicitInterface twist_taper_line = (x,y,z) -> {

    float k1 = 0.5;
    float k2 = 1.5;

    float new_y = y*cos((x*3)) - z*sin((x*3));
    float new_z = y*sin((x*3)) + z*cos((x*3));

    float xmin = -1.5;
    float xmax = 1.5;

    float tx = (x - xmin)/(xmax - xmin);

    if(x<xmin){
        tx = 0;
    }
    else if(x>xmax){
        tx = 1;
    }
    
    float kx  = (1-tx)*k1 + tx*k2;
    new_y = new_y/kx;
    new_z = new_z/kx;
    
    PVector p1 = new PVector(-1.5, 0, -1) , p2 = new PVector(1.5, 0, -1);

    float d = get_line(x,new_y,new_z, p1,p2);
    return d;
};

ImplicitInterface saucer = (x,y,z) -> {
    float a1 = a_sphere.getValue(x,y+0.2,z);
    float a2 = a_sphere.getValue(x,y-0.2,z);

    return max(a1,a2);
};

ImplicitInterface sphere_hole = (x,y,z) -> {
    float a1 = a_sphere.getValue(x/2,y/2,z/2);
    PVector p1 = new PVector(-1.5, 0, 0) , p2 = new PVector(1.5, 0, 0);
    float d1 = get_line(x,y,z,p1,p2);

    return max(a1, d1) ;
};


ImplicitInterface sphere_line = (x, y, z) -> {
  
    PVector p1 = new PVector(2, 0, 0);
    PVector p2 = new PVector(-2, 0, 0);
    PVector p3 = new PVector(0, 2, 0);
    PVector p4 = new PVector(0, -2, 0);
    PVector p5 = new PVector(0, 0, 2);
    PVector p6 = new PVector(0, 0, -2);
    
    x *= 2; y *= 2; z *=2;

  
  float l1 = get_line(x, y, z, p1, p2);
  float l2 = get_line(x, y, z, p3, p4);
   float l3 = get_line(x, y, z, p5, p6);
   float sphere = a_sphere.getValue(x / 3, y / 3, z / 3);
   sphere = (sphere>= 0 && sphere < 1 ? wyvill(sphere) : 0);
   
   float fp = l1 + l2 + l3, gp = sphere;
   
   
    //h(p) = (1-t) * f(p) + t * g(p), where 0 <= t <= 1
    
   float hp = ((1 - morph_threshold) * fp) + (morph_threshold * gp);
  
  return hp;

};



float w = random(0,0.1);



// Helper functions to make my life easy
float get_line(float x,float y,float z,PVector p1,PVector p2){
    PVector q = new PVector(x,y,z);
    PVector p = new PVector(0,0,0);
    PVector d = PVector.sub(p2,p1);
    PVector v = PVector.sub(q,p1);

    float t = PVector.dot(d,v)/d.magSq();
    
    if(t<0)
        p = p1;
    else if(t>1)
        p = p2;
    else
        p = PVector.add(p1,PVector.mult(d,t));
        
    float dq = PVector.sub(p,q).magSq();
    return wyvill(dq);
}

float taurus(float x,float y,float z){
  //(x^2 + y^2 + z^2 + R^2 - r^2)^2 - 4R^2 (x^2 + y^2),
     float R = 1.2, r = 0.2;
    float d =  sq( sq(x) + sq(y) + sq(z) + sq(R) - sq(r) ) - 4*sq(R)*(sq(x) + sq(y));
    return d;
}

PVector RotatePoint(PVector point, float angle){
    float cos = cos(radians(angle));
    float sin = sin(radians(angle));
    
    PMatrix3D rotate_mat = new PMatrix3D();
    rotate_mat.set(1, 0, 0, 0,
         0, cos, -sin, 0,
         0, sin, cos, 0,
         0, 0, 0, 1);
    
    float[] source = {point.x , point.y , point.z , 1.0};
    float[] target = new float[4];

    rotate_mat.mult(source, target);

    PVector new_pt = new PVector(target[0],target[1],target[2]);
    return new_pt;
}

PVector ScalePoint(PVector point, float dx, float dy, float dz){
    
    PMatrix3D scale_mat = new PMatrix3D();
    scale_mat.set(dx, 0, 0, 0,
         0, dy, 0, 0,
         0, 0, dz, 0,
         0, 0, 0, 1);
    
    
    float[] target = new float[4];
    float[] source = {point.x,point.y,point.z,1.0};

    scale_mat.mult(source, target );
    
    PVector newPt = new PVector(target[0],target[1],target[2]);
    return newPt;
}

float wyvill(float d){
    float g1 = pow((1-d*d),3);
    float g = max( g1 , 0 );
    return g;
}






























 
