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
  flock << Boid.new(Vector.new([rand(20)-10,rand(20)-10]),
                    Vector.new([rand(6)-3,rand(6)-3]))
end

puts "Flock t= 0\n" + flock.to_s + "\n"

1.upto(1000) do |i|
  flock.update_and_move
  puts "Flock t= #{i}\n" + flock.to_s + "\n"
end



