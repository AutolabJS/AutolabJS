import java.io.*;
class Buyer
{
  private int cash;

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

  public void buy(Seller x) throws Exception
  {
    if(cash>0)
    {
      if(x.sell()==1)
      {
        cash--;
      }
    }
	throw new Exception();
  }
}
