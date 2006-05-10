module Ruboid

  #Represents a flock of boids, which move together according to Reynolds' rules
  class Flock
    attr_accessor :boids, :velocity_limit, :safety_distance, :rebellion
    attr_accessor :separation_factor, :cohesion_factor, :alignment_factor, :goal_factor
        
    include Enumerable

    def initialize(velocity_limit = 10,
                   safety_distance = 30,
                   separation_factor = 1.0,
                   cohesion_factor = 0.01,
                   alignment_factor = 0.125)
                  
      @boids = []  
            
      @velocity_limit = velocity_limit
      @safety_distance = safety_distance
      @separation_factor = separation_factor
      @cohesion_factor = cohesion_factor
      @alignment_factor = alignment_factor
      @goal_factor = goal_factor
      @rebellion = rebellion

      #indicates if the flock must scatter or be grouped
      @flock = 1
      
      @goal=nil
      @goal_factor = 0
      
      @bound_corner1=nil
      @bound_corner2=nil
      @bound_encouragement = nil
      
      @free_will=false
      @rebellion = 0
      
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

    #set a goal for the flock
    def go_to(goal,goal_factor = 0.05)
      @goal = goal
      @goal_factor = goal_factor
    end

    #go back to meaningless wandering
    def forget_goal
      @goal = nil
    end

    #bound the boids
    def bound(corner1,corner2,bound_encouragement = 10)
      @bound_corner1 = corner1
      @bound_corner2 = corner2
      @bound_encouragement = bound_encouragement
    end

    def move_freely
      @bound_corner1 = nil
      @bound_corner2 = nil
      @bound_encouragement = nil
    end

    #degree of 
    def rebel(rebellion = 5)
      @free_will = true
      @rebellion = rebellion
    end

    def calm_down
      @free_will = false
    end

    #Main method of the class : calculates a variation of the velocity of each boid according to the position and velocity of the other boids. Finally update the velocity and the position of each boid.
    def update_and_move
      #calculate the new velocity : keep in a temp variable so all the boids get updated at the same time
      velocity_update = Array.new
      
      #calculate the variation of velocity of the boids
      @boids.each do |boid|
        d_vc = boid.cohesion(@boids).mul(@cohesion_factor * @flock)
        d_vs = boid.separation(@boids,@safety_distance).mul(@separation_factor)
        d_va = boid.alignment(@boids).mul(@alignment_factor)
        
        d_v = d_vc.add(d_vs).add(d_va)
        
        if @goal
          d_vg = boid.go_to(@goal).mul(@goal_factor)
          d_v.add(d_vg)
        end
        
        if @bound_corner1
          d_vb = boid.bound(@bound_corner1,@bound_corner2,@bound_encouragement)
          d_v.add(d_vb)
        end

        if @free_will
          d_vf = Vector.new([rand(@rebellion),rand(@rebellion)])
          d_v.add(d_vf)
        end

        velocity_update << d_v
      end

      #calculate a new velocity, limit the speed and update the position of the boids
      @boids.each_with_index do |boid,index|
        boid.velocity.add(velocity_update[index])
        boid.limit(@velocity_limit)
        boid.move
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

    def dimension
      @position.dimension
    end

    #Move a boid of one step
    def move
      @position.add(@velocity)
    end

    #Limits the velocity of the boid so it doesn't go supersonic.
    def limit(velocity_limit)
      velocity_norm = @velocity.norm
      if velocity_norm > velocity_limit
        @velocity.mul(velocity_limit / velocity_norm)
      end
    end

    def go_to(goal)
      goal.clone.sub(@position)
    end

    def bound(bound_corner1,bound_corner2,bound_encouragement)
      v = Vector.zero(dimension)
      v.each_index do |i|
        if @position[i] < bound_corner1[i]
          v[i] = bound_encouragement[i]
        elsif @position[i] > bound_corner2[i]
          v[i] = -bound_encouragement[i]
        end
      end
      v
    end

    #Moves the boid to the center of mass : Rule 1 of Conrad Parker's pseudo code
    def cohesion(boids)
      perceived_center = Vector.zero(dimension)
      boids.each do |b|
        if b != self
          perceived_center.add(b.position)
        end
      end
      perceived_center.div(boids.length - 1).sub(@position)
    end
    
    #Moves the boid away from the other boids which are too close to it : Rule 2 of Conrad Parker's pseudo code
    def separation(boids,distance)
      c = Vector.zero(dimension)
      boids.each do |b|
        if b != self
          if b.position.distance_to(@position) < distance
            c.add(@position).sub(b.position)
          end
        end
      end
      c
    end
    
    #Modifies the velocity so the boids have the tendency to go in the same direction : Rule 3 of Conrad Parker's pseudo code
    def alignment(boids)
      perceived_velocity = Vector.zero(dimension)
      boids.each do |b|
        if b != self
          perceived_velocity.add(b.velocity)
        end
      end
      perceived_velocity.div(boids.length - 1).sub(@velocity)
    end
    
  end

  

end
