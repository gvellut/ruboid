module Ruboid

  #Represents a flock of boids, which move together according to Reynolds' rules
  class Flock
    attr_accessor :boids,:safety_distance,:position_matching_factor, :velocity_matching_factor, :velocity_limit
    attr_reader :dimension

    include Enumerable

    def initialize(dimension)
      @boids = []  
      @dimension = dimension
      @safety_distance = 10
      @position_matching_factor = 0.10
      @velocity_matching_factor = 0.125
      @velocity_limit = 5

      @flock = 1
    end

    #Adds a boid to the flock
    def <<(boid)
      @boids << boid
    end

    def each
      boids.each {|b| yield b}
    end

    #Scatters the flock, not as a reaction to a particular obstacle, but for example, as a reaction to a loud noise. It will break the cohesion.
    def scatter
      @flock = -1
    end

    #Regroups the flock
    def regroup
      @flock = 1
    end

    #Main method of the class : Updates the velocity of each boid according to the position and velocity of the other boids. Finally updates the position of each boid.
    def update_and_move
      #calculate the new velocity
      match_velocity
      match_position
      avoid_other_boids
      
      #limit velocity
      limit_velocity
      #move the boids
      move
    end
    

    private

    #Updates the position of the boids
    def move
      boids.each {|boid| boid.move}
    end

    #Limits the velocity of the boids so they don't go supersonic.
    def limit_velocity
      boids.each do |boid|
        velocity_norm = boid.velocity.norm
        if velocity_norm > @velocity_limit
          boid.velocity *= @velocity_limit / velocity_norm
        end
      end
    end

    #Moves the boid to the center of mass : Rule 1 of Conrad Parker's pseudo code
    def match_position
      boids.each do |b_current|
        perceived_center = Vector.zero(@dimension)
        boids.each do |b|
          if b != b_current
            perceived_center += b.position
          end
        end
        perceived_center /= (@boids.length - 1)
        b_current.velocity += (perceived_center - b_current.position) * (@position_matching_factor * @flock)
      end
    end

    #Moves the boid away from the other boids which are too close to it : Rule 2 of Conrad Parker's pseudo code
    def avoid_other_boids
      boids.each do |b_current|
        c = Vector.zero(@dimension)
        boids.each do |b|
          if b != b_current
            if b.position.distance_to(b_current.position) < @safety_distance
              #is it += or -= ? I would say += (since you want to move b_current away from b)
              #but the pseudo code says -=
              c+= b_current.position - b.position
            end
          end
        end
        b_current.velocity += c
      end
    end

    #Modifies the velocity so the boids have the tendency to go in the same direction : Rule 3 of Conrad Parker's pseudo code
    def match_velocity
      boids.each do |b_current|
        perceived_velocity = Vector.zero(@dimension)
        boids.each do |b|
          if b != b_current
            perceived_velocity += b.velocity
          end
        end
        perceived_velocity /= (@boids.length - 1)
        b_current.velocity += (perceived_velocity - b_current.velocity) * @velocity_matching_factor
      end
    end
  end

  #Represents a boid : You can think of it as a fish or a bird 
  class Boid
    #position of the boid
    attr_accessor :position
    #distance done by the boid by unit of time chosen by the application using the lib
    attr_accessor :velocity
    
    #the initial parameters of the boid are the responsibility of the calling application
    def initialize(position,velocity)
      @position = position
      @velocity = velocity
    end
    
    #Move a boid of one step
    def move
      @position += @velocity
    end
  end

  #Pure Ruby vector arithmetic class with no checks at all
  #For speed, the NArray library could be considered (but some part is in C)
  #Vectors taking part in operations are assumed to be of the same dimension
  class Vector
    attr_accessor :coords
        
    include Enumerable
    
    def initialize(array)
      @coords = array
    end

    def self.zero(dimension)
      Vector.new(Array.new(dimension,0.0))
    end

    def each
      @coords.each { |c| yield c}
    end
    
    def dimension
      @coords.length
    end

    def [](n)
      @coords[n]
    end

    def []=(n,value)
      @coords[n]=value
    end

    #Calculates the euclidian distance between 2 vectors
    def distance_to(vector)
      diff = self - vector
      distance = diff.inject(0) do |distance_acc,value|
        distance_acc + value**2
      end
      Math.sqrt(distance)
    end

    #Calculates the euclidian norm of the vector
    def norm
      distance_to(Vector.zero(dimension))
    end
    
    #Addition of 2 vectors
    def +(vector)
      result_array = Array.new(dimension)
      @coords.each_index do |i|
        result_array[i] = @coords[i] + vector[i] 
      end
      Vector.new(result_array)
    end

    #Substraction of 2 vectors
    def -(vector)
      result_array = Array.new(dimension)
      @coords.each_index do |i|
        result_array[i] = @coords[i] - vector[i] 
      end
      Vector.new(result_array)
    end

    #Division by a scalar
    def /(scalar)
      result_array = []
      @coords.each do |coord|
        result_array << (coord/scalar)
      end
      Vector.new(result_array)
    end

    #Multiplication by a scalar
    def *(scalar)
      result_array = []
      @coords.each do |coord|
        result_array << (coord*scalar)
      end
      Vector.new(result_array)
    end

    #Tests for the equality of vectors
    def ==(vector)
      @coords.each_index do |i|
        return false if @coords[i] !=  vector[i] 
      end
      true
    end
  end

end
