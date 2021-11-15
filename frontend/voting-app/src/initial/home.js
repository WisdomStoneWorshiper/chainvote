import {Link} from 'react-router-dom';

function home(){
    return (
        <div>
            <h1> Welcome to the blockchain based voting system </h1>
            <Link to="/voting">
                <button >
                    Cast Vote
                </button>
            </Link>
        </div>

        
    )
}


export default home;