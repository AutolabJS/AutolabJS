import java.io.*;

class Test
{
  public int test()
  {
    Seller x1=new Seller(2);
    int score=0;
    if(x1.sell()==1)
    {
      if(x1.getQuantity()==1)
      {
        x1.setQuantity(0);
        if(x1.sell()==0)
        {
          if(x1.getQuantity()==0)
          {
            score=1;
          }
        }
      }
    }
    return score;
  }
}
