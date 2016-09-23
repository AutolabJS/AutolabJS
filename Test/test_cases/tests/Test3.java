import java.io.*;
class Test
{
  public int test() {
    Buyer x1=new Buyer(100);
    if(x1.getCash()==100)
    {
      x1.setCash(20);
      if(x1.getCash()==20)
      {
        return 1;
      }
      else
      {
        return 0;
      }
    }
    else
    {
      return 0;
    }
  }
}
