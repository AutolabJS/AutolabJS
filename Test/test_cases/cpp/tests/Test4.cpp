#include "Buyer.hpp"

using namespace std;

int test()
{
    Buyer buyer(2);
    Seller seller(10);
    int score=0;
    buyer.buy(seller);
    if(buyer.getCash()==1)
    {
      buyer.setCash(0);
      buyer.buy(seller);
      if(buyer.getCash()==0)
      {
        buyer.setCash(1);
        seller.setQuantity(0);
        buyer.buy(seller);
        if(buyer.getCash()==1)
        {
          score=1;
        }
      }
    }
    return score;
}
