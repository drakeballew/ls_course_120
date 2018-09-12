class Pet
  def jump
    'jumping!'
  end
end

class Dog < Pet
end

class Cat < Pet
end

class Bulldog < Dog
end

class Person
  attr_accessor :name, :pets

  def initialize(name)
    @name = name
    @pets = []
  end
end

bob = Person.new('Robert')

kitty = Cat.new
bud = Bulldog.new

bob.pets << kitty
bob.pets << bud

p bob.pets.each { |pet| puts pet.jump }
