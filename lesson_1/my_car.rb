module Loadable
  def load_bed
    puts "Loading the bed..."
  end
end

class Vehicle
  attr_accessor :color, :current_speed
  attr_reader :year, :model

  @@number_of_vehicles = 0

  def initialize(year, color, model)
    @year = year
    @color = color
    @model = model
    @current_speed = 0
    @@number_of_vehicles += 1
  end

  def self.total_number_of_vehicles
    puts "This program has created #{@@number_of_vehicles} vehicles."
  end

  def self.gas_mileage(gallons, miles)
    puts "#{miles/gallons} miles per gallon of gas."
  end

  def speed_check
    puts "You are going #{current_speed} miles per hour."
  end

  def speed_up(number)
    self.current_speed += number
    puts "Vrooom!"
  end

  def brake(number)
    self.current_speed -= number
    puts "Eeeek!"
  end

  def shut_off
    self.current_speed = 0
    puts "Let's put 'er to rest!"
  end

  def spray_paint(new_color)
    self.color = new_color
    puts "Your #{self.model}'s new color is #{self.color}."
  end

  def age
    puts "Your #{self.model} is #{calculate_age} years old."
  end

  private

  def calculate_age
    Time.now.year - self.year
  end

end

class MyCar < Vehicle
  NUMBER_OF_DOORS = 4

end

class MyTruck < Vehicle
  NUMBER_OF_DOORS = 2
  include Loadable
end


lumina = MyCar.new(2012, 'red', 'Chevy Lumina')
# lumina.speed_up(20)
# lumina.speed_check
# lumina.brake(15)
# lumina.speed_check
# lumina.shut_off
# lumina.spray_paint('orange')
# MyCar.gas_mileage(13, 351)
# puts Vehicle.total_number_of_vehicles
# f150 = MyTruck.new('2017', 'blue', 'Ford F150')
# f150.load_bed
# puts "== Vehicle Method Lookup =="
# puts Vehicle.ancestors
# puts "== MyCar Method Lookup =="
# puts MyCar.ancestors
# puts "== MyTruck Method Lookup =="
# puts MyTruck.ancestors
lumina.age

