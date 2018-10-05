class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +
                  [[1, 5, 9], [3, 5, 7]]

  attr_reader :squares

  def initialize
    @squares = {}
    reset
  end

  # rubocop:disable Metrics/AbcSize
  def draw
    puts "     |     |     "
    puts "  #{squares[1]}  |  #{squares[2]}  |  #{squares[3]}  "
    puts "     |     |     "
    puts "-----+-----+-----"
    puts "     |     |     "
    puts "  #{squares[4]}  |  #{squares[5]}  |  #{squares[6]}  "
    puts "     |     |     "
    puts "-----+-----+-----"
    puts "     |     |     "
    puts "  #{squares[7]}  |  #{squares[8]}  |  #{squares[9]}  "
    puts "     |     |     "
  end

  # rubocop:enable Metrics/AbcSize
  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  def get_key(square)
    squares.select { |_, v| v == square }.keys.first
  end

  def [](key)
    squares[key].marker
  end

  def []=(key, marker)
    squares[key].marker = marker
  end

  def unmarked_keys
    squares.keys.select { |key| squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  # returns winning marker or nil
  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_markers?(squares)
        return squares.first.marker
      end
    end
    nil
  end

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size < 3
    markers.min == markers.max
  end

  def proactive_move(marker, off_def)
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if opportune_or_risky_square?(squares, marker, off_def)
        return squares.select { |sq| sq.marker == Square::INITIAL_MARKER }.first
      end
    end
    nil
  end

  def opportune_or_risky_square?(squares, cpu_marker, off_def)
    markers = squares.select { |sq| sq.marker == cpu_marker }.collect(&:marker)
    unmarked = squares.select(&:unmarked?).collect(&:marker)
    if off_def == 'O'
      return true if markers.size == 2 && unmarked.size == 1
    elsif off_def == 'D'
      return true if markers.empty? && unmarked.size == 1
    end
    false
  end

  def middle_empty?
    squares[5].unmarked?
  end
end

class Scoreboard
  attr_reader :player1, :player2, :games, :sets

  def initialize(player1, player2)
    @player1 = player1
    @player2 = player2
    @games = {}
    @sets = {}
    reset
  end

  def winning_player(winning_marker)
    games.select { |k, _| k.marker == winning_marker }.keys.first
  end

  def increment_games(winning_player)
    games[winning_player] += 1
  end

  def increment_sets(winning_player)
    sets[winning_player] += 1
  end

  def reset
    reset_games
    reset_sets
  end

  def reset_games
    @games = { player1 => 0, player2 => 0 }
  end

  def reset_sets
    @sets = { player1 => 0, player2 => 0 }
  end

  # rubocop:disable Metrics/AbcSize
  def show
    header = "== #{player1.name} vs #{player2.name} =="
    header_size = header.size
    puts header
    puts "Sets:".center(header_size)
    puts "#{sets[player1]} - #{sets[player2]}".center(header_size)
    puts "Games:".center(header_size)
    puts "#{games[player1]} - #{games[player2]}".center(header_size)
    puts "=" * header_size
    puts ""
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Naming/AccessorMethodName
  def set_won?(player)
    return if games[player] != TTTGame::GAMES_IN_SET
    increment_sets(player)
    games_in_set = TTTGame::GAMES_IN_SET
    puts "#{games.select { |_, v| v == games_in_set }.keys.first.name}" \
         " won the set!"
    reset_games
  end
  # rubocop:enable Naming/AccessorMethodName

  def match_won?
    sets[player1] == TTTGame::SETS_IN_MATCH ||
      sets[player2] == TTTGame::SETS_IN_MATCH
  end

  def match_end_message
    sets_in_match = TTTGame::SETS_IN_MATCH
    puts "#{sets.select { |_, v| v == sets_in_match }.keys.first.name}" \
         " won the match!"
  end
end

class Square
  INITIAL_MARKER = ' '

  attr_accessor :marker

  def initialize(marker=INITIAL_MARKER)
    @marker = marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def marked?
    marker != INITIAL_MARKER
  end

  def to_s
    @marker
  end
end

class Player
  attr_accessor :name, :marker

  def initialize
    @marker = marker
    @name = ''
    set_name
    set_marker
  end
end

class Human < Player
  def set_name
    response = ''
    loop do
      puts "What's your name?"
      response = gets.chomp.strip
      break unless response.empty?
      puts "Invalid entry. Try again."
    end
    self.name = response
    puts ""
    puts "Hi #{name}!"
  end

  def set_marker
    choice = nil
    loop do
      puts "Which marker would you like to play with?"
      choice = gets.chomp
      break unless
        choice.strip.empty? ||
        choice.length > 1 ||
        choice.downcase == 'o'
      if choice.downcase == 'o'
        puts "Sorry, that's the computer's marker. Try again."
      else
        puts "Entries must be exactly 1 character in length. Try again."
      end
    end
    self.marker = choice
  end

  def move(board)
    puts "Choose a square (#{join_or(board.unmarked_keys, ', ', 'or')}): "
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end
    board[square] = marker
  end

  private

  def join_or(arr, delim, conj)
    case arr.size
    when 0 then ''
    when 1 then arr.first
    when 2 then arr.join(" #{conj} ")
    else
      arr[-1] = "#{conj} #{arr.last}"
      arr.join(delim)
    end
  end
end

class Computer < Player
  def set_name
    self.name = ['Hal', 'R2D2', 'Chappie'].sample
  end

  def set_marker
    self.marker = 'O'
  end

  def moves(board)
    if board.proactive_move(marker, 'O')
      board[board.get_key(board.proactive_move(marker, 'O'))] = marker
    elsif board.proactive_move(marker, 'D')
      board[board.get_key(board.proactive_move(marker, 'D'))] = marker
    elsif board.middle_empty?
      board[5] = marker
    else
      board[board.unmarked_keys.sample] = marker
    end
  end
end

class TTTGame
  FIRST_TO_MOVE = :choose
  GAMES_IN_SET = 3
  SETS_IN_MATCH = 2

  attr_reader :board, :human, :computer, :scoreboard
  attr_accessor :current_player

  def play
    match_loop
    display_goodbye_message
  end

  private

  def initialize
    clear_screen
    display_welcome_message

    @board = Board.new
    @computer = Computer.new
    @human = Human.new
    @scoreboard = Scoreboard.new(human, computer)
    @current_player = FIRST_TO_MOVE
    display_rules
    who_goes_first?
  end

  def who_goes_first?
    self.current_player =
      case FIRST_TO_MOVE
      when :choose then choose_first_to_move
      when :human then human
      when :computer then computer
      end
  end

  def choose_first_to_move
    response = ''
    loop do
      puts "Would you like to go first? (y/n)"
      response = gets.chomp
      break if ['y', 'n'].include?(response)
      puts "Invalid entry. Try again."
    end
    response == 'y' ? human : computer
  end

  def match_loop
    loop do
      game_loop
      scoreboard.match_end_message if scoreboard.match_won?
      break unless play_again?
      board_reset
      scoreboard.reset
    end
  end

  def game_loop
    loop do
      if human_turn?
        clear_screen
        display_scoreboard
        display_board
      end
      turn_loop
      update_score
      display_result

      break if scoreboard.match_won?
      break unless play_next_game?
      board_reset
    end
  end

  def turn_loop
    loop do
        current_player_moves
        break if board.full? || board.someone_won?
        clear_screen_and_display_board if human_turn?
      end
  end

  def display_welcome_message
    puts "Welcome to Tic Tac Toe!"
    puts ""
  end

  def display_rules
    puts ""
    puts "Rules before we begin:"
    puts ""
    puts "- Players take turns placing markers."
    puts "- Games are won by placing three markers in a row," \
         " vertically, horizontally, or diagonally."
    puts "- It's #{GAMES_IN_SET} games to win a set and " \
         "#{SETS_IN_MATCH} sets to win a match."
    puts ""
    puts "Good luck!"
    puts ""
  end

  def display_goodbye_message
    puts ""
    puts "Thanks for playing Tic Tac Toe, #{human.name}! Goodbye!"
  end

  def clear_screen
    system 'clear'
    system 'cls'
  end

  def clear_screen_and_display_board
    clear_screen
    display_scoreboard
    display_board
  end

  def display_board
    puts "You are #{human.marker}'s. Computer is #{computer.marker}'s."
    puts ""
    board.draw
    puts ""
  end

  def display_result
    clear_screen_and_display_board

    case board.winning_marker
    when human.marker
      puts "You won!"
    when computer.marker
      puts "#{computer.name} won!"
    else
      puts "It's a tie!"
    end
  end

  def display_scoreboard
    scoreboard.show
  end

  def update_score
    winning_marker = board.winning_marker
    winning_player = scoreboard.winning_player(winning_marker)
    scoreboard.increment_games(winning_player) if winning_player
    scoreboard.set_won?(winning_player)
  end

  def current_player_moves
    if human_turn?
      human.move(board)
      self.current_player = computer
    else
      computer.moves(board)
      self.current_player = human
    end
  end

  def human_turn?
    current_player == human
  end

  def play_again?
    choice = nil
    puts "Play a fresh match? (y/n)"
    loop do
      choice = gets.chomp
      break if ['y', 'n'].include?(choice)
      puts "Invalid choice. Try again."
    end
    return false if choice == 'n'
    true
  end

  def play_next_game?
    choice = nil
    puts "Ready for the next game? (y/n)"
    loop do
      choice = gets.chomp
      break if ['y', 'n'].include?(choice)
      puts "Invalid choice. Try again."
    end
    return false if choice == 'n'
    true
  end

  def board_reset
    board.reset
    self.current_player = who_goes_first?
    clear_screen
  end
end

game = TTTGame.new
game.play
