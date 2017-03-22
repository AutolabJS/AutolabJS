#include "Buyer.hpp"

Buyer::Buyer(int cash)
{
    this->cash=cash;
}

int Buyer::getCash()
{
    return cash;
}

void Buyer::setCash(int cash)
{
    this->cash=cash;
}

void Buyer::buy(Seller x)
{
    if(cash>0)
    {
      if(x.sell()==1)
      {
        cash--;
      }
    }
}

