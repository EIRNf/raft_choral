package choral.raft;

//import raft.LogEntry;

// import java.util.concurrent.ExecutorService;
import java.util.ArrayList;
import java.util.List;
// import choral.raft.PossibleStates;
enum PossibleStates@A {FOLLOWER, CANDIDATE, LEADER}

//Generic server class, role A generic parameter to be instantiated by a names role.
public class Server@A {
    public Integer@A serverId; 
    public PossibleStates@A state;

    // public Duration@(A,B,C) electionTimeout;
	public Integer@A serverCount;
    
    //"Persistent" States

    //latest term server has seen (initialized to 0 on first boot, increases monotonically)
    public Integer@A currentTerm;
    //candidateId that received vote in current term (or null if none)
    public Integer@A votedFor;
    //count for how many votes have been received
    public Integer@A voteCount;
    //log entries; each entry contains command for state machine, and term when entry was received by leader (first index is 1)
    // public List<LogEntry<Integer@A,Integer@A>> log;

    //Volatile States

    //index of highest log entry known to be committed (initialized to 0, increases monotonically)
    public Integer@A commitIndex;
    //index of highest log entry applied to state machine (initialized to 0, increases monotonically)
    public Integer@A lastApplied;

    public Server(
        Integer@A serverId, 
        Integer@A commitIndex, 
        Integer@A lastApplied,
        Integer@A serverCount){
        this.serverId = serverId;
        this.state = PossibleStates@A.FOLLOWER;  //Instantiate as a Follower

        this.currentTerm = 0@A;
        this.votedFor = 0@A;
        //Instantiate empty ArrayList as log
        // log = new ArrayList@A<LogEntry<Integer@A,Integer@A>>();

        this.commitIndex = commitIndex;
        this.lastApplied = lastApplied;
        this.serverCount = serverCount;
    }

    public Integer@A getServerId() {
        return this.serverId;
    }

    public void setServerId(Integer@A serverId) {
        this.serverId = serverId;
    }

    public PossibleStates@A getState() {
        return this.state;
    }

    public void setState(PossibleStates@A state) {
        this.state = state;
    }

    public Integer@A getServerCount() {
        return this.serverCount;
    }

    public void setServerCount(Integer@A serverCount) {
        this.serverCount = serverCount;
    }

    public Integer@A getCurrentTerm() {
        return this.currentTerm;
    }

    public void setCurrentTerm(Integer@A currentTerm) {
        this.currentTerm = currentTerm;
    }

    public Integer@A getVotedFor() {
        return this.votedFor;
    }

    public void setVotedFor(Integer@A votedFor) {
        this.votedFor = votedFor;
    }

    public Integer@A getVoteCount() {
        return this.voteCount;
    }

    public void setVoteCount(Integer@A voteCount) {
        this.voteCount = voteCount;
    }

    public Integer@A getCommitIndex() {
        return this.commitIndex;
    }

    public void setCommitIndex(Integer@A commitIndex) {
        this.commitIndex = commitIndex;
    }

    public Integer@A getLastApplied() {
        return this.lastApplied;
    }

    public void setLastApplied(Integer@A lastApplied) {
        this.lastApplied = lastApplied;
    }


}
