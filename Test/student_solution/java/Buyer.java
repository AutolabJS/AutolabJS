import java.io.*;
ahaa this is a syntax error now //this is a comment
class Buyer
{
  //private int cash;

  public Buyer(int cash)
  {
    this.cash=cash;
  }

  public int getCash()
  {
    return cash;
  }

  public void setCash(int cash)
  {
    this.cash=cash;
  }

  public void buy(Seller x)
  {
    if(cash>0)
    {
      if(x.sell()==1)
      {
        cash--;
        
      //}
    }
  }
}
