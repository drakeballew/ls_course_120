require 'pry'

class Card
  attr_reader :value, :suit

  SUITS = ['C', 'D', 'H', 'S']
  VALUES = [2, 3, 4, 5, 6, 7, 8, 9, 10, 'J', 'Q', 'K', 'A']

  def initialize(suit, value)
    @suit = suit
    @value = value
  end

  def to_s
    "#{value}#{suit}"
  end

  def ace?
    value == 'A'
  end

  def king?
    value == 'K'
  end

  def queen?
    value == 'Q'
  end

  def jack?
    value == 'J'
  end
end

class Deck
  attr_accessor :cards

  def initialize
    new_deck
    shuffle_cards
  end

  def new_deck
    self.cards = []
    Card::SUITS.each do |suit|
      Card::VALUES.each do |value|
        cards << Card.new(suit, value)
      end
    end
    shuffle_cards
  end

  def shuffle_cards
    cards.shuffle!
  end

  def deal_one
    cards.pop
  end
end

module Hand
  def busted?
    total > 21
  end

  def blackjack?
    total == 21
  end

  def total
    total = 0
    hand.each do |card|
      if card.ace?
        total += 11
      elsif card.jack? || card.queen? || card.king?
        total += 10
      else
        total += card.value
      end
    end

    hand.select(&:ace?).count.times do
      break if total <= 21
      total -= 10
    end

    total
  end

  def show_hand
    puts "---- #{name}'s Hand ----"
    hand.each do |card|
      puts "=> #{card}"
    end
    puts "Total: #{total}"
    puts ""
  end

  def add_card(new_card)
    hand << new_card
  end
end

class Participant
  include Hand

  attr_accessor :name, :hand

  def initialize
    @hand = []
    set_name
  end
end

class Player < Participant
  def set_name
    response = ''
    loop do
      puts "What's your name?"
      response = gets.chomp.strip
      break unless response.empty?
      puts "Invalid entry. Try again."
    end
    self.name = response
  end

  def hit_or_stay(deck)
    response = ''

    puts "#{name}'s turn..."
    loop do
      if blackjack?
        break
      else
        loop do
          puts "Hit (h) or stay (s)?"
          response = gets.chomp
          break if ['h', 's'].include?(response)
          puts "Invalid entry. Try again."
        end
        if response == 's'
          puts "#{name} stays."
          break
        else
          add_card(deck.deal_one)
          show_hand
          break if busted?
        end
      end
    end
  end
end

class Dealer < Participant
  def set_name
    self.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5'].sample
  end

  def show_flop
    puts "---- #{name}'s Hand ----"
    puts "#{hand[0]}"
    puts "??"
    puts ""
  end

  def hit_or_stay(deck)
    puts "#{name}'s turn..."

    while !busted? && !blackjack?
      if total < 17
        puts "#{name} hits."
        add_card(deck.deal_one)
      elsif total > 17 && total < 21
        puts "#{name} stays."
        break
      end
    end
  end
end


class Game
  attr_accessor :player, :dealer, :deck

  def initialize
    clear_screen
    self.deck = Deck.new
    self.player = Player.new
    self.dealer = Dealer.new
  end

  def start
    loop do
      clear_screen
      deal_cards
      show_flop
      player_turn
      if player.blackjack? || player.busted?
        declare_winner
        break if !play_again?
        reset
        next
      end

      dealer_turn
      if dealer.blackjack? || dealer.busted?
        dealer.show_hand
        declare_winner
        break if !play_again?
        reset
        next
      end

      show_cards
      declare_winner
      break unless play_again?
      reset
    end
    puts "Thanks for playing Twenty One, #{player.name}!"
  end

  def deal_cards
    2.times do
      player.add_card(deck.deal_one)
      dealer.add_card(deck.deal_one)
    end
  end

  def declare_winner
    if player.blackjack?
      puts "Blackjack! #{player.name} wins!"
    elsif player.busted?
      puts "#{player.name} busted! #{dealer.name} wins!"
    elsif dealer.blackjack?
      puts "Blackjack! #{dealer.name} wins!"
    elsif dealer.busted?
      puts "#{dealer.name} busted! #{player.name} wins!"
    elsif dealer.total <= player.total
      puts "#{player.name} wins, #{player.total} to #{dealer.total}!"
    else
      puts "#{dealer.name} wins, #{dealer.total} to #{player.total}!"
    end
  end

  def player_turn
    player.hit_or_stay(deck)
  end

  def dealer_turn
    dealer.hit_or_stay(deck)
  end

  def reset
    deck.new_deck
    player.hand = []
    dealer.hand = []
  end

  def play_again?
    choice = nil
    loop do
      puts "Play again? (y/n)"
      choice = gets.chomp.downcase
      break if ['y', 'n'].include?(choice)
    end
    choice == 'y'
  end

  def clear_screen
    system 'clear'
    system 'cls'
  end

  def show_flop
    player.show_hand
    dealer.show_flop
  end

  def show_cards
    player.show_hand
    dealer.show_hand
  end
end

Game.new.start
