import './main.css';
import { Main } from './Main.elm';
//import registerServiceWorker from './registerServiceWorker';

const elmDiv = document.getElementById('root');

const elmApp = Main.embed(elmDiv, {
  homeAddress: `http://${process.env.ELM_APP_HOME_ADDRESS}`
});

//registerServiceWorker();
