import java.io.*;
class Test
{
  public int test() throws Exception
  {
    Buyer x1=new Buyer(2);
    Seller x=new Seller(10);
    int score=0;
    x1.buy(x);
    if(x1.getCash()==1)
    {
      x1.setCash(0);
      x1.buy(x);
      if(x1.getCash()==0)
      {
        x1.setCash(1);
        x.setQuantity(0);
        x1.buy(x);
        if(x1.getCash()==1)
        {
          score=1;
        }
      }
    }
    return score;
  }
}
