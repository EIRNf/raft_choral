package choral.raft;

// Pair class for returns
public class Pair@A<L@X, R@X>{
    private L@A left;
    private R@A right;
    
    public Pair(L@A left, R@A right){
        this.left = left;
        this.right = right;
    }
    public L@A left(){
        return this.left;
    }
    public R@A right(){
        return this.right;
    }
}