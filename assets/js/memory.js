import React from 'react';
import ReactDOM from 'react-dom';
import { Button } from 'reactstrap';

export default function game_init(root, channel) {
  ReactDOM.render(<Memory channel={channel} />, root);
}


class Memory extends React.Component {


  /**
  channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp); })
    .receive("error", resp => { console.log("Unable to join", resp); });

  */

  constructor(props) {
    super(props);

    this.channel = props.channel;

    this.channel.join()
      .receive("ok", this.gotView.bind(this))
      .receive("error", resp => { console.log("Unable to join", resp); });


    this.state = {
      attempts: 0,
      score: 0,
      pre_card_idx: -1,
      cards: [],
      screen_disabled: false
    }
  }



  gotView(msg) {
    console.log("Got View", msg);
    this.setState(msg.view);
    console.log(this.state);
  }

/*
  update_score(points) {
    let preScore = this.state.score;
    this.setState({
      score: preScore + points
    });
  }
*/

  user_click(index) {
    this.channel.push("user_click", { index: index} )
        .receive("ok", this.gotView.bind(this));
  }

/*
  handle_click(index) {

    let cards = this.state.cards;
    let pre_card_idx = this.state.pre_card_idx;
    let attempts = this.state.attempts;
    let screen_disabled = this.state.screen_disabled;

    if(cards[index].match) {
      return;
    }

    if(pre_card_idx == index) {
      return;
    }

    if(this.cal_open_cards() == 2) {
      return;
    }

    if(screen_disabled) {
      return;
    }

    this.update_score(-5);
    cards[index].flag = true;
    attempts = attempts + 1;

    this.setState({
      cards: cards,
      attempts: attempts
    })




console.log(attempts);

    if(attempts % 2 == 0) {

      let pre_card = cards[pre_card_idx];
      let card = cards[index];

      console.log(pre_card);

      if(card.letter === pre_card.letter) {

        screen_disabled = true
        setTimeout( () => {
          pre_card["match"] = true;
          card["match"] = true;
          this.update_score(25);
          this.setState({
            cards: cards,
            pre_card_idx: -1,
            screen_disabled:false
          });
        }, 1000);
      }

      else {
        screen_disabled = true;
        setTimeout( () => {
          card["flag"] = false;
          pre_card["flag"] = false;
          this.setState({
            cards: cards,
            pre_card_idx: -1,
            screen_disabled: false
          });

        }, 1000);
      }
    }

    else {
      this.setState({
        pre_card_idx: index
      });
    }
  }
*/

/*
  cal_open_cards() {
    let cards = this.state.cards;
    let openCards = _.filter(cards, (card) => {
      card["flag"] == true && card["match"] == false
    })
    return openCards.length;
  }
*/

  restart() {

    /*
    this.setState({
      attempts: 0,
      score: 0,
      pre_card_idx: -1,
      cards: _.shuffle(init()),
      screen_disabled: false
    });
    */
  }



  render(){
    let cards = this.state.cards;

    return(
      <div className='container'>
        <div className='row'>
          <Attempts state={this.state} />
          <Score state={this.state} />
        </div>

        <div className='row'>
          <div className='col-md-12'>
            <div className='grid-container'>
              {cards.map( (card,i) =>
                <div className="grid-item"><Card root={this} index={card["index"]} key={i} /></div>
              )}
            </div>
          </div>
        </div>

        <div className='row'>
          <Button onClick={ this.restart.bind(this) }><b>Restart Game</b></Button>
        </div>
      </div>
    );
  }
}






function Card(props) {
  let cards = props.root.state.cards;

  if(cards[props.index].match == true) {
    let letter = cards[props.index].letter;
    return (
      <div className="open-card">{letter}</div>
    );
  }

  else if(cards[props.index].flag == true) {
    let letter = cards[props.index].letter;
    return (
      <div className="middle-card">{letter}</div>
    );
  }

  else {
    return (
      //<div className='hide-card' key={props.index} onClick={ () => props.root.handle_click(props.index)}>?</div>
      <div className='hide-card' onClick={ () => props.root.user_click(props.index)}>?</div>
    );
  }
}


function Attempts(props) {
  let attempts = props.state.attempts;

  return (
    <div className='col-md-6'>
      <p><b>Number of Your Attempts:</b></p>
      <p>{ attempts }</p>
    </div>
  );
}



function Score(props) {
  let score = props.state.score;

  return (
    <div className='col-md-6'>
      <p><b>Your Score: { score }</b></p>
    </div>
  );
}
