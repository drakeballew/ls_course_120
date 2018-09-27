class Animal
  def initialize(name)
    @name = name
  end

  def speak
    "#{self.name} says arf!"
  end
end

class GoodDog < Animal
  DOG_YEARS = 7

  @@number_of_dogs = 0

  attr_accessor :name, :height, :weight, :age

  def initialize(n, h, w, a)
    super(n)
    self.height = h
    self.weight = w
    self.age = a * DOG_YEARS
    @@number_of_dogs += 1
  end

  def speak
    super + "from GoodDog class"
  end


  def change_info(n, h, w, a)
    self.name = n
    self.height = h
    self.weight = w
    self.age = a * DOG_YEARS
  end

  def info
    "#{self.name} is #{self.age} years old, weighs #{self.weight}, and is #{self.height} tall."
  end

  def self.total_number_of_dogs
    @@number_of_dogs
  end
end

sparky = GoodDog.new('Sparky', '12 inches', '10 lbs', 4)
puts sparky.info
sparky.change_info('Spartacus', '24 inches', '45 lbs', 8)
puts sparky.info
puts sparky.age
puts sparky.speak
bruno = GoodDog.new('Bruno', '14 inches', '5 lbs', 2)
