require 'pry'

class Participant
  attr_accessor :hand, :name

  def initialize
    @hand = []
    @name = set_name
  end

  def hit(deck)
    hand << deck.deal_one
  end

  def stay
  end

  def hand_total(cards)
    ace_total(cards) + non_ace_total(cards)
  end

  def non_ace_total(cards)
    total = 0
    cards.select { |card| card[0] != 'A' }.each do |card|
      total += case card[0]
      when 'J', 'Q', 'K' then 10
      else card[0]
      end
    end
    total
  end

  def ace_total(cards)
    total = 0
    ace_count = cards.select { |card| card[0] == 'A'}.count

    total =

      if ace_count == 1 && non_ace_total(cards) <= 10
        11
      elsif ace_count == 2 && non_ace_total(cards) <= 9
        12
      elsif ace_count == 3 && non_ace_total(cards) <= 8
        13
      elsif ace_count == 4 && non_ace_total(cards) <= 7
        14
      else
        ace_count
      end

    total
  end

  def busted?(cards)
    hand_total(cards) > 21
  end

  def blackjack?(cards)
    hand_total(cards) == 21
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
    loop do
      if blackjack?(hand)
        puts "Blackjack! You win!"
        break
      end
      loop do
        puts "Hit (h) or stay (s)?"
        response = gets.chomp.downcase
        break if ['h', 's'].include?(response)
        puts "Invalid entry. Try again."
      end
      if response == 'h'
        puts "#{name} hits."
        hand << deck.deal_one
      else
        puts "#{name} stays."
        break
      end
       if busted?(hand)
        puts "Busted! Dealer wins!"
        break
      end
    end
  end

end

class Dealer < Participant
  def set_name
    self.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5'].sample
  end


  def hit_or_stay(cards, deck)
    while !busted?(hand) && !blackjack?(hand)
      if hand_total(cards) < 17
        puts "#{name} hits."
        hand << deck.deal_one
      elsif hand_total(cards) > 17 && hand_total(cards) < 21
        puts "#{name} stays."
        break
      end
      if blackjack?(hand)
        puts "Blackjack! #{name} wins!"
      end
      if busted?(hand)
        puts "Busted! You win!"
      end
    end
  end
end

class Deck
  SUITS = ['C', 'D', 'H', 'S']
  CARDS = [2, 3, 4, 5, 6, 7, 8, 9, 10, 'J', 'Q', 'K', 'A']

  attr_accessor :cards

  def initialize
    open_new
  end

  def open_new
    self.cards = CARDS.product(SUITS)
    shuffle_cards
  end

  def shuffle_cards
    cards.shuffle!
  end

  def deal_one
    cards.shift
  end

  def deal_two
    cards.shift(2)
  end
end

class Game
  attr_accessor :deck, :player, :dealer

  def initialize
    self.deck = Deck.new
    self.player = Player.new
    self.dealer = Dealer.new
  end

  def start
    loop do
      clear_screen
      deal_cards
      show_hands

      player_turn
      if player.busted?(player.hand) || player.blackjack?(player.hand)
        show_hands
        if play_again?
          puts "Let's play again."
          reset
          next
        else
          break
        end
      end

      dealer_turn
      if dealer.busted?(dealer.hand) || dealer.blackjack?(dealer.hand)
        show_hands
        if play_again?
          puts "Let's play again."
          reset
          next
        else
          break
        end
      end

      show_result
      if play_again?
        reset
      else
        break
      end

    end
  end

  def deal_cards
    player.hand = deck.deal_two
    dealer.hand = deck.deal_two
  end

  def show_hands
    puts "#{player.name}'s cards:"
    show_cards(player.hand)
    puts "#{dealer.name}'s cards:"
    show_cards(dealer.hand)

  end

  def show_cards(participant_cards)
    participant_cards.each do |card|
      puts "=> #{card}"
    end
  end

  def player_turn
    player.hit_or_stay(deck)
  end


  def dealer_turn
    dealer.hit_or_stay(dealer.hand, deck)
  end

  def compare_hands(player_hand_total, dealer_hand_total)

  end

  def show_result
    player_total = player.hand_total(player.hand)
    dealer_total = dealer.hand_total(dealer.hand)

    show_hands
    if player_total >= dealer_total
      puts "#{player.name} wins, #{player_total} to #{dealer_total}!"
    else
      puts "#{dealer.name}, #{dealer_total} to #{player_total}!"
    end
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

  def reset
    deck.open_new
    player.hand = []
    dealer.hand = []
  end
end

Game.new.start
