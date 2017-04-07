class BuyerMistake
{
  intentional error;
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

  public void buy(Seller seller)
  {
    if(cash>0)
    {
      if(seller.sell()==1)
      {
        cash--;
      }
    }
  }
}
