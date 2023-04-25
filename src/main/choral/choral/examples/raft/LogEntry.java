package choral.raft;

//Implemented with Generic Types, however the left corresponds to the term, while the right to the log entry of that term
public class LogEntry<L, R>{
    private L term;
    private R entry;
    
    public LogEntry(L term, R entry){
        this.term = term;
        this.entry = entry;
    }
    public L term(){
        return this.term;
    }
    public R entry(){
        return this.entry;
    }
}