package choral.raft;

//Implemented with Generic Types, however the left corresponds to the term, while the right to the log entry of that term
public class RequestVote@A{
    private Integer@A term;
    private Integer@A candidateId;
    private Integer@A lastLogIndex;
    private Integer@A lastLogTerm;


    //Arguments: term, candidateId, lastLogIndex, lastLogTerm
    public RequestVote(Integer@A term, Integer@A candidateId, Integer@A lastLogIndex, Integer@A lastLogTerm){
        this.term = term;
        this.candidateId = candidateId;
        this.lastLogIndex = lastLogIndex;
        this.lastLogTerm = lastLogTerm;
    }
    public Integer@A term(){
        return this.term;
    }
    public Integer@A candidateId(){
        return this.candidateId;
    }
    public Integer@A lastLogIndex(){
        return this.lastLogIndex;
    }
    public Integer@A lastLogTerm(){
        return this.lastLogTerm;
    }
    
}