module Ruboid
  
  #Pure Ruby simplistic vector arithmetic class with no checks at all
  #For speed, the NArray library could be considered (but some part is in C)
  #Vectors taking part in operations are assumed to be of the same dimension
  class Vector
    attr_accessor :coords
        
    include Enumerable
    
    def initialize(array)
      @coords = array
    end

    def clone
      Vector.new(@coords.clone)
    end

    def self.zero(dimension)
      Vector.new(Array.new(dimension,0.0))
    end
    
    def to_s
      @coords.join(",")
    end

    def each
      @coords.each { |c| yield c}
    end

    def each_index
      0.upto(dimension-1) { |i| yield i}
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
      diff = self.clone.sub(vector)
      distance = diff.inject(0) do |distance_acc,value|
        distance_acc + value**2
      end
      Math.sqrt(distance)
    end

    #Calculates the euclidian norm of the vector
    def norm
      distance_to(Vector.zero(dimension))
    end
    
    def add(vector)
      @coords.each_index do |i|
        @coords[i] += vector[i] 
      end
      self
    end

    def sub(vector)
      @coords.each_index do |i|
        @coords[i] -= vector[i] 
      end
      self
    end

    def div(scalar)
      @coords.each_index do |i|
        @coords[i] /= scalar
      end
      self
    end

    def mul(scalar)
      @coords.each_index do |i|
        @coords[i] *= scalar
      end
      self
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
