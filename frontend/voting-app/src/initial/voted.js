import {Link} from 'react-router-dom';

function voted(){
    return (
        <div>
            <h1> Thank you for voting! </h1>
            <Link to="/">
                <button >
                    Cast New Vote
                </button>
            </Link>
        </div>

        
    )
}


export default voted;