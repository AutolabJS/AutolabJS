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

  public void buy(Seller x)
  {
      if(x.sell()==1)
      {
        cash--;
      }

  }
}
