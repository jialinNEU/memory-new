import React from 'react';
import ReactDOM from 'react-dom';
import { Button } from 'reactstrap';

export default function game_init(root, channel) {
  ReactDOM.render(<Memory channel={channel} />, root);
}


class Memory extends React.Component {

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
  }

  user_click(index) {

    this.channel.push("user_click", { index: index} )
    .receive("ok", this.gotView.bind(this));
    let attempts = this.state.attempts;
    if (attempts % 2 == 1) {
      console.log(attempts);
      window.setTimeout( () => {
        this.channel.push("card_match", { index: index})
        .receive("ok", this.gotView.bind(this));
      }, 1500);
    }
  }

  game_restart() {
    this.channel.push("game_restart", {})
    .receive("ok", this.gotView.bind(this))
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
                <div className="grid-item" key={i} ><Card root={this} index={card["index"]} /></div>
              )}
            </div>
          </div>
        </div>

        <div className='row'>
          <Button onClick={ this.game_restart.bind(this) }><b>Restart Game</b></Button>
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
