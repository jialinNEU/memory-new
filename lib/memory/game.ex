defmodule Memory.Game do
  def new do
    %{
      cards: init(),
      attempts: 0,
      score: 0,
      pre_card_idx: -1,
      screen_disabled: false,
    }

  end

  def client_view(game) do
    cards = game.cards
    attempts = game.attempts
    score = game.score
    pre_card_idx = game.pre_card_idx
    screen_disabled = game.screen_disabled

    %{
      score: score,
      attempts: attempts,
      pre_card_idx: pre_card_idx,
      cards: cards,
      screen_disabled: screen_disabled
    }
  end




  # from old state to new state
  def handle_click(game, index) do
    screen_disabled = game.screen_disabled
    pre_card_idx = game.pre_card_idx
    attempts = game.attempts
    score = game.score

    {new_cards, new_attempts, new_score, new_pre_card_idx, new_screen_disabled}
    = update(index, game.cards, attempts, score, pre_card_idx, screen_disabled)


    %{
      cards: new_cards,
      attempts: new_attempts,
      score: new_score,
      pre_card_idx: new_pre_card_idx,
      screen_disabled: new_screen_disabled # debug
    }


  end


  def update(index, cards, attempts, score, pre_card_idx, screen_disabled) do
    cond do
      screen_disabled == true -> {cards, attempts, score, pre_card_idx, screen_disabled}
      Enum.at(cards, index).match == true -> {cards, attempts, score, pre_card_idx, screen_disabled}
      pre_card_idx == index -> {cards, attempts, score, pre_card_idx, screen_disabled}

      true -> change_state(index, cards, attempts, score, pre_card_idx)
    end
  end


  def change_state(index, cards, attempts, score, pre_card_idx) do

    new_cards = List.update_at(cards, index, &(Map.put(&1, :flag, true)))
    new_score = score - 5
    new_attempts = attempts + 1
    IO.inspect new_attempts
    {new_pre_card_idx, new_screen_disabled} =
      if rem(new_attempts, 2) == 0 do
        {pre_card_idx, true}
      else
        {index, false}
      end

    {new_cards, new_attempts, new_score, new_pre_card_idx, new_screen_disabled}
  end



  def card_match(game, index) do
    %{ cards: cards, attempts: attempts, score: score, pre_card_idx: pre_card_idx, screen_disabled: screen_disabled} = game

    match_score = score + 25
    match_cards = List.update_at(cards, index, &(Map.put(&1, :match, true)))
    match_cards = List.update_at(match_cards, pre_card_idx, &(Map.put(&1, :match, true)))

    unmatch_cards = List.update_at(cards, index, &(Map.put(&1, :flag, false)))
    unmatch_cards = List.update_at(unmatch_cards, pre_card_idx, &(Map.put(&1, :flag, false)))

    card = Enum.at(cards, index)
    pre_card = Enum.at(cards, pre_card_idx)

    result =
      if (card.letter == pre_card.letter) do
        %{cards: match_cards, attempts: attempts, score: match_score, pre_card_idx: -1, screen_disabled: false}
      else
        %{cards: unmatch_cards, attempts: attempts, score: score, pre_card_idx: -1, screen_disabled: false}
      end

    result
  end


  def init() do
    cards = [
      %{letter: "A", flag: false, match: false, index: 0},
      %{letter: "A", flag: false, match: false, index: 1},
      %{letter: "B", flag: false, match: false, index: 2},
      %{letter: "B", flag: false, match: false, index: 3},
      %{letter: "C", flag: false, match: false, index: 4},
      %{letter: "C", flag: false, match: false, index: 5},
      %{letter: "D", flag: false, match: false, index: 6},
      %{letter: "D", flag: false, match: false, index: 7},
      %{letter: "E", flag: false, match: false, index: 8},
      %{letter: "E", flag: false, match: false, index: 9},
      %{letter: "F", flag: false, match: false, index: 10},
      %{letter: "F", flag: false, match: false, index: 11},
      %{letter: "G", flag: false, match: false, index: 12},
      %{letter: "G", flag: false, match: false, index: 13},
      %{letter: "H", flag: false, match: false, index: 14},
      %{letter: "H", flag: false, match: false, index: 15}
    ]

    Enum.shuffle(cards)
  end
end
