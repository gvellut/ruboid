$:.unshift(File.dirname(__FILE__) + '/../lib')

#I see flying boids!

require 'ruboid'

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

flock = Flock.new(2)

1.upto(10) do |i|
  flock << Boid.new(Vector.new([rand(300),rand(300)]),
                    Vector.new([rand(10)-5,rand(10)-5]))
end

puts "Flock t= 0\n" + flock.to_s + "\n"

1.upto(100) do |i|
  flock.update_and_move
  puts "Flock t= #{i}\n" + flock.to_s + "\n"
end

flock.go_to(Vector.new([0,0]))

101.upto(200) do |i|
  flock.update_and_move
  puts "Flock t= #{i}\n" + flock.to_s + "\n"
end



