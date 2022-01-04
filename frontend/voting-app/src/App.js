import './App.css';
import home from './initial/home'
import registration from "./initial/registration"
import VotingPage from './initial/votingPage';
import voted from './initial/voted';
import {Route,Routes} from 'react-router-dom';
//import Route from 'react-router-dom'

function App() {
  return (
    //  <div>
    //   <ul>
    //     <li>
    //       <Link to="/">
    //         home
    //       </Link>
    //     </li>
    //     <li>
    //       <Link to="/voting">
    //         voting
    //       </Link>
    //     </li>
    //     <li>
    //       <Link to="/voted">
    //         voted
    //       </Link>
    //     </li>
    //   </ul>
    <div>
      <Routes>
        <Route path="/" exact element={registration()}/>
        <Route path="/voting" exact element={VotingPage}/>
        <Route path="/voted" exact element={voted}/>
      </Routes>
    </div>
  )
}

export default App;
