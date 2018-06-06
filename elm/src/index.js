import './main.css';
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

//Main.embed(document.getElementById('root'));

const elmDiv = document.getElementById('root');

debugger;

const elmApp = Main.embed(elmDiv, {
  homeAddress: process.env.ELM_APP_HOME_ADDRESS
});

registerServiceWorker();
