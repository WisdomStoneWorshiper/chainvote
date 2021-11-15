import { useNavigate, Link } from "react-router-dom";

function VotingPage(){
    
    let currentVote = ""
    function setVote(candidate){
        currentVote = candidate.candidate
    }
    function CheckVote(){
        if (currentVote !== ""){
            SubmitVote()
        }
        else{
            console.log("empty vote")
        }
    }
    function SubmitVote(){
        console.log(currentVote+" being voted for")
    //    let navigate = useNavigate();
    //    navigate('voted');
    }
      
    const candidateList = ["Candidate 1","Candidate 2","Candidate 3","Candidate 4"]
    const candidateListElements = candidateList.map((candidate)=>
            {
                if ({candidate}.candidate==="tempNotNeeded"){//candidateList[0]) {
                    console.log("IF CALLED FOR",{candidate})
                    return(<div>
                        <input type="radio" name="candidate" value={candidate} checked={false} onChange={()=>{
                            setVote({candidate})
                        }}/>
                        {candidate}
                        <br></br>    
                    </div>)
                }
                else{
                    return(
                    <div>
                        <input type="radio" name="candidate" value={candidate} onChange={()=>{
                            setVote({candidate})
                        }}/>
                        {candidate}
                        <br></br>    
                    </div>)
                }
            }
            
        
    );
    return(
        <div>
            {candidateListElements}
            <br/> 
            
                <Link to="/voted">
                <button onClick={CheckVote}>
                    Submit Vote
                </button>
                </Link>
            
        </div>
    )
}



export default VotingPage;