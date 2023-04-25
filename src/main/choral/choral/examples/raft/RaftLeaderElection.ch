package choral.raft;

// import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
// import java.util.Random;
// import java.util.concurrent.Executor;
// import java.util.concurrent.ExecutorService;

import choral.raft.Pair;
import choral.raft.Server;
import choral.raft.RequestVote;

import choral.channels.SymChannel;

public class RaftLeaderElection@(A,B,C){
	private Server@A node_A;
	private Server@B node_B;
	private Server@C node_C;
	private SymChannel@( A, B )< Object > ch_AB;
	private SymChannel@( B, C )< Object > ch_BC;
	private SymChannel@( C, A )< Object > ch_CA;

	public  RaftLeaderElection(
		Server@A node_A,
		Server@B node_B,
	 	Server@C node_C,
		SymChannel@( A, B )< Object > ch_AB,
		SymChannel@( B, C )< Object > ch_BC,
		SymChannel@( C, A )< Object > ch_CA
	) {
			this.node_A = node_A;
			this.node_B = node_B;
			this.node_C = node_C;
			this.ch_AB = ch_AB;
			this.ch_BC = ch_BC;
			this.ch_CA = ch_CA;
	}


	public void setServerStateCandidate(){
		node_A.setState(PossibleStates@A.CANDIDATE);
		node_A.setCurrentTerm(node_A.getCurrentTerm() + 1@A);
		node_A.setVoteCount(1@A);
		node_A.setVotedFor(node_A.getServerId());

		node_B.setState(PossibleStates@B.CANDIDATE);
		node_B.setCurrentTerm(node_B.getCurrentTerm()+ 1@B);
		node_B.setVoteCount(1@B);
		node_B.setVotedFor(node_B.getServerId());

		node_C.setState(PossibleStates@C.CANDIDATE);
		node_C.setCurrentTerm(node_C.getCurrentTerm() + 1@C);
		node_C.setVoteCount(1@C);
		node_C.setVotedFor(node_C.getServerId());
		
	}

	public void printServer(){

		System@A.out.println("ServerID:"@A);
		System@A.out.println(node_A.getServerId());
		System@A.out.println("ServerState:"@A);
		System@A.out.println(node_A.getState());
		System@A.out.println("VoteCount:%d"@A);
		System@A.out.println(node_A.getVoteCount());

		System@B.out.println("ServerID:"@B);
		System@B.out.println(node_B.getServerId());
		System@B.out.println("ServerState:"@B);
		System@B.out.println(node_B.getState());
		System@B.out.println("VoteCount:%d"@B);
		System@B.out.println(node_B.getVoteCount());

		System@C.out.println("ServerID:"@C);
		System@C.out.println(node_C.getServerId());
		System@C.out.println("ServerState:"@C);
		System@C.out.println(node_C.getState());
		System@C.out.println("VoteCount:%d"@C);
		System@C.out.println(node_C.getVoteCount());

	}
	
	//Arguments: term, candidateId, lastLogIndex, lastLogTerm
	//Results: term, voteGranted
    public void RequestVote() {
		// Begin Election! We are now candidate!
		setServerStateCandidate();

		//Arguments: term, candidateId, lastLogIndex, lastLogTerm
		RequestVote@A voteSend_A = new RequestVote@A(
			node_A.getCurrentTerm(),
			node_A.getServerId(),
			node_A.getCommitIndex(),
			node_A.getLastApplied());

		RequestVote@B voteSend_B = new RequestVote@B(
			node_B.getCurrentTerm(),
			node_B.getServerId(),
			node_B.getCommitIndex(),
			node_B.getLastApplied());

		RequestVote@C voteSend_C = new RequestVote@C(
			node_C.getCurrentTerm(),
			node_C.getServerId(),
			node_C.getCommitIndex(),
			node_C.getLastApplied());


		//Results: term, voteGranted
		//A
		RequestVote@B voteReceive_AatB = voteSend_A >> ch_AB::<RequestVote>com;
		RequestVote@C voteReceive_AatC = voteSend_A >> ch_CA::<RequestVote>com;

		//B
		RequestVote@C voteReceive_BatC = voteSend_B >> ch_BC::<RequestVote>com;
		RequestVote@A voteReceive_BatA = voteSend_B >> ch_AB::<RequestVote>com;

		//C
		RequestVote@A voteReceive_CatA = voteSend_C >> ch_CA::<RequestVote>com;
		RequestVote@B voteReceive_CatB = voteSend_C >> ch_BC::<RequestVote>com;

		//A
		//Reply false if term < currentTerm
		//If votedFor is null or candidateId, and candidate’s log 
		//is at least as up-to-date as receiver’s log, grant vote
		Integer@B voteAatB = Integer@B.valueOf(0@B);
		Integer@C voteAatC = Integer@C.valueOf(0@C);
		if(voteReceive_AatB.term() < node_B.getCurrentTerm()){
			voteAatB = Integer@B.valueOf(0@B);
		}  
		if (
			node_B.getVotedFor() == null@B ||
			node_B.getVotedFor()  == node_B.getServerId()
			 ) {
				node_B.setState(PossibleStates@B.FOLLOWER);
				voteAatB = Integer@B.valueOf(1@B);
		}

		if(voteReceive_AatC.term() < node_C.getCurrentTerm()){
			voteAatC = Integer@C.valueOf(0@C);
		}  
		if (
			node_C.getVotedFor() == null@C ||
			node_C.getVotedFor()  == node_C.getServerId() ){
				node_C.setState(PossibleStates@C.FOLLOWER);
				voteAatC = Integer@C.valueOf(1@C);
		}

		//Add votes from other participants to local
		Integer@A vote1_result_A = voteAatB >> ch_AB::<Integer>com;
		Integer@A vote2_result_A = voteAatC >> ch_CA::<Integer>com; 
		node_A.setVoteCount( vote1_result_A + vote2_result_A);

		//We have majority of votes, become leader
		if( node_A.getVoteCount() >= node_A.getServerCount()/2@A){
			node_A.setState(PossibleStates@A.LEADER);
		}

		//B
		//Reply false if term < currentTerm
		//If votedFor is null or candidateId, and candidate’s log 
		//is at least as up-to-date as receiver’s log, grant vote
		Integer@C voteBatC = Integer@C.valueOf(0@C);
		Integer@A voteBatA = Integer@A.valueOf(0@A);
		if(voteReceive_BatC.term() < node_C.getCurrentTerm()){
			node_C.setState(PossibleStates@C.FOLLOWER);
			voteBatC = Integer@C.valueOf(0@C);
		}  
		if (
		node_C.getVotedFor() == null@C ||
		node_C.getVotedFor()  == node_C.getServerId() ){
			voteBatC = Integer@C.valueOf(1@C);
		}

		if(voteReceive_BatA.term() < node_A.getCurrentTerm()){
			node_A.setState(PossibleStates@A.FOLLOWER);
			voteBatA = Integer@A.valueOf(0@A);
		}  
		if (
		node_A.getVotedFor() == null@A ||
		node_A.getVotedFor()  == node_A.getServerId() ){
				voteBatA = Integer@A.valueOf(1@A);
		}

		//Add votes from other participants to local
		Integer@B vote1_result_B = voteBatC >> ch_BC::<Integer>com;
		Integer@B vote2_result_B = voteBatA >> ch_AB::<Integer>com; 
		node_B.setVoteCount( vote1_result_B + vote2_result_B);

		//We have majority of votes, become leader
		if( node_B.getVoteCount() >= node_B.getServerCount()/2@B){
			node_B.setState(PossibleStates@B.LEADER);
		}

		//TODO: Bug, logic is maybe wrong about vote grant
		//C
		//Reply false if term < currentTerm
		//If votedFor is null or candidateId, and candidate’s log 
		//is at least as up-to-date as receiver’s log, grant vote
		Integer@A voteCatA = Integer@A.valueOf(0@A);
		Integer@B voteCatB = Integer@B.valueOf(0@B);
		if(voteReceive_CatA.term() < node_A.getCurrentTerm()){
			node_A.setState(PossibleStates@A.FOLLOWER);
			voteCatA = Integer@A.valueOf(0@A);
		}  
		if (
		node_A.getVotedFor() == null@A ||
		node_A.getVotedFor()  == node_A.getServerId() ){
			voteCatA = Integer@A.valueOf(1@A);
		}

		if(voteReceive_CatB.term() < node_B.getCurrentTerm()){
			node_B.setState(PossibleStates@B.FOLLOWER);
			voteCatB = Integer@B.valueOf(0@B);
		}  
		if (
		node_B.getVotedFor() == null@B ||
		node_B.getVotedFor()  == node_B.getServerId() ){
			voteCatB = Integer@B.valueOf(1@B);
		}

		//Add votes from other participants to local
		Integer@C vote1_result_C = voteCatA >> ch_CA::<Integer>com;
		Integer@C vote2_result_C = voteCatB >> ch_BC::<Integer>com; 
		node_C.setVoteCount( vote1_result_C + vote2_result_C);

		//We have majority of votes, become leader
		if( node_C.getVoteCount() >= node_C.getServerCount()/2@C){
			node_C.setState(PossibleStates@C.LEADER);
		}


		// Print out IDs and States
		printServer();
    }



}