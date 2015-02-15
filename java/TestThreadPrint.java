
class ThreadPrint extends Thread {

  static int numall = 0 ;
  int num ;
  String msg ;

  ThreadPrint (String msg) {
    numall++ ; num=numall ;
    this.msg = msg ;
  }

  public void run() {
    try {
      for (int i=0;i<5;i++) {
        int s = (int) Math.random()*100 ;
        Thread.sleep(s) ;
        System.out.println( msg ) ;
      }
    }
    catch ( InterruptedException e ) {
      e.printStackTrace() ;
    }
  }
}


class TestThreadPrint {
  public static void main (String args[]) {
    ThreadPrint t1 = new ThreadPrint( "toto" ) ;
    ThreadPrint t2 = new ThreadPrint( "    tata" ) ;
    ThreadPrint t3 = new ThreadPrint( "        tutu" ) ;
    t1.start() ;
    t2.start() ;
    t3.start() ;
  }
}

