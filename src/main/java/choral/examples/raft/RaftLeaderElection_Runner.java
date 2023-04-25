package choral.examples.raft;

import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.ExecutorService;

import choral.raft.RaftLeaderElection_A;
import choral.raft.RaftLeaderElection_B;
import choral.raft.RaftLeaderElection_C;
import choral.raft.Server;

import choral.channels.SymChannel_A;
import choral.channels.SymChannel_B;

import choral.choralUnit.testUtils.TestUtils_A;
import choral.choralUnit.testUtils.TestUtils_B;


public class RaftLeaderElection_Runner {

    public static void main(String[] args){
        runProtocol();
    }

    public static void runProtocol(){
        try {
            ExecutorService executors = Executors.newFixedThreadPool( 3 );

            //Three Comm channels
            SymChannel_A< Object > ch_AB_A_Channel = TestUtils_A.newLocalChannel("ch_AB" );
            SymChannel_A< Object > ch_BC_A_Channel = TestUtils_A.newLocalChannel("ch_BC" );
            SymChannel_A< Object > ch_CA_A_Channel = TestUtils_A.newLocalChannel("ch_CA" );

            SymChannel_B< Object > ch_AB_B_Channel = TestUtils_B.newLocalChannel("ch_AB" );
            SymChannel_B< Object > ch_BC_B_Channel = TestUtils_B.newLocalChannel("ch_BC" );
            SymChannel_B< Object > ch_CA_B_Channel = TestUtils_B.newLocalChannel("ch_CA" );
                    
            // Instantiate three Servers, and apply Request vote with variable timeout
            Server node_A = new Server(1, 0, 0, 3);
            Server node_B = new Server(2, 0, 0, 3);
            Server node_C = new Server(3, 0, 0, 3);

            RaftLeaderElection_A election_A = new RaftLeaderElection_A(node_A, ch_AB_A_Channel, ch_CA_B_Channel);
            RaftLeaderElection_B election_B = new RaftLeaderElection_B(node_B, ch_AB_B_Channel, ch_BC_A_Channel);
            RaftLeaderElection_C election_C = new RaftLeaderElection_C(node_C, ch_BC_B_Channel, ch_CA_A_Channel);

            Future< ? > f1 = executors.submit( () -> election_A.RequestVote() );
            Future< ? > f2 = executors.submit( () -> election_B.RequestVote());
            Future< ? > f3 = executors.submit( () -> election_C.RequestVote());

            f1.get();
            f2.get();
            f3.get();
            //f1.get(1000, TimeUnit.MILLISECONDS);

            executors.shutdown();
            

		} catch( Exception e ) {
			e.printStackTrace();
		}

    }
}