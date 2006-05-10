$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'RMagick'
require 'ruboid'

include Magick
include Ruboid

Flock.class_eval do 
  def to_s
    res = ""
    @boids.each_index do |i|
      res += "[#{i+1}] " + @boids[i].position.coords.join(", ") + "\n"
    end
    res
  end
end

animation = ImageList.new

flock = Flock.new
1.upto(10) do |i|
  flock << Boid.new(Vector.new([rand(300),rand(300)]),
                    Vector.new([rand(10)-5,rand(10)-5]))
end

flock.bound(Vector.new([10,10]),Vector.new([290,290]),10)

1.upto(10) do |step|

  1.upto(10) do |i|
    flock.update_and_move
    
    image = Image.new(300,300)
    circle = Magick::Draw.new
    circle.stroke('red')
    
    flock.boids.each do |boid|
      circle.ellipse(boid.position[0],boid.position[1],5,5,0,360)
    end
    
    circle.draw(image)
    animation << image
    
  end

  if rand(10)>5
    flock.scatter
  else
    flock.regroup
  end

  flock.go_to(Vector.new([rand(250)+25,rand(250)+25]))

end


animation.write("ruboid.gif")
