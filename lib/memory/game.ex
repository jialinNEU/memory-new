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
    }
  end




  # from old state to new state
  def handle_click(game, index) do
    screen_disabled = game.screen_disabled
    pre_card_idx = game.pre_card_idx
    attempts = game.attempts
    score = game.score

    {new_cards, new_attempts, new_score, new_pre_card_idx}
      = update(index, game.cards, attempts, score, pre_card_idx, screen_disabled)


    %{
      cards: new_cards,
      attempts: new_attempts,
      score: new_score,
      pre_card_idx: new_pre_card_idx,
      screen_disabled: screen_disabled # debug
    }
  end


  def update(index, cards, attempts, score, pre_card_idx, screen_disabled) do
    cond do
      screen_disabled == true -> {cards, attempts, score, pre_card_idx}
      Enum.at(cards, index).match == true -> {cards, attempts, score, pre_card_idx}
      pre_card_idx == index -> {cards, attempts, score, pre_card_idx}

      true -> change_state(index, cards, attempts, score, pre_card_idx)
    end
  end


  def change_state(index, cards, attempts, score, pre_card_idx) do

    new_cards = List.update_at(cards, index, &(Map.put(&1, :flag, true)))
    new_score = score - 5
    new_attempts = attempts + 1

    case rem(new_attempts, 2) do
      0 -> check_state(index, new_cards, new_attempts, new_score, pre_card_idx)
      _ -> {new_cards, new_attempts, new_score, index}
    end

  end

  def check_state(index, cards, attempts, score, pre_card_idx) do

    new_cards_match = List.update_at(cards, index, &(Map.put(&1, :match, true)))
    new_cards_match = List.update_at(new_cards_match, pre_card_idx, &(Map.put(&1, :match, true)))
    new_pre_card_idx = -1
    new_score = score + 25

    new_cards_unmatch = List.update_at(cards, index, &(Map.put(&1, :flag, false)))
    new_cards_unmatch = List.update_at(new_cards_unmatch, pre_card_idx, &(Map.put(&1, :flag, false)))

    card = Enum.at(cards, index)
    pre_card = Enum.at(cards, pre_card_idx)

    task =
      if(card.letter == pre_card.letter) do
        {new_cards_match, attempts, new_score, new_pre_card_idx}
      else
        {new_cards_unmatch, attempts, score, pre_card_idx}
      end

    task
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
